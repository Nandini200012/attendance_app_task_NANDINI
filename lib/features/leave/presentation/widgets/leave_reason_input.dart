import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Text area for providing leave justification with minimum length validation.
class LeaveReasonInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  const LeaveReasonInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final nonWhitespaceLength = text.replaceAll(RegExp(r'\s'), '').length;
    final hasEnoughChars =
        nonWhitespaceLength >= AppConstants.minLeaveReasonLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reason for Leave', style: AppTypography.headingSmall),
            Text(
              '$nonWhitespaceLength/${AppConstants.minLeaveReasonLength} min characters',
              style: AppTypography.bodySmall.copyWith(
                color: hasEnoughChars
                    ? AppColors.secondaryText
                    : AppColors.error,
                fontWeight: hasEnoughChars ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 3,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Describe the purpose of your leave request...',
            errorText: errorMessage,
          ),
        ),
      ],
    );
  }
}
