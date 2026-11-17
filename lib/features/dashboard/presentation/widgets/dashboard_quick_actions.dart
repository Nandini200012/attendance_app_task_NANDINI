import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Quick action shortcuts routing the employee directly to key app workflows.
class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onAttendanceTap;
  final VoidCallback onApplyLeaveTap;
  final VoidCallback onSyncTap;

  const DashboardQuickActions({
    super.key,
    required this.onAttendanceTap,
    required this.onApplyLeaveTap,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionItem(
            icon: Icons.fingerprint_rounded,
            label: 'Attendance',
            onTap: onAttendanceTap,
            iconColor: AppColors.tealAccent,
            bgColor: AppColors.tealAccentLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionItem(
            icon: Icons.edit_calendar_rounded,
            label: 'Apply Leave',
            onTap: onApplyLeaveTap,
            iconColor: AppColors.purpleAccent,
            bgColor: AppColors.purpleAccentLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionItem(
            icon: Icons.cloud_sync_rounded,
            label: 'Sync Center',
            onTap: onSyncTap,
            iconColor: AppColors.primaryAccent,
            bgColor: AppColors.primaryAccentLight,
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelBadge.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
