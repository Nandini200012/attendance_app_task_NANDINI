import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_record.dart';

/// Utilities to merge local check-in and check-out punches into attendance history.
class AttendanceRecordMerger {
  /// Applies a single punch event to a list of existing attendance records.
  static List<AttendanceRecord> applyPunch(
    List<AttendanceRecord> records,
    AttendanceEvent punch,
  ) {
    final date = punch.timestamp;

    if (punch.eventType == AttendanceEventType.checkIn) {
      final activeIndex = records.indexWhere((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day &&
          r.status == AttendanceStatus.checkedIn);

      if (activeIndex != -1) {
        final existing = records[activeIndex];
        final updated = existing.copyWith(
          checkInTime: punch.timestamp,
          clearCheckOut: true,
          status: AttendanceStatus.checkedIn,
          syncStatus: punch.syncStatus,
          latitude: punch.latitude,
          longitude: punch.longitude,
          distanceMeters: punch.distanceMeters,
        );
        final list = List<AttendanceRecord>.from(records);
        list[activeIndex] = updated;
        return list;
      }
      final newRec = AttendanceRecord(
        id: punch.eventId,
        date: DateTime(date.year, date.month, date.day),
        checkInTime: punch.timestamp,
        workingDuration: '0h 00m',
        status: AttendanceStatus.checkedIn,
        syncStatus: punch.syncStatus,
        latitude: punch.latitude,
        longitude: punch.longitude,
        distanceMeters: punch.distanceMeters,
      );
      return [newRec, ...records];
    } else {
      // Check out punch
      final activeIndex = records.indexWhere((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day &&
          r.status == AttendanceStatus.checkedIn);
      final targetIndex = activeIndex != -1
          ? activeIndex
          : records.indexWhere((r) =>
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day);

      if (targetIndex != -1) {
        final existing = records[targetIndex];
        String duration = existing.workingDuration;
        if (existing.checkInTime != null) {
          final diff = punch.timestamp.difference(existing.checkInTime!);
          final h = diff.inHours;
          final m = diff.inMinutes.remainder(60);
          duration = '${h}h ${m.toString().padLeft(2, '0')}m';
        }
        final updated = existing.copyWith(
          checkOutTime: punch.timestamp,
          workingDuration: duration,
          status: AttendanceStatus.checkedOut,
          syncStatus: punch.syncStatus,
        );
        final list = List<AttendanceRecord>.from(records);
        list[targetIndex] = updated;
        return list;
      }
      final newRec = AttendanceRecord(
        id: punch.eventId,
        date: DateTime(date.year, date.month, date.day),
        checkOutTime: punch.timestamp,
        workingDuration: '0h 00m',
        status: AttendanceStatus.checkedOut,
        syncStatus: punch.syncStatus,
        latitude: punch.latitude,
        longitude: punch.longitude,
        distanceMeters: punch.distanceMeters,
      );
      return [newRec, ...records];
    }
  }

  /// Merges multiple local events (pending or synced) into a list of records.
  static List<AttendanceRecord> mergeEvents(
    List<AttendanceRecord> baseRecords,
    List<AttendanceEvent> events,
  ) {
    var result = List<AttendanceRecord>.from(baseRecords);
    final sortedEvents = List<AttendanceEvent>.from(events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final ev in sortedEvents) {
      if (ev.syncStatus != SyncStatus.rejected) {
        result = applyPunch(result, ev);
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}

