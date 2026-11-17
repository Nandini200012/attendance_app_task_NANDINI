import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';

/// Clickable date picker input field for leave date selections.
class LeaveDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const LeaveDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatShortDate(date),
                style: AppTypography.bodyMediumBold,
              ),
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.primaryAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
