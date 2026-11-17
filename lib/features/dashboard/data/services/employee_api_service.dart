import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/employee_model.dart';

/// Service responsible for querying employee profile endpoints.
class EmployeeApiService {
  final ApiClient _client;

  EmployeeApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Fetches the authenticated employee profile from GET /employee/me.
  Future<EmployeeModel> getEmployeeProfile() async {
    final response = await _client.get<EmployeeModel>(
      ApiConstants.employeeMe,
      fromData: (rawData) {
        if (rawData is Map<String, dynamic>) {
          return EmployeeModel.fromJson(rawData);
        }
        throw const FormatException(
          'Expected JSON object for employee profile',
        );
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const FormatException('Empty employee profile payload received.');
  }
}
