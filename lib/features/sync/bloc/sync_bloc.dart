import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// BLoC coordinating offline queue telemetry and background sync transactions.
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository _repository;
  Timer? _autoSyncTimer;

  SyncBloc({required SyncRepository repository, bool enableAutoSync = true})
    : _repository = repository,
      super(const SyncInitial()) {
    on<LoadSyncData>(_onLoadSyncData);
    on<TriggerSyncNow>(_onTriggerSyncNow);
    on<AutoSyncIfOnline>(_onAutoSyncIfOnline);

    if (enableAutoSync) {
      _startAutoSyncMonitor();
    }
  }

  void _startAutoSyncMonitor() {
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) add(const AutoSyncIfOnline());
    });
  }

  Future<void> _onLoadSyncData(
    LoadSyncData event,
    Emitter<SyncState> emit,
  ) async {
    final stats = await _repository.getSyncStats();
    final pending = _repository.getPendingOperations();
    emit(
      SyncLoaded(
        stats: stats,
        pendingOperations: pending,
        syncedOperations: _repository.getSyncedOperations(),
        failedOperations: _repository.getFailedOperations(),
      ),
    );

    if (stats.isOnline && pending.isNotEmpty) {
      add(const TriggerSyncNow());
    }
  }

  Future<void> _onTriggerSyncNow(
    TriggerSyncNow event,
    Emitter<SyncState> emit,
  ) async {
    if (state is SyncLoaded && (state as SyncLoaded).isSyncing) return;

    final initialStats = await _repository.getSyncStats();
    final current = state is SyncLoaded
        ? (state as SyncLoaded)
        : SyncLoaded(
            stats: initialStats,
            pendingOperations: _repository.getPendingOperations(),
            syncedOperations: _repository.getSyncedOperations(),
            failedOperations: _repository.getFailedOperations(),
          );

    emit(current.copyWith(isSyncing: true));

    final isOnline = await _repository.isBackendOnline();
    if (!isOnline) {
      final updatedStats = await _repository.getSyncStats(isOnline: false);
      final remaining = _repository.getPendingOperations().length;
      emit(
        current.copyWith(
          stats: updatedStats,
          isSyncing: false,
          notificationMessage:
              'Sync paused: Server is offline. $remaining item(s) saved safely.',
        ),
      );
      return;
    }

    final initialPending = _repository.getPendingOperations().length;
    final synced = await _repository.syncPendingOperations();
    final updatedStats = await _repository.getSyncStats(isOnline: true);
    final remaining = _repository.getPendingOperations().length;
    final failed = _repository.getFailedOperations().length;

    final msg = _resolveSyncMessage(
      synced: synced,
      failed: failed,
      remaining: remaining,
      initial: initialPending,
    );

    emit(
      current.copyWith(
        stats: updatedStats,
        pendingOperations: _repository.getPendingOperations(),
        syncedOperations: _repository.getSyncedOperations(),
        failedOperations: _repository.getFailedOperations(),
        isSyncing: false,
        notificationMessage: msg,
      ),
    );
  }

  String _resolveSyncMessage({
    required int synced,
    required int failed,
    required int remaining,
    required int initial,
  }) {
    if (initial == 0) return 'All operations are already up to date.';
    if (synced > 0 && remaining == 0) {
      return 'Sync complete: $synced operation(s) synced to server.';
    }
    if (failed > 0) {
      return 'Sync processed: $synced synced, $failed failed or rejected.';
    }
    if (synced > 0 && remaining > 0) {
      return 'Sync progress: $synced synced, $remaining remaining.';
    }
    return 'Sync paused: $remaining item(s) remained pending in queue.';
  }

  Future<void> _onAutoSyncIfOnline(
    AutoSyncIfOnline event,
    Emitter<SyncState> emit,
  ) async {
    if (state is SyncLoaded && (state as SyncLoaded).isSyncing) return;
    if (!_repository.hasPendingOperations()) return;

    final isReachable = await _repository.isBackendOnline();
    if (isReachable) {
      add(const TriggerSyncNow());
    }
  }

  @override
  Future<void> close() {
    _autoSyncTimer?.cancel();
    return super.close();
  }
}
