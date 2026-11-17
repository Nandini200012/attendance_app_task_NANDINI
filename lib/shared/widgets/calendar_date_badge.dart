import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Compact calendar date badge displaying the day number and 3-letter month.
class CalendarDateBadge extends StatelessWidget {
  final DateTime date;

  const CalendarDateBadge({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: AppTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            months[date.month - 1],
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }
}
