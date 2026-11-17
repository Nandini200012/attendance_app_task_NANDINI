import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable key-value row for displaying metadata, telemetry, and event details.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final IconData? icon;
  final bool showDivider;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.icon,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.secondaryText),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.bodySmall),
              const Spacer(),
              if (valueWidget != null)
                valueWidget!
              else
                Flexible(
                  child: Text(
                    value,
                    style: AppTypography.bodyMediumBold,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}
