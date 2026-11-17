import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_event.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/dashboard/data/services/employee_api_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';

void main() {
  group('Employee API Integration Tests', () {
    test(
      'EmployeeApiService parses GET /employee/me response correctly',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/employee/me');
          return http.Response(
            '{"StatusCode":6000,"message":{"title":"Employee Profile","body":"Success"},"data":{"id":"emp-001","employee_id":"EMP-2048","employee_name":"Nandini N","designation":"Senior Flutter Specialist","department":"Mobile Engineering","email":"nandini.n@rebs.io","phone_number":"+91 98765 43210","office_location":"REBS HQ (Bangalore Tech Park)","employee_status":"Active"}}',
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final service = EmployeeApiService(client: apiClient);

        final employee = await service.getEmployeeProfile();
        expect(employee.id, 'emp-001');
        expect(employee.name, 'Nandini N');
        expect(employee.employeeCode, 'EMP-2048');
        expect(employee.designation, 'Senior Flutter Specialist');
        expect(employee.department, 'Mobile Engineering');
        expect(employee.email, 'nandini.n@rebs.io');
      },
    );

    test(
      'DashboardBloc fetches employee data and emits DashboardLoaded',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            '{"StatusCode":6000,"message":{"title":"Success","body":"OK"},"data":{"id":"emp-001","employee_id":"EMP-2048","employee_name":"Nandini N","designation":"Senior Flutter Specialist","department":"Mobile Engineering","email":"nandini.n@rebs.io"}}',
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final employeeService = EmployeeApiService(client: apiClient);
        final storage = SyncStorageService();
        final repository = DashboardRepository(
          employeeService: employeeService,
          storageService: storage,
        );
        final bloc = DashboardBloc(repository: repository);

        expect(
          bloc.stream,
          emitsInOrder([
            isA<DashboardLoading>(),
            predicate<DashboardState>((state) {
              if (state is DashboardLoaded) {
                return state.data.employee.name == 'Nandini N' &&
                    state.data.employee.employeeCode == 'EMP-2048';
              }
              return false;
            }),
          ]),
        );

        bloc.add(const LoadDashboardData());
      },
    );
  });
}
