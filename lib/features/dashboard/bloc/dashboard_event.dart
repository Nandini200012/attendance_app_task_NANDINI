import 'package:equatable/equatable.dart';

/// Base class for all events dispatched to DashboardBloc.
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers initial fetch of dashboard metrics, employee profile, and sync state.
class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

/// Triggers manual pull-to-refresh reload of dashboard data.
class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}
