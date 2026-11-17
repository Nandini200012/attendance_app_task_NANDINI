import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/attendance_enums.dart';

/// Configuration descriptor for location state banners.
class LocationBannerConfig {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final String? actionLabel;

  const LocationBannerConfig({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.actionLabel,
  });

  /// Resolves the visual configuration for a given location state
  static LocationBannerConfig fromState(LocationState state) {
    switch (state) {
      case LocationState.outsideRadius:
        return LocationBannerConfig(
          title: 'Outside Allowed Radius',
          message: 'You are >200m from REBS HQ. Check-in is restricted.',
          icon: Icons.wrong_location_outlined,
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.3),
        );
      case LocationState.gpsUnavailable:
        return LocationBannerConfig(
          title: 'GPS Signal Unavailable',
          message: 'Ensure device location / GPS toggle is turned on.',
          icon: Icons.location_disabled_outlined,
          backgroundColor: AppColors.pendingLight,
          foregroundColor: AppColors.pending,
          borderColor: AppColors.pending.withValues(alpha: 0.3),
          actionLabel: 'Enable',
        );
      case LocationState.permissionDenied:
        return LocationBannerConfig(
          title: 'Location Permission Required',
          message: 'Grant location permission to record valid attendance.',
          icon: Icons.security_outlined,
          backgroundColor: AppColors.pendingLight,
          foregroundColor: AppColors.pending,
          borderColor: AppColors.pending.withValues(alpha: 0.3),
          actionLabel: 'Allow',
        );
      case LocationState.permissionPermanentlyDenied:
        return LocationBannerConfig(
          title: 'Permission Permanently Denied',
          message: 'Please enable location permissions in Android Settings.',
          icon: Icons.settings_outlined,
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.3),
          actionLabel: 'Settings',
        );
      case LocationState.granted:
        return const LocationBannerConfig(
          title: '',
          message: '',
          icon: Icons.check,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          borderColor: Colors.transparent,
        );
    }
  }
}
