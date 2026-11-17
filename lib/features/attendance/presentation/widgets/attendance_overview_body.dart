import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../utils/location_action_handler.dart';
import 'attendance_recent_section.dart';
import 'location_info_card.dart';
import 'location_state_banner.dart';
import 'today_attendance_card.dart';

/// Scrollable body widgets for Screen 2 (Attendance Overview).
class AttendanceOverviewBody extends StatelessWidget {
  final AttendanceStatus status;
  final LocationState locState;
  final double distance;
  final List<AttendanceRecord> records;
  final AttendanceEvent? lastPunchEvent;
  final VoidCallback onHistoryTap;
  final ValueChanged<AttendanceRecord> onRecordTap;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  const AttendanceOverviewBody({
    super.key,
    required this.status,
    required this.locState,
    required this.distance,
    required this.records,
    this.lastPunchEvent,
    required this.onHistoryTap,
    required this.onRecordTap,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final todayRec = records.isNotEmpty ? records.first : null;
    final checkIn = todayRec?.checkInTime != null
        ? DateFormatter.formatTime(todayRec!.checkInTime!)
        : '--:--';
    final checkOut = status == AttendanceStatus.checkedIn
        ? '--:--'
        : (todayRec?.checkOutTime != null
            ? DateFormatter.formatTime(todayRec!.checkOutTime!)
            : '--:--');
    final duration = todayRec?.workingDuration ??
        (status == AttendanceStatus.notCheckedIn ? '0h 00m' : '--');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
        vertical: 12,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocationStateBanner(
            state: locState,
            onSettingsTap: () =>
                locState == LocationState.permissionPermanentlyDenied
                    ? onOpenSettings()
                    : onRequestPermission(),
          ),
          if (locState != LocationState.granted) const SizedBox(height: 12),
          TodayAttendanceCard(
            status: status,
            checkInTime: checkIn,
            checkOutTime: checkOut,
            workingDuration: duration,
            isWithinRadius: locState == LocationState.granted,
            onCheckIn: () => LocationActionHandler.handlePunch(
              context: context,
              type: AttendanceEventType.checkIn,
              locState: locState,
              distance: distance,
            ),
            onCheckOut: () => LocationActionHandler.handlePunch(
              context: context,
              type: AttendanceEventType.checkOut,
              locState: locState,
              distance: distance,
            ),
          ),
          const SizedBox(height: 12),
          LocationInfoCard(
            latitude: AppConstants.officeLatitude,
            longitude: AppConstants.officeLongitude,
            distanceMeters: distance,
            locationState: locState,
          ),
          if (lastPunchEvent != null &&
              lastPunchEvent!.syncStatus == SyncStatus.pending) ...[
            const SizedBox(height: 12),
            OfflineBanner(
              message:
                  'Pending sync: ${lastPunchEvent!.eventType.label} recorded locally.',
              isOffline: true,
            ),
          ],
          const SizedBox(height: 12),
          AttendanceRecentSection(
            records: records.take(3).toList(),
            onViewFullHistory: onHistoryTap,
            onRecordTap: onRecordTap,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

