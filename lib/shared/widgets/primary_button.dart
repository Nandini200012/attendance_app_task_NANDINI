import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Primary action button styled with #111111 solid fill and #FFFFFF text.
///
/// Ensures a comfortable touch target (minimum 48px height) and clear visual hierarchy.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.buttonText,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.buttonText),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTypography.buttonText),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: AppColors.buttonText,
          disabledBackgroundColor: AppColors.secondaryText.withValues(
            alpha: 0.3,
          ),
          elevation: 2,
          shadowColor: AppColors.primaryButton.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: buttonContent,
      ),
    );
  }
}
