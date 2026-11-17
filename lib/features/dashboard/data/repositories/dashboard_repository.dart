import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/models/employee_model.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../attendance/data/services/attendance_api_service.dart';
import '../../../attendance/data/utils/attendance_record_merger.dart';
import '../../../leave/data/services/leave_api_service.dart';
import '../../../sync/data/services/cache_storage_service.dart';
import '../../../sync/data/services/sync_storage_service.dart';
import '../models/dashboard_data.dart';
import '../services/employee_api_service.dart';

/// Repository orchestrating data aggregation and Hive caching for the dashboard.
class DashboardRepository {
  final EmployeeApiService _employeeService;
  final AttendanceApiService _attendanceService;
  final LeaveApiService _leaveService;
  final SyncStorageService _storageService;
  final CacheStorageService _cacheService;

  DashboardRepository({
    EmployeeApiService? employeeService,
    AttendanceApiService? attendanceService,
    LeaveApiService? leaveService,
    required SyncStorageService storageService,
    CacheStorageService? cacheService,
  }) : _employeeService = employeeService ?? EmployeeApiService(),
       _attendanceService = attendanceService ?? AttendanceApiService(),
       _leaveService = leaveService ?? LeaveApiService(),
       _storageService = storageService,
       _cacheService = cacheService ?? CacheStorageService();

  /// Fetches unified dashboard payload combining employee, attendance, and leave info.
  Future<DashboardData> getDashboardData() async {
    EmployeeModel? employee;
    LeaveBalance? leaveBalance;
    List<AttendanceRecord>? records;
    bool isOffline = false;

    try {
      employee = await _employeeService.getEmployeeProfile();
      await _cacheService.cacheEmployee(employee);
    } catch (_) {
      isOffline = true;
      employee = _cacheService.getCachedEmployee();
    }

    try {
      leaveBalance = await _leaveService.getLeaveBalance();
      await _cacheService.cacheLeaveBalance(leaveBalance);
    } catch (_) {
      isOffline = true;
      leaveBalance = _cacheService.getCachedLeaveBalance();
    }

    try {
      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final res = await _attendanceService.getAttendance(month: monthStr);
      records = res.records;
      if (records.isNotEmpty) {
        await _cacheService.cacheAttendanceRecords(monthStr, records);
      }
    } catch (_) {
      isOffline = true;
      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      records = _cacheService.getCachedAttendanceRecords(monthStr);
    }

    if (employee == null) {
      throw const NetworkException(
        'No internet connection and no cached data available.',
      );
    }

    final localEvents = _storageService.getPendingEvents() +
        _storageService.getSyncedEvents();
    records = AttendanceRecordMerger.mergeEvents(records, localEvents);

    leaveBalance ??= LeaveBalance.empty;

    final todayRec = records.isNotEmpty ? records.first : null;
    final checkInStr = todayRec?.checkInTime != null
        ? DateFormatter.formatTime(todayRec!.checkInTime!)
        : '--:--';
    final checkOutStr = (todayRec?.status == AttendanceStatus.checkedIn)
        ? '--:--'
        : (todayRec?.checkOutTime != null
            ? DateFormatter.formatTime(todayRec!.checkOutTime!)
            : '--:--');

    final pendingCount = _storageService.getPendingEvents().length;

    return DashboardData(
      employee: employee,
      todayStatus: todayRec?.status ?? AttendanceStatus.notCheckedIn,
      checkInTime: checkInStr,
      checkOutTime: checkOutStr,
      workingDuration: todayRec?.workingDuration ?? '--',
      leaveBalance: leaveBalance,
      recentRecords: records.take(5).toList(),
      pendingSyncCount: pendingCount,
      isOffline: isOffline,
    );
  }
}
