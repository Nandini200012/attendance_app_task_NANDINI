/// Types of employee leave supported by REBS HRMS.
enum LeaveType {
  casual('Casual Leave'),
  sick('Sick Leave');

  final String label;
  const LeaveType(this.label);
}

/// Approval lifecycle status for leave requests.
enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  final String label;
  const LeaveStatus(this.label);
}
