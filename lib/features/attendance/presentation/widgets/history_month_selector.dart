import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Minimal month selector allowing the employee to navigate attendance periods.
class HistoryMonthSelector extends StatelessWidget {
  final String selectedMonth;
  final List<String> availableMonths;
  final ValueChanged<String> onMonthChanged;

  const HistoryMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.availableMonths,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: AppColors.primaryAccent,
            ),
            const SizedBox(width: 8),
            Text('Period', style: AppTypography.bodyMediumBold),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedMonth,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primaryText,
              ),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              items: availableMonths.map((m) {
                return DropdownMenuItem<String>(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) {
                if (val != null) onMonthChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
