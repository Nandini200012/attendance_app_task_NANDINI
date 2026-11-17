import 'package:equatable/equatable.dart';
import '../../../../shared/models/attendance_enums.dart';

/// Base class for all events handled by AttendanceBloc.
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Requests attendance register data for a given month (e.g. '2026-11').
class LoadAttendanceMonth extends AttendanceEvent {
  final String month;

  const LoadAttendanceMonth(this.month);

  @override
  List<Object?> get props => [month];
}

/// Triggers check-in or check-out punch submission.
class RecordPunch extends AttendanceEvent {
  final AttendanceEventType eventType;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  const RecordPunch({
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  @override
  List<Object?> get props => [eventType, latitude, longitude, distanceMeters];
}

/// Simulates location permission or geofence boundary alterations.
class SimulateLocationChange extends AttendanceEvent {
  final LocationState state;
  final double distanceMeters;

  const SimulateLocationChange({
    required this.state,
    required this.distanceMeters,
  });

  @override
  List<Object?> get props => [state, distanceMeters];
}

/// Manually overrides attendance status in interactive preview mode.
class SimulateStatusChange extends AttendanceEvent {
  final AttendanceStatus status;

  const SimulateStatusChange(this.status);

  @override
  List<Object?> get props => [status];
}
