import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/employee_model.dart';
import '../../../../shared/models/leave_model.dart';

/// Aggregated data container driving Screen 1 (Employee Dashboard).
class DashboardData {
  final EmployeeModel employee;
  final AttendanceStatus todayStatus;
  final String checkInTime;
  final String checkOutTime;
  final String workingDuration;
  final LeaveBalance leaveBalance;
  final List<AttendanceRecord> recentRecords;
  final int pendingSyncCount;
  final bool isOffline;

  const DashboardData({
    required this.employee,
    required this.todayStatus,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingDuration,
    required this.leaveBalance,
    required this.recentRecords,
    required this.pendingSyncCount,
    required this.isOffline,
  });

  /// Fallback baseline instance when offline without cache.
  static final DashboardData fallback = DashboardData(
    employee: EmployeeModel.mockEmployee,
    todayStatus: AttendanceStatus.checkedIn,
    checkInTime: '09:15 AM',
    checkOutTime: '--:--',
    workingDuration: '7h 45m',
    leaveBalance: LeaveBalance.mockBalance,
    recentRecords: const [],
    pendingSyncCount: 2,
    isOffline: false,
  );
}
