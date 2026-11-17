import 'leave_enums.dart';

/// Represents an individual leave application submitted by an employee.
class LeaveRequest {
  final String id;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int requestedDays;
  final DateTime submissionDate;
  final LeaveStatus status;
  final String reason;
  final String? rejectionReason;
  final String? employeeId;

  const LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    required this.submissionDate,
    required this.status,
    required this.reason,
    this.rejectionReason,
    this.employeeId,
  });

  /// Factory constructor to parse leave request from JSON map.
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final typeStr = json['leaveType'] as String? ??
        json['leave_type'] as String? ??
        'casual';
    final statusStr = json['status'] as String? ?? 'pending';

    return LeaveRequest(
      id: json['id'] as String? ??
          json['requestId'] as String? ??
          json['request_id'] as String? ??
          '',
      leaveType: typeStr.toLowerCase().contains('sick')
          ? LeaveType.sick
          : LeaveType.casual,
      startDate: DateTime.tryParse(
            json['startDate'] as String? ?? json['start_date'] as String? ?? '',
          ) ??
          DateTime.now(),
      endDate: DateTime.tryParse(
            json['endDate'] as String? ?? json['end_date'] as String? ?? '',
          ) ??
          DateTime.now(),
      requestedDays: json['requestedDays'] as int? ??
          json['numberOfDays'] as int? ??
          json['number_of_days'] as int? ??
          1,
      submissionDate: DateTime.tryParse(
            json['appliedDate'] as String? ??
                json['applied_date'] as String? ??
                json['submissionDate'] as String? ??
                '',
          ) ??
          DateTime.now(),
      status: _parseLeaveStatus(statusStr),
      reason: json['reason'] as String? ?? '',
      rejectionReason: json['rejectionReason'] as String? ??
          json['rejection_reason'] as String?,
      employeeId:
          json['employeeId'] as String? ?? json['employee_id'] as String?,
    );
  }

  /// Serializes leave request to JSON map for submission or cache.
  Map<String, dynamic> toJson() => {
    'id': id,
    'leaveType': leaveType == LeaveType.sick ? 'sick' : 'casual',
    'startDate': startDate.toIso8601String().substring(0, 10),
    'endDate': endDate.toIso8601String().substring(0, 10),
    'numberOfDays': requestedDays,
    'reason': reason,
    'status': status.name,
    'appliedDate': submissionDate.toIso8601String(),
    'rejectionReason': rejectionReason,
    'employeeId': employeeId,
  };

  static LeaveStatus _parseLeaveStatus(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'pending':
      default:
        return LeaveStatus.pending;
    }
  }

  /// Mock sample requests for fallback.
  static List<LeaveRequest> get mockRequests => [
    LeaveRequest(
      id: 'LEV-2026-004',
      leaveType: LeaveType.casual,
      startDate: DateTime(2026, 11, 24),
      endDate: DateTime(2026, 11, 26),
      requestedDays: 3,
      submissionDate: DateTime(2026, 11, 14),
      status: LeaveStatus.pending,
      reason: 'Attending annual family gathering and personal travel.',
    ),
    LeaveRequest(
      id: 'LEV-2026-003',
      leaveType: LeaveType.sick,
      startDate: DateTime(2026, 11, 4),
      endDate: DateTime(2026, 11, 5),
      requestedDays: 2,
      submissionDate: DateTime(2026, 11, 3),
      status: LeaveStatus.approved,
      reason: 'Severe seasonal flu and prescribed medical bed rest.',
    ),
  ];
}
