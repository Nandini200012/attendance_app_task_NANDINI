import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card summarizing available casual and sick leave balances on the dashboard.
class DashboardLeaveCard extends StatelessWidget {
  final LeaveBalance balance;
  final VoidCallback onTap;

  const DashboardLeaveCard({
    super.key,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      size: 16,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Leave Quota', style: AppTypography.headingSmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purpleAccentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${balance.totalAvailable} Days Left',
                  style: AppTypography.labelBadge.copyWith(
                    color: AppColors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LeaveProgressItem(
                  title: 'Casual Leave',
                  available: balance.casualAvailable,
                  total: balance.casualTotal,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LeaveProgressItem(
                  title: 'Sick Leave',
                  available: balance.sickAvailable,
                  total: balance.sickTotal,
                  color: AppColors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaveProgressItem extends StatelessWidget {
  final String title;
  final int available;
  final int total;
  final Color color;

  const _LeaveProgressItem({
    required this.title,
    required this.available,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.bodySmall),
            Text(
              '$available/$total',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
