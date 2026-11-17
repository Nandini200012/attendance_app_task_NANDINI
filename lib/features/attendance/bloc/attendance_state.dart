import 'package:equatable/equatable.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/attendance_summary.dart';

/// Base state for AttendanceBloc.
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

/// Loading state during fetch or sync.
class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

/// Comprehensive active state containing records, metrics, and location telemetry.
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final AttendanceMonthlySummary summary;
  final String selectedMonth;
  final AttendanceStatus todayStatus;
  final LocationState locationState;
  final double distanceMeters;
  final AttendanceEvent? lastPunchEvent;
  final String? notificationMessage;

  const AttendanceLoaded({
    required this.records,
    required this.summary,
    required this.selectedMonth,
    required this.todayStatus,
    this.locationState = LocationState.granted,
    this.distanceMeters = 48.2,
    this.lastPunchEvent,
    this.notificationMessage,
  });

  AttendanceLoaded copyWith({
    List<AttendanceRecord>? records,
    AttendanceMonthlySummary? summary,
    String? selectedMonth,
    AttendanceStatus? todayStatus,
    LocationState? locationState,
    double? distanceMeters,
    AttendanceEvent? lastPunchEvent,
    String? notificationMessage,
  }) {
    return AttendanceLoaded(
      records: records ?? this.records,
      summary: summary ?? this.summary,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      todayStatus: todayStatus ?? this.todayStatus,
      locationState: locationState ?? this.locationState,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      lastPunchEvent: lastPunchEvent ?? this.lastPunchEvent,
      notificationMessage: notificationMessage,
    );
  }

  @override
  List<Object?> get props => [
    records,
    summary,
    selectedMonth,
    todayStatus,
    locationState,
    distanceMeters,
    lastPunchEvent,
    notificationMessage,
  ];
}

/// Error state when network or validation fails.
class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
