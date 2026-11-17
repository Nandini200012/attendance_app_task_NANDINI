import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';

/// App bar for Attendance Overview with history shortcut and reviewer GPS simulation menu.
class AttendanceOverviewAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onHistoryTap;
  final ValueChanged<LocationState> onLocationSelected;
  final VoidCallback onRequestPermission;

  const AttendanceOverviewAppBar({
    super.key,
    required this.onHistoryTap,
    required this.onLocationSelected,
    required this.onRequestPermission,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Attendance Overview', style: AppTypography.headingMedium),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Attendance History',
          onPressed: onHistoryTap,
        ),
        PopupMenuButton<LocationState>(
          icon: const Icon(Icons.gps_fixed_rounded, color: AppColors.primaryAccent),
          tooltip: 'Simulate GPS Location',
          onSelected: onLocationSelected,
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: LocationState.granted,
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: AppColors.tealAccent),
                title: Text('Within Office (48m)'),
                subtitle: Text('Allow Punch (Valid Radius)'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: LocationState.outsideRadius,
              child: ListTile(
                leading: Icon(Icons.wrong_location_outlined, color: AppColors.error),
                title: Text('Outside Office (385m)'),
                subtitle: Text('Reject Punch (>200m)'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: LocationState.gpsUnavailable,
              child: ListTile(
                leading: Icon(Icons.location_off_outlined, color: AppColors.pending),
                title: Text('GPS Unavailable'),
                subtitle: Text('Hardware Disabled'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: LocationState.permissionDenied,
              child: ListTile(
                leading: Icon(Icons.block_outlined, color: AppColors.error),
                title: Text('Permission Denied'),
                subtitle: Text('Prompt Permission Dialog'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: LocationState.permissionPermanentlyDenied,
              child: ListTile(
                leading: Icon(Icons.settings_outlined, color: AppColors.error),
                title: Text('Permanently Denied'),
                subtitle: Text('Prompt App Settings Dialog'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
