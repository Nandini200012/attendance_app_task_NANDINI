import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../models/attendance_enums.dart';
import '../models/leave_enums.dart';
import '../models/sync_operation.dart';

/// Reusable status badge with muted background tint, colored border, and text.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
    this.showDot = false,
  });

  factory StatusBadge.fromSyncOpStatus(SyncOpStatus s) {
    switch (s) {
      case SyncOpStatus.synced:
        return const StatusBadge(
          label: 'Synced',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle_rounded,
        );
      case SyncOpStatus.syncing:
        return const StatusBadge(
          label: 'Syncing...',
          foregroundColor: AppColors.tealAccent,
          backgroundColor: AppColors.tealAccentLight,
          icon: Icons.sync_rounded,
        );
      case SyncOpStatus.failed:
        return const StatusBadge(
          label: 'Failed',
          foregroundColor: AppColors.error,
          backgroundColor: AppColors.errorLight,
          icon: Icons.error_outline_rounded,
        );
      case SyncOpStatus.pending:
        return const StatusBadge(
          label: 'Pending Sync',
          foregroundColor: AppColors.pending,
          backgroundColor: AppColors.pendingLight,
          icon: Icons.schedule_rounded,
        );
    }
  }

  factory StatusBadge.fromSyncStatus(SyncStatus s) =>
      StatusBadge.fromSyncOpStatus(
        s == SyncStatus.synced
            ? SyncOpStatus.synced
            : s == SyncStatus.rejected
            ? SyncOpStatus.failed
            : SyncOpStatus.pending,
      );

  factory StatusBadge.fromLeaveStatus(LeaveStatus s) => s ==
          LeaveStatus.approved
      ? const StatusBadge(
          label: 'Approved',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_rounded,
        )
      : s == LeaveStatus.rejected
      ? const StatusBadge(
          label: 'Rejected',
          foregroundColor: AppColors.error,
          backgroundColor: AppColors.errorLight,
          icon: Icons.close_rounded,
        )
      : const StatusBadge(
          label: 'Pending',
          foregroundColor: AppColors.pending,
          backgroundColor: AppColors.pendingLight,
          icon: Icons.hourglass_top_rounded,
        );

  factory StatusBadge.fromAttendanceStatus(AttendanceStatus s) => s ==
          AttendanceStatus.checkedIn
      ? const StatusBadge(
          label: 'Checked In',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          showDot: true,
        )
      : s == AttendanceStatus.checkedOut
      ? const StatusBadge(
          label: 'Checked Out',
          foregroundColor: AppColors.secondaryText,
          backgroundColor: AppColors.border,
          showDot: true,
        )
      : const StatusBadge(
          label: 'Not Checked In',
          foregroundColor: AppColors.secondaryText,
          backgroundColor: AppColors.background,
          showDot: true,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: foregroundColor,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelBadge.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
