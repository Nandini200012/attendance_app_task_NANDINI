import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/leave_model.dart';
import 'leave_form_content.dart';

/// Scrollable wrapper for the Apply Leave form.
class ApplyLeaveBody extends StatelessWidget {
  final LeaveType selectedType;
  final LeaveBalance balance;
  final DateTime startDate;
  final DateTime endDate;
  final int requestedDays;
  final TextEditingController reasonController;
  final bool isSubmitting;
  final bool isValid;
  final String? dateErrorMessage;
  final ValueChanged<LeaveType> onTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final VoidCallback onReasonChanged;
  final VoidCallback onSubmit;

  const ApplyLeaveBody({
    super.key,
    required this.selectedType,
    required this.balance,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    required this.reasonController,
    required this.isSubmitting,
    required this.isValid,
    this.dateErrorMessage,
    required this.onTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onReasonChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
        vertical: 12,
      ),
      physics: const BouncingScrollPhysics(),
      child: LeaveFormContent(
        selectedType: selectedType,
        balance: balance,
        startDate: startDate,
        endDate: endDate,
        requestedDays: requestedDays,
        reasonController: reasonController,
        isSubmitting: isSubmitting,
        isValid: isValid,
        dateErrorMessage: dateErrorMessage,
        onTypeChanged: onTypeChanged,
        onStartDateChanged: onStartDateChanged,
        onEndDateChanged: onEndDateChanged,
        onReasonChanged: onReasonChanged,
        onSubmit: onSubmit,
      ),
    );
  }
}
