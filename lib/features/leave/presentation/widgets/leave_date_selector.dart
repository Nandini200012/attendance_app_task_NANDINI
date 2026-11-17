import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'leave_date_field.dart';

/// Date range picker with strict future-date validation and quota verification.
class LeaveDateSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int requestedDays;
  final int availableQuota;
  final String? errorMessage;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const LeaveDateSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    required this.availableQuota,
    this.errorMessage,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  bool get _isExceedingQuota => requestedDays > availableQuota;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null || _isExceedingQuota;
    final accentColor = hasError ? AppColors.error : AppColors.primaryAccent;
    final bgColor =
        hasError ? AppColors.errorLight : AppColors.primaryAccentLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duration & Date Range', style: AppTypography.headingSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LeaveDateField(
                label: 'Start Date',
                date: startDate,
                onTap: () => _pickDate(context, isStartDate: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LeaveDateField(
                label: 'End Date',
                date: endDate,
                onTap: () => _pickDate(context, isStartDate: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: hasError ? 0.8 : 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hasError ? Icons.error_outline_rounded : Icons.date_range_rounded,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text('Requested Duration:', style: AppTypography.bodySmall.copyWith(color: accentColor)),
                ],
              ),
              Text(
                '$requestedDays Calendar ${requestedDays == 1 ? 'Day' : 'Days'}',
                style: AppTypography.bodyMediumBold.copyWith(color: accentColor),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorMessage ??
                      (availableQuota <= 0
                          ? 'No available leave balance remaining in this category.'
                          : 'Exceeds allowed balance ($availableQuota days available).'),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Text(
          '* All calendar days count toward leave duration.',
          style: AppTypography.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStartDate}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minDate = isStartDate ? today : (startDate.isBefore(today) ? today : startDate);
    final current = isStartDate ? startDate : endDate;
    final initial = current.isBefore(minDate) ? minDate : current;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: DateTime(today.year + 2, 12, 31),
    );
    if (picked != null) {
      final norm = DateTime(picked.year, picked.month, picked.day);
      isStartDate ? onStartDateChanged(norm) : onEndDateChanged(norm);
    }
  }
}
