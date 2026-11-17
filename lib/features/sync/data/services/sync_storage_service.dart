import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/sync_operation.dart';

/// Manages Hive-based unified offline persistent queue and sync telemetry.
class SyncStorageService {
  static const String queueBoxName = 'rebs_sync_queue';
  static const String syncMetaBoxName = 'rebs_sync_meta';

  Box? _queueBox;
  Box? _metaBox;

  /// Initializes required Hive boxes idempotently.
  Future<void> init() async {
    _queueBox = await Hive.openBox(queueBoxName);
    _metaBox = await Hive.openBox(syncMetaBoxName);
  }

  /// Appends an offline operation to the persistent queue.
  Future<void> enqueueOperation(SyncOperation op) async {
    await _queueBox?.put(op.id, op.toJson());
  }

  /// Retrieves all operations in the persistent queue sorted by creation date.
  List<SyncOperation> getAllOperations() {
    if (_queueBox == null || _queueBox!.isEmpty) return [];
    final ops = _queueBox!.values
        .whereType<Map>()
        .map((m) => SyncOperation.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    ops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ops;
  }

  /// Retrieves pending operations sorted chronologically (FIFO order).
  List<SyncOperation> getPendingOperations() {
    return getAllOperations()
        .where(
          (o) =>
              o.status == SyncOpStatus.pending ||
              o.status == SyncOpStatus.syncing,
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Retrieves synced operations (latest first).
  List<SyncOperation> getSyncedOperations() =>
      getAllOperations().where((o) => o.status == SyncOpStatus.synced).toList();

  /// Retrieves failed operations (latest first).
  List<SyncOperation> getFailedOperations() =>
      getAllOperations().where((o) => o.status == SyncOpStatus.failed).toList();

  /// Updates an operation's sync status, error message, and retry count.
  Future<void> updateOperationStatus(
    String id,
    SyncOpStatus status, {
    String? errorMessage,
    bool incrementRetry = false,
  }) async {
    final raw = _queueBox?.get(id);
    if (raw is Map) {
      final op = SyncOperation.fromJson(Map<String, dynamic>.from(raw));
      final updated = op.copyWith(
        status: status,
        errorMessage: errorMessage ?? op.errorMessage,
        retryCount: incrementRetry ? op.retryCount + 1 : op.retryCount,
      );
      await _queueBox?.put(id, updated.toJson());
    }
  }

  // --- Compatibility bridges for AttendanceEvent ---

  Future<void> queuePendingEvent(AttendanceEvent event) async {
    final type = event.eventType == AttendanceEventType.checkOut
        ? SyncOperationType.checkOut
        : SyncOperationType.checkIn;
    final op = SyncOperation(
      id: event.eventId,
      type: type,
      payload: event.toJson(),
      createdAt: event.timestamp,
      status: SyncOpStatus.pending,
    );
    await enqueueOperation(op);
  }

  List<AttendanceEvent> getPendingEvents() => getPendingOperations()
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  List<AttendanceEvent> getSyncedEvents() => getSyncedOperations()
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  List<AttendanceEvent> getRejectedEvents() => getFailedOperations()
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  Future<void> markEventSynced(AttendanceEvent event) =>
      updateOperationStatus(event.eventId, SyncOpStatus.synced);

  Future<void> markEventRejected(AttendanceEvent event, String reason) async {
    final type = event.eventType == AttendanceEventType.checkOut
        ? SyncOperationType.checkOut
        : SyncOperationType.checkIn;
    final op = SyncOperation(
      id: event.eventId,
      type: type,
      payload: event.toJson(),
      createdAt: event.timestamp,
      status: SyncOpStatus.failed,
      errorMessage: reason,
      retryCount: 1,
    );
    await enqueueOperation(op);
  }

  Future<void> saveLastSyncTime(DateTime time) async =>
      _metaBox?.put('last_sync_time', time.toIso8601String());

  DateTime? getLastSyncTime() {
    final str = _metaBox?.get('last_sync_time') as String?;
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> clearAllSyncData() async {
    await _queueBox?.clear();
    await _metaBox?.clear();
  }
}
