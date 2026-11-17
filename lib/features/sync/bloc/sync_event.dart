import 'package:equatable/equatable.dart';

/// Base class for events handled by SyncBloc.
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers load of queue counts and transaction history.
class LoadSyncData extends SyncEvent {
  const LoadSyncData();
}

/// Triggers manual synchronization of pending offline attendance records.
class TriggerSyncNow extends SyncEvent {
  const TriggerSyncNow();
}

/// Checks network connectivity and automatically syncs pending queue if online.
class AutoSyncIfOnline extends SyncEvent {
  const AutoSyncIfOnline();
}
