import 'package:flutter/material.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'leave_date_selector.dart';
import 'leave_reason_input.dart';
import 'leave_type_selector.dart';

/// Form inputs and submission action button for the leave application screen.
class LeaveFormContent extends StatelessWidget {
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

  const LeaveFormContent({
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
    final quota = selectedType == LeaveType.casual
        ? balance.casualAvailable
        : balance.sickAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeaveTypeSelector(
          selectedType: selectedType,
          casualAvailable: balance.casualAvailable,
          sickAvailable: balance.sickAvailable,
          onTypeChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        LeaveDateSelector(
          startDate: startDate,
          endDate: endDate,
          requestedDays: requestedDays,
          availableQuota: quota,
          errorMessage: dateErrorMessage,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
        ),
        const SizedBox(height: 16),
        LeaveReasonInput(
          controller: reasonController,
          onChanged: (_) => onReasonChanged(),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: isSubmitting ? 'Submitting...' : 'Submit Leave Application',
          onPressed: isValid && !isSubmitting ? onSubmit : null,
        ),
      ],
    );
  }
}
