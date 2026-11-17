import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const sampleJson = '''
{
  "StatusCode": 6000,
  "message": {
    "title": "Attendance Records",
    "body": "Retrieved 18 records successfully"
  },
  "data": [
    {"id":"REC-20261128","employee_id":"emp-001","attendance_date":"2026-11-28","check_in_time":"2026-11-28T09:00:00.000Z","check_out_time":null,"working_hours":"0h 00m","attendance_status":"Checked In","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-20261120","employee_id":"emp-001","attendance_date":"2026-11-20","check_in_time":"2026-11-20T09:05:00.000Z","check_out_time":null,"working_hours":"0h 00m","attendance_status":"Checked In","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1116","employee_id":"emp-001","attendance_date":"2026-11-16","check_in_time":"2026-11-16T09:15:30.000Z","check_out_time":"2026-11-16T14:15:00.000Z","working_hours":"4h 59m","attendance_status":"Checked Out","location":"REBS HQ (48m from perimeter)","sync_status":"Synced"},
    {"id":"REC-2026-1115","employee_id":"emp-001","attendance_date":"2026-11-15","check_in_time":"2026-11-15T09:02:14.000Z","check_out_time":"2026-11-15T18:15:20.000Z","working_hours":"9h 13m","attendance_status":"Checked Out","location":"REBS HQ (52m from perimeter)","sync_status":"Synced"},
    {"id":"REC-2026-1114","employee_id":"emp-001","attendance_date":"2026-11-14","check_in_time":"2026-11-14T08:55:00.000Z","check_out_time":"2026-11-14T17:45:10.000Z","working_hours":"8h 50m","attendance_status":"Checked Out","location":"REBS HQ (34m from perimeter)","sync_status":"Synced"},
    {"id":"REC-2026-1113","employee_id":"emp-001","attendance_date":"2026-11-13","check_in_time":"2026-11-13T09:30:12.000Z","check_out_time":"2026-11-13T15:00:22.000Z","working_hours":"5h 30m","attendance_status":"Checked Out","location":"REBS HQ (62m from perimeter)","sync_status":"Synced"},
    {"id":"REC-2026-1112","employee_id":"emp-001","attendance_date":"2026-11-12","check_in_time":"2026-11-12T10:10:05.000Z","check_out_time":null,"working_hours":"0h 00m","attendance_status":"Checked In","location":"Outside Radius (468m from perimeter)","sync_status":"Rejected"},
    {"id":"REC-2026-1111","employee_id":"emp-001","attendance_date":"2026-11-11","check_in_time":"2026-11-11T09:00:00.000Z","check_out_time":"2026-11-11T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1110","employee_id":"emp-001","attendance_date":"2026-11-10","check_in_time":"2026-11-10T09:00:00.000Z","check_out_time":"2026-11-10T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1109","employee_id":"emp-001","attendance_date":"2026-11-09","check_in_time":"2026-11-09T09:00:00.000Z","check_out_time":"2026-11-09T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1108","employee_id":"emp-001","attendance_date":"2026-11-08","check_in_time":null,"check_out_time":null,"working_hours":"0h 00m","attendance_status":"Weekend","location":"Weekly Off","sync_status":"Synced"},
    {"id":"REC-2026-1107","employee_id":"emp-001","attendance_date":"2026-11-07","check_in_time":null,"check_out_time":null,"working_hours":"0h 00m","attendance_status":"Weekend","location":"Weekly Off","sync_status":"Synced"},
    {"id":"REC-2026-1106","employee_id":"emp-001","attendance_date":"2026-11-06","check_in_time":"2026-11-06T09:00:00.000Z","check_out_time":"2026-11-06T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1105","employee_id":"emp-001","attendance_date":"2026-11-05","check_in_time":null,"check_out_time":null,"working_hours":"0h 00m","attendance_status":"On Leave","location":"Approved Sick Leave","sync_status":"Synced"},
    {"id":"REC-2026-1104","employee_id":"emp-001","attendance_date":"2026-11-04","check_in_time":null,"check_out_time":null,"working_hours":"0h 00m","attendance_status":"On Leave","location":"Approved Sick Leave","sync_status":"Synced"},
    {"id":"REC-2026-1103","employee_id":"emp-001","attendance_date":"2026-11-03","check_in_time":"2026-11-03T09:00:00.000Z","check_out_time":"2026-11-03T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1102","employee_id":"emp-001","attendance_date":"2026-11-02","check_in_time":"2026-11-02T09:00:00.000Z","check_out_time":"2026-11-02T18:00:00.000Z","working_hours":"9h 00m","attendance_status":"Checked Out","location":"REBS HQ","sync_status":"Synced"},
    {"id":"REC-2026-1101","employee_id":"emp-001","attendance_date":"2026-11-01","check_in_time":null,"check_out_time":null,"working_hours":"0h 00m","attendance_status":"Weekend","location":"Weekly Off","sync_status":"Synced"}
  ]
}
''';

  group('GET /attendance JSON Parsing Tests', () {
    test('parses all 18 records without FormatException or ServerException',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/attendance');
        expect(request.url.queryParameters['month'], '2026-11');
        return http.Response(
          sampleJson,
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AttendanceApiService(
        client: ApiClient(client: mockClient),
      );
      final result = await service.getAttendance(month: '2026-11');

      // 1. Verify all 18 records parsed
      expect(result.records.length, 18);

      // 2. First record: Checked in, check_out_time is null
      final r0 = result.records[0];
      expect(r0.id, 'REC-20261128');
      expect(r0.status, AttendanceStatus.checkedIn);
      expect(r0.checkInTime, isNotNull);
      expect(r0.checkOutTime, isNull);
      expect(r0.workingDuration, '0h 00m');
      expect(r0.syncStatus, SyncStatus.synced);

      // 3. Third record: Checked out, both times present
      final r2 = result.records[2];
      expect(r2.id, 'REC-2026-1116');
      expect(r2.status, AttendanceStatus.checkedOut);
      expect(r2.checkInTime, DateTime.parse('2026-11-16T09:15:30.000Z'));
      expect(r2.checkOutTime, DateTime.parse('2026-11-16T14:15:00.000Z'));
      expect(r2.workingDuration, '4h 59m');
      expect(r2.syncStatus, SyncStatus.synced);

      // 4. Record 6: Rejected sync status
      final r6 = result.records[6];
      expect(r6.id, 'REC-2026-1112');
      expect(r6.syncStatus, SyncStatus.rejected);

      // 5. Record 10: Weekend, both in/out are null
      final r10 = result.records[10];
      expect(r10.id, 'REC-2026-1108');
      expect(r10.checkInTime, isNull);
      expect(r10.checkOutTime, isNull);
      expect(r10.status, AttendanceStatus.notCheckedIn);

      // 6. Record 13: On Leave, both in/out are null
      final r13 = result.records[13];
      expect(r13.id, 'REC-2026-1105');
      expect(r13.checkInTime, isNull);
      expect(r13.checkOutTime, isNull);
      expect(r13.status, AttendanceStatus.notCheckedIn);

      // 7. Verify calculated summary
      expect(result.summary.totalDays, 18);
      expect(result.summary.presentDays, 13);
      expect(result.summary.totalWorkingHours, isNotEmpty);
      expect(result.summary.averageWorkingHours, isNotEmpty);
    });
  });
}
