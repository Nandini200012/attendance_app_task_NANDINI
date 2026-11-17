import 'attendance_enums.dart';
import 'attendance_event.dart';

/// Supported offline queue operation types.
enum SyncOperationType {
  checkIn,
  checkOut,
  leaveApplication;

  String get label {
    switch (this) {
      case SyncOperationType.checkIn:
        return 'Attendance Check-in';
      case SyncOperationType.checkOut:
        return 'Attendance Check-out';
      case SyncOperationType.leaveApplication:
        return 'Leave Application';
    }
  }
}

/// Unified synchronization lifecycle status.
enum SyncOpStatus {
  pending,
  syncing,
  synced,
  failed;

  String get label {
    switch (this) {
      case SyncOpStatus.pending:
        return 'Pending';
      case SyncOpStatus.syncing:
        return 'Syncing';
      case SyncOpStatus.synced:
        return 'Synced';
      case SyncOpStatus.failed:
        return 'Failed';
    }
  }
}

/// Persistent record representing an offline action queued for synchronization.
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final SyncOpStatus status;
  final int retryCount;
  final String? errorMessage;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.status = SyncOpStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
  });

  bool get isAttendance =>
      type == SyncOperationType.checkIn || type == SyncOperationType.checkOut;

  String get displayId {
    if (id.startsWith('op-') && id.length >= 11) {
      return 'OP-${id.substring(3, 11).toUpperCase()}';
    }
    if (id.startsWith('evt-') && id.length >= 12) {
      return 'EVT-${id.substring(4, 12).toUpperCase()}';
    }
    if (id.startsWith('lev-') && id.length >= 12) {
      return 'LEV-${id.substring(4, 12).toUpperCase()}';
    }
    return id.toUpperCase();
  }

  AttendanceEvent toAttendanceEvent() {
    final evt = AttendanceEvent.fromJson(payload);
    final s = status == SyncOpStatus.synced
        ? SyncStatus.synced
        : status == SyncOpStatus.failed
        ? SyncStatus.rejected
        : SyncStatus.pending;
    return AttendanceEvent(
      eventId: id,
      eventType: type == SyncOperationType.checkOut
          ? AttendanceEventType.checkOut
          : AttendanceEventType.checkIn,
      timestamp: createdAt,
      latitude: evt.latitude,
      longitude: evt.longitude,
      distanceMeters: evt.distanceMeters,
      syncStatus: s,
      rejectionReason: errorMessage,
      deviceModel: evt.deviceModel,
      networkType: evt.networkType,
      verificationMethod: evt.verificationMethod,
      employeeId: evt.employeeId,
    );
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'] as String? ?? '',
    type: SyncOperationType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => SyncOperationType.checkIn,
    ),
    payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    status: SyncOpStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => SyncOpStatus.pending,
    ),
    retryCount: json['retryCount'] as int? ?? 0,
    errorMessage: json['errorMessage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'retryCount': retryCount,
    'errorMessage': errorMessage,
  };

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    SyncOpStatus? status,
    int? retryCount,
    String? errorMessage,
  }) => SyncOperation(
    id: id ?? this.id,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
