import 'package:equatable/equatable.dart';
import '../../../../shared/models/leave_model.dart';

/// Base state for LeaveBloc.
abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class LeaveInitial extends LeaveState {
  const LeaveInitial();
}

/// Loading state during leave data fetching.
class LeaveLoading extends LeaveState {
  const LeaveLoading();
}

/// Active state providing leave quotas and request history.
class LeaveLoaded extends LeaveState {
  final LeaveBalance balance;
  final List<LeaveRequest> requests;
  final String? notificationMessage;

  const LeaveLoaded({
    required this.balance,
    required this.requests,
    this.notificationMessage,
  });

  LeaveLoaded copyWith({
    LeaveBalance? balance,
    List<LeaveRequest>? requests,
    String? notificationMessage,
  }) {
    return LeaveLoaded(
      balance: balance ?? this.balance,
      requests: requests ?? this.requests,
      notificationMessage: notificationMessage,
    );
  }

  @override
  List<Object?> get props => [balance, requests, notificationMessage];
}

/// State emitted while sending leave submission to API.
class LeaveSubmitting extends LeaveState {
  const LeaveSubmitting();
}

/// State emitted upon successful leave application submission.
class LeaveSubmitSuccess extends LeaveState {
  final LeaveRequest request;

  const LeaveSubmitSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

/// State emitted when leave submission is rejected by validation or network.
class LeaveSubmitFailure extends LeaveState {
  final String error;

  const LeaveSubmitFailure(this.error);

  @override
  List<Object?> get props => [error];
}
