import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/info_row.dart';

/// Renders device, network, and geofence telemetry metadata for an attendance punch.
class EventDetailInfoSection extends StatelessWidget {
  final AttendanceEvent event;

  const EventDetailInfoSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification & Telemetry',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: 'Office Perimeter',
            value: '${AppConstants.allowedRadiusMeters.toInt()}m Geofence',
            icon: Icons.radar_outlined,
          ),
          InfoRow(
            label: 'Office Distance',
            value: '${event.distanceMeters.toStringAsFixed(1)} meters',
            icon: Icons.navigation_outlined,
          ),
          InfoRow(
            label: 'GPS Coordinates',
            value:
                '${event.latitude.toStringAsFixed(6)}, ${event.longitude.toStringAsFixed(6)}',
            icon: Icons.pin_drop_outlined,
          ),
          InfoRow(
            label: 'Verification Method',
            value: event.verificationMethod,
            icon: Icons.verified_user_outlined,
          ),
          InfoRow(
            label: 'Network Type',
            value: event.networkType,
            icon: Icons.wifi_outlined,
          ),
          InfoRow(
            label: 'Hardware Device',
            value: event.deviceModel,
            icon: Icons.smartphone_outlined,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
