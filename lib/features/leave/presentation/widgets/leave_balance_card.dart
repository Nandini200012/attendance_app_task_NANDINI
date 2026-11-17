import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card showing remaining and quota limits with visual progress meters.
class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance balance;

  const LeaveBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                      Icons.beach_access_rounded,
                      size: 16,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Annual Leave Quota',
                    style: AppTypography.headingSmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purpleAccentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${balance.totalAvailable} Days Total',
                  style: AppTypography.labelBadge.copyWith(
                    color: AppColors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LeaveQuotaColumn(
                  title: 'Casual Leave',
                  available: balance.casualAvailable,
                  total: balance.casualTotal,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _LeaveQuotaColumn(
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

class _LeaveQuotaColumn extends StatelessWidget {
  final String title;
  final int available;
  final int total;
  final Color color;

  const _LeaveQuotaColumn({
    required this.title,
    required this.available,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodySmall),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$available',
                  style: AppTypography.headingSmall.copyWith(fontSize: 18),
                ),
                TextSpan(
                  text: ' / $total days',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
