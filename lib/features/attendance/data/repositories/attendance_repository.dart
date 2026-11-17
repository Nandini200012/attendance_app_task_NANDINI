import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/location_calculator.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/attendance_summary.dart';
import '../../../sync/data/services/cache_storage_service.dart';
import '../../../sync/data/services/sync_storage_service.dart';
import '../models/attendance_month_result.dart';
import '../services/attendance_api_service.dart';
import '../utils/attendance_record_merger.dart';

/// Repository coordinating attendance punch telemetry and geofence verification.
class AttendanceRepository {
  final AttendanceApiService _apiService;
  final SyncStorageService _storageService;
  final CacheStorageService _cacheService;
  final Uuid _uuid;

  AttendanceRepository({
    AttendanceApiService? apiService,
    required SyncStorageService storageService,
    CacheStorageService? cacheService,
    Uuid? uuid,
  }) : _apiService = apiService ?? AttendanceApiService(),
       _storageService = storageService,
       _cacheService = cacheService ?? CacheStorageService(),
       _uuid = uuid ?? const Uuid();

  /// Returns all offline events currently waiting in the pending queue.
  List<AttendanceEvent> getPendingEvents() =>
      _storageService.getPendingEvents();

  /// Queries attendance records with Hive offline cache fallback.
  Future<AttendanceMonthResult> getAttendanceHistory(String month) async {
    List<AttendanceRecord> records = [];
    try {
      final result = await _apiService.getAttendance(month: month);
      records = result.records;
    } catch (_) {
      records = _cacheService.getCachedAttendanceRecords(month);
    }

    final localEvents = _storageService.getPendingEvents() +
        _storageService.getSyncedEvents();
    final merged = AttendanceRecordMerger.mergeEvents(records, localEvents);
    if (merged.isNotEmpty) {
      await _cacheService.cacheAttendanceRecords(month, merged);
    }
    return AttendanceMonthResult(
      records: merged,
      summary: AttendanceMonthlySummary.fromRecords(month, merged),
    );
  }

  /// Records an attendance punch with guaranteed local persistence and geofence check.
  Future<AttendanceEvent> recordPunch({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    double? distanceMeters,
    String? employeeId,
    DateTime? timestamp,
  }) async {
    final dist = distanceMeters ??
        LocationCalculator.distanceFromOffice(latitude: latitude, longitude: longitude);
    final empId = employeeId ??
        _cacheService.getCachedEmployee()?.employeeCode ?? 'EMP-2048';

    // 1. Offline geofence perimeter validation against configured office location
    if (dist > AppConstants.allowedRadiusMeters) {
      final reason =
          'Outside allowed geofence perimeter (${dist.toStringAsFixed(1)}m > ${AppConstants.allowedRadiusMeters.toInt()}m limit).';
      final rejected = AttendanceEvent(
        eventId: 'evt-${_uuid.v4()}',
        eventType: eventType,
        timestamp: timestamp ?? DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        distanceMeters: dist,
        syncStatus: SyncStatus.rejected,
        rejectionReason: reason,
        employeeId: empId,
      );
      await _storageService.markEventRejected(rejected, reason);
      return rejected;
    }

    final event = AttendanceEvent(
      eventId: 'evt-${_uuid.v4()}',
      eventType: eventType,
      timestamp: timestamp ?? DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      distanceMeters: dist,
      syncStatus: SyncStatus.pending,
      employeeId: empId,
    );

    await _storageService.queuePendingEvent(event);
    AttendanceEvent punchResult;

    try {
      final ack = await _apiService.postAttendanceEvent(event);
      final status = ack['status'] as String? ?? 'synced';

      if (status == 'rejected') {
        final reason =
            ack['rejectionReason'] as String? ?? 'Rejected by server.';
        await _storageService.markEventRejected(event, reason);
        punchResult = _copy(event, SyncStatus.rejected, reason);
      } else {
        await _storageService.markEventSynced(event);
        await _storageService.saveLastSyncTime(DateTime.now());
        punchResult = _copy(event, SyncStatus.synced);
      }
    } on ServerException catch (e) {
      await _storageService.markEventRejected(event, e.message);
      punchResult = _copy(event, SyncStatus.rejected, e.message);
    } catch (_) {
      punchResult = event;
    }

    if (punchResult.syncStatus != SyncStatus.rejected) {
      final d = punchResult.timestamp;
      final m = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      final cached = _cacheService.getCachedAttendanceRecords(m);
      final updated = AttendanceRecordMerger.applyPunch(cached, punchResult);
      await _cacheService.cacheAttendanceRecords(m, updated);
    }
    return punchResult;
  }

  AttendanceEvent _copy(AttendanceEvent e, SyncStatus s, [String? r]) =>
      AttendanceEvent(
        eventId: e.eventId,
        eventType: e.eventType,
        timestamp: e.timestamp,
        latitude: e.latitude,
        longitude: e.longitude,
        distanceMeters: e.distanceMeters,
        syncStatus: s,
        rejectionReason: r ?? e.rejectionReason,
        employeeId: e.employeeId,
      );
}
