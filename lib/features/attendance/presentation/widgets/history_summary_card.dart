import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Minimal monthly attendance metrics row: present days, total hours, and daily average.
class HistorySummaryCard extends StatelessWidget {
  final int totalPresentDays;
  final String totalWorkingHours;
  final String averageHoursPerDay;

  const HistorySummaryCard({
    super.key,
    required this.totalPresentDays,
    required this.totalWorkingHours,
    required this.averageHoursPerDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MinimalMetric(label: 'Present', value: '$totalPresentDays days'),
          Container(width: 1, height: 26, color: AppColors.border),
          _MinimalMetric(label: 'Total Hours', value: totalWorkingHours),
          Container(width: 1, height: 26, color: AppColors.border),
          _MinimalMetric(label: 'Daily Avg', value: averageHoursPerDay),
        ],
      ),
    );
  }
}

class _MinimalMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MinimalMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.bodyMediumBold),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
