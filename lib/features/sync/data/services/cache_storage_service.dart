import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/employee_model.dart';
import '../../../../shared/models/leave_model.dart';

/// Manages Hive-based offline read-through caching for dashboard and history data.
class CacheStorageService {
  static const String cacheBoxName = 'rebs_app_cache';
  Box? _cacheBox;

  /// Initializes the cache box idempotently.
  Future<void> init() async {
    _cacheBox = await Hive.openBox(cacheBoxName);
  }

  /// Stores offline snapshot of employee profile.
  Future<void> cacheEmployee(EmployeeModel employee) async {
    await _cacheBox?.put('cached_employee', employee.toJson());
  }

  /// Reads cached snapshot of employee profile.
  EmployeeModel? getCachedEmployee() {
    final raw = _cacheBox?.get('cached_employee');
    if (raw is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  /// Stores offline snapshot of leave balance.
  Future<void> cacheLeaveBalance(LeaveBalance balance) async {
    await _cacheBox?.put('cached_leave_balance', balance.toJson());
  }

  /// Reads cached snapshot of leave balance.
  LeaveBalance? getCachedLeaveBalance() {
    final raw = _cacheBox?.get('cached_leave_balance');
    if (raw is Map) {
      return LeaveBalance.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  /// Stores offline snapshot of monthly attendance records.
  Future<void> cacheAttendanceRecords(
    String month,
    List<AttendanceRecord> records,
  ) async {
    final list = records.map((r) => r.toJson()).toList();
    await _cacheBox?.put('attendance_records_$month', list);
  }

  /// Reads cached snapshot of monthly attendance records.
  List<AttendanceRecord> getCachedAttendanceRecords(String month) {
    final raw = _cacheBox?.get('attendance_records_$month');
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => AttendanceRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    return [];
  }

  /// Stores offline snapshot of leave requests.
  Future<void> cacheLeaveRequests(List<LeaveRequest> requests) async {
    final list = requests.map((r) => r.toJson()).toList();
    await _cacheBox?.put('cached_leave_requests', list);
  }

  /// Reads cached snapshot of leave requests.
  List<LeaveRequest> getCachedLeaveRequests() {
    final raw = _cacheBox?.get('cached_leave_requests');
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => LeaveRequest.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    return [];
  }

  /// Wipes all cached snapshots for testing offline empty states.
  Future<void> clearAllCache() async {
    await _cacheBox?.clear();
  }
}
