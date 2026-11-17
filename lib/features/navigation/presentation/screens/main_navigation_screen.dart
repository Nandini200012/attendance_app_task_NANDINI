import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../attendance/bloc/attendance_bloc.dart';
import '../../../attendance/bloc/attendance_event.dart' show LoadAttendanceMonth;
import '../../../attendance/presentation/screens/attendance_event_details_screen.dart';
import '../../../attendance/presentation/screens/attendance_history_screen.dart';
import '../../../attendance/presentation/screens/attendance_overview_screen.dart';
import '../../../dashboard/bloc/dashboard_bloc.dart';
import '../../../dashboard/bloc/dashboard_event.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../leave/bloc/leave_bloc.dart';
import '../../../leave/bloc/leave_event.dart';
import '../../../leave/presentation/screens/apply_leave_screen.dart';
import '../../../leave/presentation/screens/leave_management_screen.dart';
import '../../../sync/bloc/sync_bloc.dart';
import '../../../sync/bloc/sync_event.dart';
import '../../../sync/bloc/sync_state.dart';
import '../../../sync/presentation/screens/sync_management_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Root shell widget hosting the 3 core destinations and centralized routing.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) => setState(() => _currentIndex = index);

  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceHistoryScreen(
          onNavigateToEventDetails: _navigateToEventDetailsFromRecord,
        ),
      ),
    );
  }

  Future<void> _navigateToSync() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyncManagementScreen(
          onNavigateToEventDetails: _navigateToEventDetails,
        ),
      ),
    );
    if (!mounted) return;
    _refreshSyncData();
  }

  void _refreshSyncData() {
    final now = DateTime.now();
    final m = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    context.read<AttendanceBloc>().add(LoadAttendanceMonth(m));
    context.read<DashboardBloc>().add(const RefreshDashboardData());
    context.read<LeaveBloc>().add(const LoadLeaveData());
  }

  Future<void> _navigateToApplyLeave() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApplyLeaveScreen()),
    );
    if (!mounted) return;
    context.read<SyncBloc>().add(const LoadSyncData());
  }

  void _navigateToEventDetails(AttendanceEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceEventDetailsScreen(initialEvent: event),
      ),
    );
  }

  void _navigateToEventDetailsFromRecord(AttendanceRecord record) {
    final event = AttendanceEvent(
      eventId: 'EVT-${record.id}',
      eventType: AttendanceEventType.checkIn,
      timestamp: record.checkInTime ?? record.date,
      latitude: AppConstants.officeLatitude,
      longitude: AppConstants.officeLongitude,
      distanceMeters: 48.2,
      syncStatus: record.syncStatus,
      rejectionReason: record.syncStatus.name == 'rejected'
          ? 'Outside allowed geofence perimeter (468.5m > 200m limit).'
          : null,
    );
    _navigateToEventDetails(event);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToAttendance: () => _navigateToTab(1),
        onNavigateToLeave: () => _navigateToTab(2),
        onNavigateToSync: _navigateToSync,
        onNavigateToHistory: _navigateToHistory,
        onNavigateToEventDetails: _navigateToEventDetailsFromRecord,
      ),
      AttendanceOverviewScreen(
        onNavigateToHistory: _navigateToHistory,
        onNavigateToEventDetails: _navigateToEventDetailsFromRecord,
      ),
      LeaveManagementScreen(onNavigateToApplyLeave: _navigateToApplyLeave),
    ];

    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (prev, curr) {
        if (prev is SyncLoaded && curr is SyncLoaded) {
          return prev.pendingOperations.length !=
                  curr.pendingOperations.length ||
              prev.syncedOperations.length != curr.syncedOperations.length;
        }
        return curr is SyncLoaded && prev is! SyncLoaded;
      },
      listener: (_, _) => _refreshSyncData(),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _navigateToTab,
        ),
      ),
    );
  }
}
