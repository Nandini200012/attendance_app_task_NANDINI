import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Card showing internet connection health, last successful sync timestamp, and trigger.
class SyncStatusCard extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final VoidCallback onSyncNow;

  const SyncStatusCard({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
    required this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppColors.success : AppColors.error;
    final statusBg = isOnline ? AppColors.successLight : AppColors.errorLight;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Cloud Sync Online' : 'Offline Mode Active',
                      style: AppTypography.labelBadge.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                size: 20,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lastSyncTime != null
                ? 'Last synchronized on ${DateFormatter.formatTimestamp(lastSyncTime!)}'
                : 'Not synchronized yet',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: isSyncing
                ? 'Synchronizing Events...'
                : 'Sync Pending Events',
            icon: Icons.sync_rounded,
            isLoading: isSyncing,
            onPressed: isOnline ? onSyncNow : null,
          ),
        ],
      ),
    );
  }
}
