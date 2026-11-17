import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Highlights rejection diagnostic messages when an attendance event fails validation.
class EventRejectionCard extends StatelessWidget {
  final String rejectionReason;

  const EventRejectionCard({super.key, required this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.errorLight,
      borderColor: AppColors.error.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, size: 22, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Rejected by HR Policy',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rejectionReason,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
