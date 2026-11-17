import 'package:equatable/equatable.dart';
import '../data/models/dashboard_data.dart';

/// Base class representing all states emitted by DashboardBloc.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state before any fetch occurs.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// State emitted while fetching dashboard information.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State emitted when dashboard data is successfully loaded or restored from cache.
class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// State emitted when dashboard fetch encounters an unrecoverable failure.
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
