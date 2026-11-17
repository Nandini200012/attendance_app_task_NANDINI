/// Attendance operational status for the current day.
enum AttendanceStatus {
  notCheckedIn('Not Checked In'),
  checkedIn('Checked In'),
  checkedOut('Checked Out');

  final String label;
  const AttendanceStatus(this.label);
}

/// Synchronization lifecycle states for offline-first architecture.
enum SyncStatus {
  synced('Synced'),
  pending('Pending Sync'),
  rejected('Rejected');

  final String label;
  const SyncStatus(this.label);
}

/// Specific type of recorded attendance punch.
enum AttendanceEventType {
  checkIn('Check-in'),
  checkOut('Check-out');

  final String label;
  const AttendanceEventType(this.label);
}

/// Location permission and hardware accessibility states.
enum LocationState {
  granted('Within Allowed Radius'),
  outsideRadius('Outside 200m Radius'),
  gpsUnavailable('GPS Unavailable'),
  permissionDenied('Permission Denied'),
  permissionPermanentlyDenied('Permanently Denied');

  final String label;
  const LocationState(this.label);
}
