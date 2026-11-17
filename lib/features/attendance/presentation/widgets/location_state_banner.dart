import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';
import 'location_banner_config.dart';

/// Contextual warning or error banner reflecting current location and hardware states.
class LocationStateBanner extends StatelessWidget {
  final LocationState state;
  final VoidCallback? onSettingsTap;

  const LocationStateBanner({
    super.key,
    required this.state,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state == LocationState.granted) {
      return const SizedBox.shrink();
    }

    final config = LocationBannerConfig.fromState(state);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, size: 20, color: config.foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: config.foregroundColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: config.foregroundColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onSettingsTap != null && config.actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSettingsTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(40, 32),
              ),
              child: Text(
                config.actionLabel!,
                style: TextStyle(
                  color: config.foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
