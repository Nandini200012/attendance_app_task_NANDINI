import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../data/models/dashboard_data.dart';
import 'dashboard_leave_card.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_recent_list.dart';
import 'employee_info_card.dart';
import 'today_summary_card.dart';

/// Scrollable body widgets for Screen 1 (Employee Dashboard).
class DashboardBodyContent extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onAttendanceTap;
  final VoidCallback onLeaveTap;
  final VoidCallback onSyncTap;
  final VoidCallback onHistoryTap;
  final ValueChanged<AttendanceRecord> onRecordTap;

  const DashboardBodyContent({
    super.key,
    required this.data,
    required this.onAttendanceTap,
    required this.onLeaveTap,
    required this.onSyncTap,
    required this.onHistoryTap,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = data.pendingSyncCount;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
      ),
      child: Column(
        children: [
          if (pendingCount > 0 || data.isOffline) ...[
            OfflineBanner(
              message: pendingCount > 0
                  ? '$pendingCount attendance events recorded offline.'
                  : 'Working in offline cached mode.',
              actionLabel: 'Review & Sync',
              onActionTap: onSyncTap,
              isOffline: data.isOffline,
            ),
            const SizedBox(height: 12),
          ],
          EmployeeInfoCard(employee: data.employee),
          const SizedBox(height: 12),
          TodaySummaryCard(
            status: data.todayStatus,
            checkInTime: data.checkInTime,
            checkOutTime: data.checkOutTime,
            workingDuration: data.workingDuration,
            onTap: onAttendanceTap,
          ),
          const SizedBox(height: 12),
          DashboardQuickActions(
            onAttendanceTap: onAttendanceTap,
            onApplyLeaveTap: onLeaveTap,
            onSyncTap: onSyncTap,
          ),
          const SizedBox(height: 12),
          DashboardLeaveCard(balance: data.leaveBalance, onTap: onLeaveTap),
          const SizedBox(height: 12),
          DashboardRecentList(
            records: data.recentRecords,
            onViewAllTap: onHistoryTap,
            onRecordTap: onRecordTap,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

