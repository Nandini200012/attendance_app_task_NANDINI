/// User-facing text constants and message definitions for REBS HRMS.
///
/// Centralizing strings ensures UI copy consistency across all 7 screens
/// and simplifies future localization.
abstract final class AppStrings {
  // Navigation
  static const String navHome = 'Home';
  static const String navAttendance = 'Attendance';
  static const String navLeave = 'Leave';
  static const String navSync = 'Sync';

  // Dashboard
  static const String dashboardGreeting = 'Welcome back,';
  static const String todayAttendance = "Today's Attendance";
  static const String quickActions = 'Quick Actions';
  static const String recentActivity = 'Recent Activity';
  static const String viewAllHistory = 'View Full History';

  // Attendance
  static const String checkIn = 'Check In';
  static const String checkOut = 'Check Out';
  static const String notCheckedIn = 'Not Checked In';
  static const String checkedIn = 'Checked In';
  static const String checkedOut = 'Checked Out';
  static const String workingDuration = 'Working Duration';
  static const String officeDistance = 'Office Distance';
  static const String allowedRadius = '200m Allowed Radius';
  static const String locationPermission = 'Location Permission';

  // Leave
  static const String casualLeave = 'Casual Leave';
  static const String sickLeave = 'Sick Leave';
  static const String applyLeave = 'Apply Leave';
  static const String leaveBalance = 'Leave Balance';
  static const String leaveHistory = 'Leave History';

  // Sync
  static const String syncNow = 'Sync Now';
  static const String syncManagement = 'Sync Management';
  static const String lastSynced = 'Last Synced';
  static const String pendingEvents = 'Pending Events';
  static const String syncedEvents = 'Synced Events';
  static const String rejectedEvents = 'Rejected Events';

  // Location / Geofence states
  static const String outsideRadiusMsg =
      'You are outside the 200m office perimeter. Check-in is restricted.';
  static const String gpsUnavailableMsg =
      'GPS signal unavailable. Please ensure location services are enabled.';
  static const String permissionDeniedMsg =
      'Location permission denied. Grant permission to record attendance.';
  static const String permissionPermanentMsg =
      'Location permission permanently denied. Open app settings to enable.';
}
