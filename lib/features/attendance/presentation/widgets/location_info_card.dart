import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card showing GPS telemetry, office distance, and visual geofence status.
class LocationInfoCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final LocationState locationState;

  const LocationInfoCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.locationState,
  });

  @override
  Widget build(BuildContext context) {
    final isWithinRadius =
        distanceMeters <= AppConstants.allowedRadiusMeters &&
        locationState == LocationState.granted;
    final statusColor = isWithinRadius ? AppColors.success : AppColors.error;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tealAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      size: 16,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Geofence Telemetry',
                    style: AppTypography.headingSmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWithinRadius
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isWithinRadius ? 'Within 200m' : 'Outside Radius',
                  style: AppTypography.labelBadge.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // InfoRow(
          //   label: 'Distance to HQ',
          //   value: '${distanceMeters.toStringAsFixed(1)} m',
          //   icon: Icons.straighten_rounded,
          // ),
          // InfoRow(
          //   label: 'GPS Coordinates',
          //   value:
          //       '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
          //   icon: Icons.pin_drop_rounded,
          // ),
          // InfoRow(
          //   label: 'Location Status',
          //   value: locationState.label,
          //   icon: Icons.security_rounded,
          //   showDivider: false,
          // ),
        ],
      ),
    );
  }
}
