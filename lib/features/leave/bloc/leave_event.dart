import 'package:equatable/equatable.dart';
import '../../../../shared/models/leave_enums.dart';

/// Base class for all events handled by LeaveBloc.
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers fetch of employee leave balance and submitted application history.
class LoadLeaveData extends LeaveEvent {
  const LoadLeaveData();
}

/// Submits an employee leave application.
class SubmitLeaveApplication extends LeaveEvent {
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String reason;

  const SubmitLeaveApplication({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    leaveType,
    startDate,
    endDate,
    numberOfDays,
    reason,
  ];
}
