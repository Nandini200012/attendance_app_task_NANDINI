import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable banner informing employees of offline mode or pending local synchronization.
class OfflineBanner extends StatelessWidget {
  final String message;
  final bool isOffline;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const OfflineBanner({
    super.key,
    required this.message,
    this.isOffline = true,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bgTint = isOffline
        ? AppColors.pendingLight
        : AppColors.primaryAccentLight;
    final fgColor = isOffline ? AppColors.pending : AppColors.primaryAccent;
    final icon = isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onActionTap != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: AppTypography.labelBadge.copyWith(
                  color: fgColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
