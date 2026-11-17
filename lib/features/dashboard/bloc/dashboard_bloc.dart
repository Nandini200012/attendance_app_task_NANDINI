import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// BLoC coordinating dashboard data fetching and offline fallback states.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
    : _repository = repository,
      super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError('Failed to refresh dashboard: $e'));
    }
  }
}
