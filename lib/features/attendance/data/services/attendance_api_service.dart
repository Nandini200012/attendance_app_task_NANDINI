import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_summary.dart';
import '../models/attendance_month_result.dart';

/// Service interfacing with attendance registers and punch event endpoints.
class AttendanceApiService {
  final ApiClient _client;

  AttendanceApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Retrieves monthly records and metrics for the given YYYY-MM string.
  Future<AttendanceMonthResult> getAttendance({String? month}) async {
    final query = month != null ? {'month': month} : null;
    final response = await _client.get<AttendanceMonthResult>(
      ApiConstants.attendance,
      queryParams: query,
      fromData: (rawData) =>
          AttendanceMonthResult.fromData(rawData, month ?? '2026-11'),
    );

    return response.data ??
        const AttendanceMonthResult(
          records: [],
          summary: AttendanceMonthlySummary.defaultSummary,
        );
  }

  /// Transmits a check-in or check-out telemetry event to the backend.
  Future<Map<String, dynamic>> postAttendanceEvent(
    AttendanceEvent event,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.attendanceEvents,
      body: event.toJson(),
      fromData: (rawData) =>
          rawData is Map<String, dynamic> ? rawData : <String, dynamic>{},
    );

    return response.data ?? {};
  }
}
