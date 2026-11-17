import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card summarizing pending, synced, and rejected event totals with a visual queue meter.
class SyncStatsCard extends StatelessWidget {
  final int pendingCount;
  final int syncedCount;
  final int rejectedCount;

  const SyncStatsCard({
    super.key,
    required this.pendingCount,
    required this.syncedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + syncedCount + rejectedCount;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Queue Diagnostics',
                style: AppTypography.headingSmall,
              ),
              Text('$total total events', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: syncedCount,
                      child: Container(color: AppColors.success),
                    ),
                    if (pendingCount > 0)
                      Expanded(
                        flex: pendingCount,
                        child: Container(color: AppColors.pending),
                      ),
                    if (rejectedCount > 0)
                      Expanded(
                        flex: rejectedCount,
                        child: Container(color: AppColors.error),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: _CountBox(
                  title: 'Pending',
                  count: pendingCount,
                  color: AppColors.pending,
                  bgColor: AppColors.pendingLight,
                  icon: Icons.sync_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  title: 'Synced',
                  count: syncedCount,
                  color: AppColors.success,
                  bgColor: AppColors.successLight,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  title: 'Rejected',
                  count: rejectedCount,
                  color: AppColors.error,
                  bgColor: AppColors.errorLight,
                  icon: Icons.error_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _CountBox({
    required this.title,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: AppTypography.headingSmall.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
