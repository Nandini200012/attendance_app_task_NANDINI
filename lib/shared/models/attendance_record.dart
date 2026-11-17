import 'attendance_enums.dart';

/// Represents a daily consolidated attendance record for history and dashboard views.
class AttendanceRecord {
  final String id;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String workingDuration;
  final AttendanceStatus status;
  final SyncStatus syncStatus;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.workingDuration,
    required this.status,
    required this.syncStatus,
    this.latitude,
    this.longitude,
    this.distanceMeters,
  });

  /// Factory constructor to parse record from API JSON object safely.
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final statusRaw =
        json['attendance_status'] as String? ??
        json['status'] as String? ??
        '';
    final syncRaw =
        json['sync_status'] as String? ?? json['syncStatus'] as String? ?? '';
    final dateRaw =
        json['attendance_date'] as String? ?? json['date'] as String? ?? '';
    final inRaw =
        json['check_in_time'] as String? ?? json['checkInTime'] as String?;
    final outRaw =
        json['check_out_time'] as String? ?? json['checkOutTime'] as String?;
    final loc = json['location'];
    final locMap = loc is Map<String, dynamic> ? loc : null;

    return AttendanceRecord(
      id: json['id'] as String? ?? json['record_id'] as String? ?? '',
      date: DateTime.tryParse(dateRaw) ?? DateTime.now(),
      checkInTime: inRaw != null ? DateTime.tryParse(inRaw) : null,
      checkOutTime: outRaw != null ? DateTime.tryParse(outRaw) : null,
      workingDuration:
          json['working_hours'] as String? ??
          json['workingHours'] as String? ??
          json['workingDuration'] as String? ??
          '0h 00m',
      status: _parseAttendanceStatus(statusRaw),
      syncStatus: _parseSyncStatus(syncRaw),
      latitude: (locMap?['latitude'] as num?)?.toDouble(),
      longitude: (locMap?['longitude'] as num?)?.toDouble(),
      distanceMeters: (locMap?['distanceMeters'] as num?)?.toDouble(),
    );
  }

  /// Serializes record to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'attendance_date': date.toIso8601String().substring(0, 10),
    'date': date.toIso8601String().substring(0, 10),
    'check_in_time': checkInTime?.toIso8601String(),
    'checkInTime': checkInTime?.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'working_hours': workingDuration,
    'workingHours': workingDuration,
    'attendance_status': _statusToString(status),
    'status': _statusToString(status),
    'sync_status': _syncToString(syncStatus),
    'syncStatus': _syncToString(syncStatus),
  };

  static AttendanceStatus _parseAttendanceStatus(String value) {
    final v = value.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (v.contains('checkedin') || v == 'in') return AttendanceStatus.checkedIn;
    if (v.contains('checkedout') || v == 'out') {
      return AttendanceStatus.checkedOut;
    }
    return AttendanceStatus.notCheckedIn;
  }

  static String _statusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.checkedIn:
        return 'Checked In';
      case AttendanceStatus.checkedOut:
        return 'Checked Out';
      case AttendanceStatus.notCheckedIn:
        return 'Not Checked In';
    }
  }

  static SyncStatus _parseSyncStatus(String value) {
    final v = value.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (v.contains('synced')) return SyncStatus.synced;
    if (v.contains('rejected')) return SyncStatus.rejected;
    if (v.contains('pending')) return SyncStatus.pending;
    return SyncStatus.synced;
  }

  static String _syncToString(SyncStatus status) => status.label;

  /// Creates a copy of this record with given fields updated.
  AttendanceRecord copyWith({
    String? id,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? workingDuration,
    AttendanceStatus? status,
    SyncStatus? syncStatus,
    double? latitude,
    double? longitude,
    double? distanceMeters,
    bool clearCheckOut = false,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: clearCheckOut ? null : (checkOutTime ?? this.checkOutTime),
      workingDuration: workingDuration ?? this.workingDuration,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }
}
