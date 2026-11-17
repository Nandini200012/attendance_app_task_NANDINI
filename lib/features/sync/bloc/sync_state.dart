import 'package:equatable/equatable.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/sync_model.dart';
import '../../../../shared/models/sync_operation.dart';

/// Base state for SyncBloc.
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Active state driving Screen 7 (Sync Management) with unified queue and telemetry.
class SyncLoaded extends SyncState {
  final SyncStats stats;
  final List<SyncOperation> pendingOperations;
  final List<SyncOperation> syncedOperations;
  final List<SyncOperation> failedOperations;
  final bool isSyncing;
  final String? notificationMessage;

  const SyncLoaded({
    required this.stats,
    required this.pendingOperations,
    required this.syncedOperations,
    required this.failedOperations,
    this.isSyncing = false,
    this.notificationMessage,
  });

  List<AttendanceEvent> get pendingEvents => pendingOperations
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  List<AttendanceEvent> get syncedEvents => syncedOperations
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  List<AttendanceEvent> get rejectedEvents => failedOperations
      .where((o) => o.isAttendance)
      .map((o) => o.toAttendanceEvent())
      .toList();

  SyncLoaded copyWith({
    SyncStats? stats,
    List<SyncOperation>? pendingOperations,
    List<SyncOperation>? syncedOperations,
    List<SyncOperation>? failedOperations,
    bool? isSyncing,
    String? notificationMessage,
  }) {
    return SyncLoaded(
      stats: stats ?? this.stats,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      syncedOperations: syncedOperations ?? this.syncedOperations,
      failedOperations: failedOperations ?? this.failedOperations,
      isSyncing: isSyncing ?? this.isSyncing,
      notificationMessage: notificationMessage,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    pendingOperations,
    syncedOperations,
    failedOperations,
    isSyncing,
    notificationMessage,
  ];
}

/// State emitted when sync operation experiences unrecoverable error.
class SyncFailure extends SyncState {
  final String error;

  const SyncFailure(this.error);

  @override
  List<Object?> get props => [error];
}
