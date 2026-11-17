/// Tracks remaining and allocated leave balances for an employee.
class LeaveBalance {
  final int casualAvailable;
  final int casualTotal;
  final int casualUsed;
  final int casualPending;
  final int sickAvailable;
  final int sickTotal;
  final int sickUsed;
  final int sickPending;

  const LeaveBalance({
    required this.casualAvailable,
    required this.casualTotal,
    this.casualUsed = 0,
    this.casualPending = 0,
    required this.sickAvailable,
    required this.sickTotal,
    this.sickUsed = 0,
    this.sickPending = 0,
  });

  int get totalAvailable => casualAvailable + sickAvailable;
  int get totalAllocated => casualTotal + sickTotal;
  int get totalUsed => casualUsed + sickUsed;
  int get totalPending => casualPending + sickPending;

  /// Factory deserializer supporting both snake_case API payloads and local cache.
  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['leave_type_breakdown'] ?? json['breakdown'];
    final breakdown = rawBreakdown is Map
        ? Map<String, dynamic>.from(rawBreakdown)
        : null;
    final casualRaw = breakdown?['casual'];
    final casual = casualRaw is Map
        ? Map<String, dynamic>.from(casualRaw)
        : null;
    final sickRaw = breakdown?['sick'];
    final sick = sickRaw is Map ? Map<String, dynamic>.from(sickRaw) : null;

    return LeaveBalance(
      casualAvailable: casual?['available'] as int? ?? 0,
      casualTotal: casual?['total'] as int? ?? 0,
      casualUsed: casual?['used'] as int? ?? 0,
      casualPending: casual?['pending'] as int? ?? 0,
      sickAvailable: sick?['available'] as int? ?? 0,
      sickTotal: sick?['total'] as int? ?? 0,
      sickUsed: sick?['used'] as int? ?? 0,
      sickPending: sick?['pending'] as int? ?? 0,
    );
  }

  /// Serializes balance object to JSON map.
  Map<String, dynamic> toJson() => {
    'total': totalAllocated,
    'used': totalUsed,
    'available': totalAvailable,
    'pending': totalPending,
    'leave_type_breakdown': {
      'casual': {
        'total': casualTotal,
        'used': casualUsed,
        'available': casualAvailable,
        'pending': casualPending,
      },
      'sick': {
        'total': sickTotal,
        'used': sickUsed,
        'available': sickAvailable,
        'pending': sickPending,
      },
    },
  };

  /// Empty zero-balance instance.
  static const LeaveBalance empty = LeaveBalance(
    casualAvailable: 0,
    casualTotal: 0,
    sickAvailable: 0,
    sickTotal: 0,
  );

  /// Sample mock balance for test setups.
  static const LeaveBalance mockBalance = LeaveBalance(
    casualAvailable: 3,
    casualTotal: 12,
    casualUsed: 4,
    casualPending: 8,
    sickAvailable: 5,
    sickTotal: 10,
    sickUsed: 5,
  );
}
