import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/attendance_summary.dart';

/// Container encapsulating monthly attendance records along with summary statistics.
class AttendanceMonthResult {
  final List<AttendanceRecord> records;
  final AttendanceMonthlySummary summary;

  const AttendanceMonthResult({required this.records, required this.summary});

  /// Factory constructor parsing from API response (supports both List and Map payloads).
  factory AttendanceMonthResult.fromData(
    dynamic rawData, [
    String month = '2026-11',
  ]) {
    if (rawData is List) {
      final records = rawData
          .whereType<Map>()
          .map((m) => AttendanceRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      final summary = AttendanceMonthlySummary.fromRecords(month, records);
      return AttendanceMonthResult(records: records, summary: summary);
    }
    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData);
      final rawRecords = map['records'] as List? ?? [];
      final records = rawRecords
          .whereType<Map>()
          .map((m) => AttendanceRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      final summaryMap = map['summary'] is Map
          ? Map<String, dynamic>.from(map['summary'] as Map)
          : null;
      final summary = summaryMap != null
          ? AttendanceMonthlySummary.fromJson(summaryMap)
          : AttendanceMonthlySummary.fromRecords(month, records);
      return AttendanceMonthResult(records: records, summary: summary);
    }
    return const AttendanceMonthResult(
      records: [],
      summary: AttendanceMonthlySummary.defaultSummary,
    );
  }

  /// Deserializer for map envelopes.
  factory AttendanceMonthResult.fromJson(Map<String, dynamic> json) =>
      AttendanceMonthResult.fromData(json);
}
