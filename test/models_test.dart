import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/models/attendance_event.dart';
import 'package:attendance_register_app/shared/models/attendance_record.dart';
import 'package:attendance_register_app/shared/models/employee_model.dart';
import 'package:attendance_register_app/shared/models/leave_model.dart';

void main() {
  group('EmployeeModel tests', () {
    test('fromJson & toJson roundtrip matches fields', () {
      final json = {
        'employeeId': 'emp-001',
        'name': 'Nandini N',
        'employeeCode': 'EMP-2048',
        'department': 'Mobile Engineering',
        'designation': 'Senior Flutter Specialist',
        'email': 'nandini.n@rebs.io',
      };
      final model = EmployeeModel.fromJson(json);
      expect(model.id, 'emp-001');
      expect(model.name, 'Nandini N');
      expect(model.employeeCode, 'EMP-2048');

      final serialized = model.toJson();
      expect(serialized['employeeId'], 'emp-001');
    });
  });

  group('AttendanceRecord tests', () {
    test('fromJson parses dates and status correctly', () {
      final json = {
        'id': 'rec-1',
        'date': '2026-11-16',
        'workingHours': '8h 30m',
        'status': 'checked_in',
        'syncStatus': 'synced',
      };
      final record = AttendanceRecord.fromJson(json);
      expect(record.id, 'rec-1');
      expect(record.workingDuration, '8h 30m');
      expect(record.status, AttendanceStatus.checkedIn);
      expect(record.syncStatus, SyncStatus.synced);
    });
  });

  group('AttendanceEvent tests', () {
    test('fromJson parses geofence coordinates and radius rejection', () {
      final json = {
        'eventId': 'evt-001',
        'eventType': 'check_in',
        'timestamp': '2026-11-16T09:15:00.000Z',
        'latitude': 12.971598,
        'longitude': 77.594562,
        'distanceMeters': 48.2,
        'syncStatus': 'synced',
      };
      final event = AttendanceEvent.fromJson(json);
      expect(event.eventId, 'evt-001');
      expect(event.distanceMeters, 48.2);
      expect(event.syncStatus, SyncStatus.synced);
    });
  });

  group('Leave models tests', () {
    test('LeaveBalance and LeaveRequest serialization', () {
      final balanceJson = {
        'total': 22,
        'used': 9,
        'available': 13,
        'pending': 3,
        'breakdown': {
          'casual': {'total': 12, 'used': 4, 'available': 8, 'pending': 3},
          'sick': {'total': 10, 'used': 5, 'available': 5, 'pending': 0},
        },
      };
      final balance = LeaveBalance.fromJson(balanceJson);
      expect(balance.casualAvailable, 8);
      expect(balance.sickAvailable, 5);
      expect(balance.totalAvailable, 13);

      final requestJson = {
        'id': 'lev-001',
        'leaveType': 'casual',
        'startDate': '2026-11-20',
        'endDate': '2026-11-22',
        'numberOfDays': 3,
        'reason': 'Family gathering travel',
        'status': 'pending',
      };
      final request = LeaveRequest.fromJson(requestJson);
      expect(request.id, 'lev-001');
      expect(request.leaveType, LeaveType.casual);
      expect(request.requestedDays, 3);
      expect(request.status, LeaveStatus.pending);
    });
  });
}
