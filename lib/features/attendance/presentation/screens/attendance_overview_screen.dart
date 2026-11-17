import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/attendance_bloc.dart';
import '../../bloc/attendance_event.dart';
import '../../bloc/attendance_state.dart';
import '../utils/location_action_handler.dart';
import '../widgets/attendance_overview_app_bar.dart';
import '../widgets/attendance_overview_body.dart';

/// Screen 2: Attendance Overview with live geofencing, permission handling, and skeleton.
class AttendanceOverviewScreen extends StatefulWidget {
  final VoidCallback onNavigateToHistory;
  final ValueChanged<AttendanceRecord> onNavigateToEventDetails;
  final Duration initialLoadingDuration;

  const AttendanceOverviewScreen({
    super.key,
    required this.onNavigateToHistory,
    required this.onNavigateToEventDetails,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<AttendanceOverviewScreen> createState() =>
      _AttendanceOverviewScreenState();
}

class _AttendanceOverviewScreenState extends State<AttendanceOverviewScreen> {
  bool _isInitialLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.initialLoadingDuration, () {
      if (mounted) setState(() => _isInitialLoading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceLoaded && state.notificationMessage != null) {
          LocationActionHandler.showSnackBar(
            context,
            state.notificationMessage!,
          );
        }
      },
      builder: (context, state) {
        if (state is AttendanceLoading || _isInitialLoading) {
          return Scaffold(
            appBar: AttendanceOverviewAppBar(
              onHistoryTap: widget.onNavigateToHistory,
              onLocationSelected: (_) {},
              onRequestPermission: () {},
            ),
            body: const PageSkeletonView(
              firstCardHeight: 140,
              secondCardHeight: 110,
              showHeader: false,
            ),
          );
        }

        final loaded = state is AttendanceLoaded ? state : null;
        final status = loaded?.todayStatus ?? AttendanceStatus.checkedIn;
        final locState = loaded?.locationState ?? LocationState.granted;
        final distance = loaded?.distanceMeters ?? 48.2;
        final records = loaded?.records ?? const [];

        return Scaffold(
          appBar: AttendanceOverviewAppBar(
            onHistoryTap: widget.onNavigateToHistory,
            onLocationSelected: (s) {
              final d = s == LocationState.outsideRadius ? 385.0 : 48.2;
              context.read<AttendanceBloc>().add(
                SimulateLocationChange(state: s, distanceMeters: d),
              );
            },
            onRequestPermission: () =>
                LocationActionHandler.promptPermission(context),
          ),
          body: AttendanceOverviewBody(
            status: status,
            locState: locState,
            distance: distance,
            records: records,
            lastPunchEvent: loaded?.lastPunchEvent,
            onHistoryTap: widget.onNavigateToHistory,
            onRecordTap: widget.onNavigateToEventDetails,
            onRequestPermission: () =>
                LocationActionHandler.promptPermission(context),
            onOpenSettings: () =>
                LocationActionHandler.openSettingsDialog(context),
          ),
        );
      },
    );
  }
}
