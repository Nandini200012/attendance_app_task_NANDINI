import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/leave_enums.dart';
import '../../../../shared/models/sync_model.dart';
import '../../../../shared/models/sync_operation.dart';
import '../../../attendance/data/services/attendance_api_service.dart';
import '../../../leave/data/services/leave_api_service.dart';
import '../services/sync_storage_service.dart';

/// Repository managing background synchronization and unified queue draining.
class SyncRepository {
  final SyncStorageService _storageService;
  final AttendanceApiService _attService;
  final LeaveApiService _leaveService;
  final ApiClient _apiClient;
  bool _isSyncing = false;

  SyncRepository({
    required SyncStorageService storageService,
    AttendanceApiService? attendanceApiService,
    AttendanceApiService? apiService,
    LeaveApiService? leaveApiService,
    ApiClient? apiClient,
  }) : _storageService = storageService,
       _attService = attendanceApiService ?? apiService ?? AttendanceApiService(),
       _leaveService = leaveApiService ?? LeaveApiService(),
       _apiClient = apiClient ?? ApiClient();

  Future<SyncStats> getSyncStats({bool? isOnline}) async {
    final online = isOnline ?? await isBackendOnline();
    return SyncStats(
      pendingCount: _storageService.getPendingOperations().length,
      syncedCount: _storageService.getSyncedOperations().length,
      rejectedCount: _storageService.getFailedOperations().length,
      lastSyncTime: _storageService.getLastSyncTime(),
      isOnline: online,
    );
  }

  List<SyncOperation> getPendingOperations() =>
      _storageService.getPendingOperations();
  List<SyncOperation> getSyncedOperations() =>
      _storageService.getSyncedOperations();
  List<SyncOperation> getFailedOperations() =>
      _storageService.getFailedOperations();
  bool hasPendingOperations() =>
      _storageService.getPendingOperations().isNotEmpty;

  List<AttendanceEvent> getPendingEvents() => _storageService.getPendingEvents();
  List<AttendanceEvent> getSyncedEvents() => _storageService.getSyncedEvents();
  List<AttendanceEvent> getRejectedEvents() =>
      _storageService.getRejectedEvents();

  Future<bool> isBackendOnline() => _apiClient.checkConnectivity();

  Future<int> syncPendingOperations() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    try {
      final pending = _storageService.getPendingOperations();
      if (pending.isEmpty) return 0;

      int synced = 0;
      for (final op in pending) {
        try {
          await _storageService.updateOperationStatus(op.id, SyncOpStatus.syncing);
          if (op.isAttendance) {
            final ack = await _attService.postAttendanceEvent(
              AttendanceEvent.fromJson(op.payload),
            );
            if (ack['status'] == 'rejected') {
              final r = ack['rejectionReason'] as String? ?? 'Rejected by server.';
              await _storageService.updateOperationStatus(
                op.id,
                SyncOpStatus.failed,
                errorMessage: r,
                incrementRetry: true,
              );
            } else {
              await _storageService.updateOperationStatus(op.id, SyncOpStatus.synced);
              synced++;
            }
          } else if (op.type == SyncOperationType.leaveApplication) {
            await _syncLeave(op);
            synced++;
          }
        } on ServerException catch (e) {
          if (e.message.contains('Duplicate') || e.statusCode == 409) {
            await _storageService.updateOperationStatus(op.id, SyncOpStatus.synced);
            synced++;
          } else {
            await _storageService.updateOperationStatus(
              op.id,
              SyncOpStatus.failed,
              errorMessage: e.message,
              incrementRetry: true,
            );
          }
        } catch (e) {
          await _storageService.updateOperationStatus(
            op.id,
            SyncOpStatus.pending,
            errorMessage: e.toString(),
          );
          break;
        }
      }
      if (synced > 0) await _storageService.saveLastSyncTime(DateTime.now());
      return synced;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncLeave(SyncOperation op) async {
    final p = op.payload;
    final lt = p['leave_type'] == 'sick' || p['leaveType'] == 'sick'
        ? LeaveType.sick
        : LeaveType.casual;
    final s = DateTime.tryParse(p['start_date'] as String? ?? p['startDate'] as String? ?? '') ?? DateTime.now();
    final e = DateTime.tryParse(p['end_date'] as String? ?? p['endDate'] as String? ?? '') ?? DateTime.now();
    final d = p['number_of_days'] as int? ?? p['numberOfDays'] as int? ?? 1;
    await _leaveService.submitLeaveRequest(
      leaveType: lt,
      startDate: s,
      endDate: e,
      numberOfDays: d,
      reason: p['reason'] as String? ?? '',
    );
    await _storageService.updateOperationStatus(op.id, SyncOpStatus.synced);
  }

  Future<int> syncPendingEvents() => syncPendingOperations();
}
