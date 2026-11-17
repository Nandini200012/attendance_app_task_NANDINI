import 'attendance_enums.dart';
import 'attendance_record.dart';

/// Monthly attendance aggregate metrics model returned by the attendance API.
class AttendanceMonthlySummary {
  final String month;
  final int totalDays;
  final int presentDays;
  final String totalWorkingHours;
  final String averageWorkingHours;

  const AttendanceMonthlySummary({
    required this.month,
    required this.totalDays,
    required this.presentDays,
    required this.totalWorkingHours,
    required this.averageWorkingHours,
  });

  /// Factory deserializer from JSON response.
  factory AttendanceMonthlySummary.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthlySummary(
      month: json['month'] as String? ?? '',
      totalDays: json['totalDays'] as int? ?? 0,
      presentDays: json['presentDays'] as int? ?? 0,
      totalWorkingHours: json['totalWorkingHours'] as String? ?? '0 hrs',
      averageWorkingHours: json['averageWorkingHours'] as String? ?? '0 hrs',
    );
  }

  /// Calculates aggregate monthly metrics directly from a list of records.
  factory AttendanceMonthlySummary.fromRecords(
    String month,
    List<AttendanceRecord> records,
  ) {
    if (records.isEmpty) {
      return AttendanceMonthlySummary(
        month: month,
        totalDays: 0,
        presentDays: 0,
        totalWorkingHours: '0 hrs',
        averageWorkingHours: '0 hrs',
      );
    }

    int present = 0;
    int totalMinutes = 0;

    for (final r in records) {
      final isPresent =
          r.status == AttendanceStatus.checkedIn ||
          r.status == AttendanceStatus.checkedOut;
      if (isPresent) {
        present++;
        totalMinutes += _parseDurationMinutes(r.workingDuration);
      }
    }

    final totalHours = (totalMinutes / 60).toStringAsFixed(1);
    final avgHours =
        present > 0 ? (totalMinutes / (present * 60)).toStringAsFixed(1) : '0';

    return AttendanceMonthlySummary(
      month: month,
      totalDays: records.length,
      presentDays: present,
      totalWorkingHours: '$totalHours hrs',
      averageWorkingHours: '$avgHours hrs',
    );
  }

  static int _parseDurationMinutes(String duration) {
    final regex = RegExp(r'(\d+)\s*h(?:ours?)?(?:\s*(\d+)\s*m)?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      return (hours * 60) + minutes;
    }
    return 0;
  }

  /// Serializes summary to JSON map.
  Map<String, dynamic> toJson() => {
    'month': month,
    'totalDays': totalDays,
    'presentDays': presentDays,
    'totalWorkingHours': totalWorkingHours,
    'averageWorkingHours': averageWorkingHours,
  };

  /// Fallback summary placeholder.
  static const AttendanceMonthlySummary defaultSummary =
      AttendanceMonthlySummary(
        month: '2026-11',
        totalDays: 18,
        presentDays: 12,
        totalWorkingHours: '73.2 hrs',
        averageWorkingHours: '6.1 hrs',
      );
}
