import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../bloc/attendance_bloc.dart';
import '../../bloc/attendance_event.dart';
import '../widgets/location_permission_dialog.dart';

/// Helper coordinating location permission dialogs and punch submissions.
class LocationActionHandler {
  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  static Future<bool> promptPermission(BuildContext context) async {
    final result = await LocationPermissionDialog.show(context);
    if (!context.mounted || result == null) return false;
    final granted = result == LocationState.granted;
    final d = granted ? 48.2 : 0.0;
    context.read<AttendanceBloc>().add(
      SimulateLocationChange(state: result, distanceMeters: d),
    );
    showSnackBar(
      context,
      granted
          ? 'Location access granted. Proximity: 48.2m to office.'
          : 'Location access denied. Attendance is restricted.',
    );
    return granted;
  }

  static void openSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'REBS HRMS requires Location permission to record office punches. '
          'Enable location permission in App Settings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AttendanceBloc>().add(
                const SimulateLocationChange(
                  state: LocationState.granted,
                  distanceMeters: 48.2,
                ),
              );
              showSnackBar(context, 'Location permission enabled in settings.');
            },
            child: const Text('Allow Location'),
          ),
        ],
      ),
    );
  }

  static Future<void> handlePunch({
    required BuildContext context,
    required AttendanceEventType type,
    required LocationState locState,
    required double distance,
  }) async {
    if (locState == LocationState.permissionDenied ||
        locState == LocationState.permissionPermanentlyDenied) {
      final granted = await promptPermission(context);
      if (!context.mounted || !granted) return;
    }
    if (locState == LocationState.outsideRadius) {
      showSnackBar(context, 'Outside Geofence: Must be within 200m of office.');
      return;
    }
    if (locState == LocationState.gpsUnavailable) {
      showSnackBar(context, 'GPS Disabled: Please turn on device location.');
      return;
    }
    if (!context.mounted) return;
    context.read<AttendanceBloc>().add(
      RecordPunch(
        eventType: type,
        latitude: AppConstants.officeLatitude,
        longitude: AppConstants.officeLongitude,
        distanceMeters: distance,
      ),
    );
  }
}
