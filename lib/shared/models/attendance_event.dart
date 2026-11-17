import 'attendance_enums.dart';

/// Detailed attendance punch event with geofence and telemetry metadata.
class AttendanceEvent {
  final String eventId;
  final AttendanceEventType eventType;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final SyncStatus syncStatus;
  final String? rejectionReason;
  final String deviceModel;
  final String networkType;
  final String verificationMethod;
  final String? employeeId;

  const AttendanceEvent({
    required this.eventId,
    required this.eventType,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.syncStatus,
    this.rejectionReason,
    this.deviceModel = 'Pixel 8 Pro (Android 14)',
    this.networkType = 'Wi-Fi (REBS-Corp-5G)',
    this.verificationMethod = 'GPS Geofence (200m Perimeter)',
    this.employeeId,
  });

  /// Compact human-readable identifier for list tiles (e.g. EVT-17F96D4D).
  String get displayId {
    if (eventId.startsWith('evt-') && eventId.length >= 12) {
      return 'EVT-${eventId.substring(4, 12).toUpperCase()}';
    }
    return eventId.replaceFirst('EVT-2026-', 'EVT-');
  }

  /// Factory constructor to parse event from JSON map.
  factory AttendanceEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['event_type'] as String? ??
        json['eventType'] as String? ??
        'check_in';
    final syncStr = json['sync_status'] as String? ??
        json['syncStatus'] as String? ??
        'pending';

    return AttendanceEvent(
      eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
      eventType: typeStr == 'check_out' || typeStr == 'checkOut'
          ? AttendanceEventType.checkOut
          : AttendanceEventType.checkIn,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters:
          (json['distanceMeters'] as num?)?.toDouble() ??
          (json['location']?['distanceMeters'] as num?)?.toDouble() ??
          0.0,
      syncStatus: syncStr == 'synced'
          ? SyncStatus.synced
          : syncStr == 'rejected'
          ? SyncStatus.rejected
          : SyncStatus.pending,
      rejectionReason: json['rejection_reason'] as String? ??
          json['rejectionReason'] as String?,
      deviceModel: json['device_info'] as String? ??
          json['deviceModel'] as String? ??
          'Pixel 8 Pro (Android 14)',
      networkType: json['networkType'] as String? ?? 'Wi-Fi (REBS-Corp-5G)',
      verificationMethod: json['verificationMethod'] as String? ??
          'GPS Geofence (200m Perimeter)',
      employeeId:
          json['employee_id'] as String? ?? json['employeeId'] as String?,
    );
  }

  /// Serializes instance to JSON map for API dispatch or local storage.
  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'event_id': eventId,
    'eventType': eventType == AttendanceEventType.checkOut
        ? 'check_out'
        : 'check_in',
    'event_type': eventType == AttendanceEventType.checkOut
        ? 'check_out'
        : 'check_in',
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'distanceMeters': distanceMeters,
    'syncStatus': syncStatus.name,
    'sync_status': syncStatus.name,
    'rejectionReason': rejectionReason,
    'deviceModel': deviceModel,
    'device_info': deviceModel,
    'networkType': networkType,
    'verificationMethod': verificationMethod,
    'employeeId': employeeId ?? 'emp-001',
    'employee_id': employeeId ?? 'emp-001',
    'location': 'REBS HQ (Bangalore Tech Park)',
  };
}
