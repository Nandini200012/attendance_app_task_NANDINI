import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/attendance_summary.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/utils/attendance_record_merger.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

/// BLoC orchestrating attendance history queries, punch events, and geofence simulation.
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceBloc({required AttendanceRepository repository})
    : _repository = repository,
      super(const AttendanceInitial()) {
    on<LoadAttendanceMonth>(_onLoadAttendanceMonth);
    on<RecordPunch>(_onRecordPunch);
    on<SimulateLocationChange>(_onSimulateLocationChange);
    on<SimulateStatusChange>(_onSimulateStatusChange);
  }

  Future<void> _onLoadAttendanceMonth(
    LoadAttendanceMonth event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is! AttendanceLoaded) emit(const AttendanceLoading());
    try {
      final res = await _repository.getAttendanceHistory(event.month);
      final records = res.records;
      final now = DateTime.now();
      final todayRec = records.cast<AttendanceRecord?>().firstWhere(
            (r) => r != null && r.date.year == now.year &&
                r.date.month == now.month && r.date.day == now.day,
            orElse: () => null,
          );
      final pendingEvents = _repository.getPendingEvents();
      emit(AttendanceLoaded(
        records: records,
        summary: res.summary,
        selectedMonth: event.month,
        todayStatus: todayRec?.status ?? AttendanceStatus.notCheckedIn,
        lastPunchEvent: pendingEvents.isNotEmpty ? pendingEvents.last : null,
      ));
    } catch (_) {
      emit(AttendanceLoaded(
        records: const [],
        summary: AttendanceMonthlySummary.defaultSummary,
        selectedMonth: event.month,
        todayStatus: AttendanceStatus.notCheckedIn,
      ));
    }
  }

  Future<void> _onRecordPunch(
    RecordPunch event,
    Emitter<AttendanceState> emit,
  ) async {
    final current = state is AttendanceLoaded
        ? state as AttendanceLoaded
        : const AttendanceLoaded(
            records: [],
            summary: AttendanceMonthlySummary.defaultSummary,
            selectedMonth: '2026-11',
            todayStatus: AttendanceStatus.notCheckedIn,
          );

    // Guard against repeated taps & enforce check-out only after check-in
    if (event.eventType == AttendanceEventType.checkIn &&
        current.todayStatus == AttendanceStatus.checkedIn) {
      return;
    }
    if (event.eventType == AttendanceEventType.checkOut &&
        current.todayStatus != AttendanceStatus.checkedIn) {
      return;
    }

    final punchResult = await _repository.recordPunch(
      eventType: event.eventType,
      latitude: event.latitude,
      longitude: event.longitude,
      distanceMeters: event.distanceMeters,
    );

    final newStatus = event.eventType == AttendanceEventType.checkIn
        ? AttendanceStatus.checkedIn
        : AttendanceStatus.checkedOut;

    var updatedRecords = current.records;
    if (punchResult.syncStatus != SyncStatus.rejected) {
      updatedRecords = AttendanceRecordMerger.applyPunch(current.records, punchResult);
    }

    final updatedSummary = AttendanceMonthlySummary.fromRecords(
      current.selectedMonth,
      updatedRecords,
    );

    final note = punchResult.syncStatus == SyncStatus.synced
        ? '${event.eventType.label} recorded & verified by server.'
        : punchResult.syncStatus == SyncStatus.rejected
        ? 'Rejected: ${punchResult.rejectionReason}'
        : '${event.eventType.label} queued offline. Ready for sync.';

    emit(current.copyWith(
      records: updatedRecords,
      summary: updatedSummary,
      todayStatus: punchResult.syncStatus == SyncStatus.rejected
          ? current.todayStatus
          : newStatus,
      lastPunchEvent: punchResult,
      notificationMessage: note,
    ));
  }

  void _onSimulateLocationChange(
    SimulateLocationChange event,
    Emitter<AttendanceState> emit,
  ) {
    if (state is AttendanceLoaded) {
      final current = state as AttendanceLoaded;
      emit(current.copyWith(locationState: event.state, distanceMeters: event.distanceMeters));
    }
  }

  void _onSimulateStatusChange(
    SimulateStatusChange event,
    Emitter<AttendanceState> emit,
  ) {
    if (state is AttendanceLoaded) {
      final current = state as AttendanceLoaded;
      emit(current.copyWith(todayStatus: event.status));
    }
  }
}
