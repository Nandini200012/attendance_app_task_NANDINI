import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/leave_model.dart';

/// Service interfacing with leave balances and leave request submission endpoints.
class LeaveApiService {
  final ApiClient _client;

  LeaveApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Retrieves leave quotas and remaining balances.
  Future<LeaveBalance> getLeaveBalance() async {
    final response = await _client.get<LeaveBalance>(
      ApiConstants.leaveBalance,
      fromData: (rawData) {
        if (rawData is Map<String, dynamic>) {
          return LeaveBalance.fromJson(rawData);
        }
        throw const FormatException('Expected JSON map for leave balance');
      },
    );

    if (response.data != null) return response.data!;
    throw const FormatException('Empty leave balance payload received.');
  }

  /// Retrieves list of submitted leave requests.
  Future<List<LeaveRequest>> getLeaveRequests() async {
    final response = await _client.get<List<LeaveRequest>>(
      ApiConstants.leaveRequests,
      fromData: (rawData) {
        if (rawData is List<dynamic>) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map(LeaveRequest.fromJson)
              .toList();
        }
        throw const FormatException('Expected JSON list for leave requests');
      },
    );

    return response.data ?? const [];
  }

  /// Submits a new leave application to the remote server.
  Future<LeaveRequest> submitLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required int numberOfDays,
    required String reason,
  }) async {
    final typeStr = leaveType == LeaveType.sick ? 'sick' : 'casual';
    final sDate = startDate.toIso8601String().substring(0, 10);
    final eDate = endDate.toIso8601String().substring(0, 10);
    final payload = {
      'leave_type': typeStr,
      'leaveType': typeStr,
      'start_date': sDate,
      'startDate': sDate,
      'end_date': eDate,
      'endDate': eDate,
      'number_of_days': numberOfDays,
      'numberOfDays': numberOfDays,
      'reason': reason,
    };

    final response = await _client.post<LeaveRequest>(
      ApiConstants.leaveRequests,
      body: payload,
      fromData: (rawData) {
        if (rawData is Map<String, dynamic>) {
          return LeaveRequest.fromJson(rawData);
        }
        throw const FormatException(
          'Expected JSON map for created leave request',
        );
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const FormatException('Failed to parse submitted leave response');
  }
}
