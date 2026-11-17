import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';

/// Modal dialog prompting the employee for device location access.
class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  /// Helper to display the modal permission prompt.
  static Future<LocationState?> show(BuildContext context) {
    return showDialog<LocationState>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LocationPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryAccentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryAccent,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Allow "REBS HRMS" to access this device\'s location?',
              textAlign: TextAlign.center,
              style: AppTypography.headingSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'REBS HRMS requires location access to verify you are '
              'within 200m of the office geofence before punching attendance.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 22),
            _buildOption(
              context: context,
              label: 'While using the app',
              state: LocationState.granted,
              isPrimary: true,
            ),
            const SizedBox(height: 8),
            _buildOption(
              context: context,
              label: 'Only this time',
              state: LocationState.granted,
              isPrimary: false,
            ),
            const SizedBox(height: 8),
            _buildOption(
              context: context,
              label: "Don't allow",
              state: LocationState.permissionDenied,
              isPrimary: false,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required LocationState state,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(state),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isPrimary ? AppColors.primaryAccent : Colors.transparent,
          side: BorderSide(
            color: isPrimary
                ? AppColors.primaryAccent
                : isDestructive
                ? AppColors.border
                : AppColors.border,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary
                ? Colors.white
                : isDestructive
                ? AppColors.error
                : AppColors.primaryText,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

