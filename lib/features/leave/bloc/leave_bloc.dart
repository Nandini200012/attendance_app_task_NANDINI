import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/leave_model.dart';
import '../data/repositories/leave_repository.dart';
import 'leave_event.dart';
import 'leave_state.dart';

/// BLoC coordinating leave balance tracking and application form dispatch.
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _repository;

  LeaveBloc({required LeaveRepository repository})
    : _repository = repository,
      super(const LeaveInitial()) {
    on<LoadLeaveData>(_onLoadLeaveData);
    on<SubmitLeaveApplication>(_onSubmitLeaveApplication);
  }

  Future<void> _onLoadLeaveData(
    LoadLeaveData event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveLoading());
    try {
      final balance = await _repository.getLeaveBalance();
      final requests = await _repository.getLeaveRequests();
      emit(LeaveLoaded(balance: balance, requests: requests));
    } catch (_) {
      emit(
        const LeaveLoaded(balance: LeaveBalance.empty, requests: []),
      );
    }
  }

  Future<void> _onSubmitLeaveApplication(
    SubmitLeaveApplication event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveSubmitting());
    try {
      final created = await _repository.submitLeaveRequest(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        numberOfDays: event.numberOfDays,
        reason: event.reason,
      );
      emit(LeaveSubmitSuccess(created));
      final balance = await _repository.getLeaveBalance();
      final requests = await _repository.getLeaveRequests();
      emit(
        LeaveLoaded(
          balance: balance,
          requests: requests,
          notificationMessage: 'Leave application submitted successfully.',
        ),
      );
    } on ServerException catch (e) {
      emit(LeaveSubmitFailure(e.message));
    } catch (e) {
      emit(LeaveSubmitFailure('Submission failed: $e'));
    }
  }
}
