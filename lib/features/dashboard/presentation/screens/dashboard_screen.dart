import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import '../../bloc/dashboard_state.dart';
import '../widgets/dashboard_body_content.dart';
import '../widgets/dashboard_header.dart';

/// Screen 1: Employee Dashboard with initial 2s skeleton shimmer and BLoC streaming.
class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToAttendance;
  final VoidCallback onNavigateToLeave;
  final VoidCallback onNavigateToSync;
  final VoidCallback onNavigateToHistory;
  final ValueChanged<AttendanceRecord> onNavigateToEventDetails;
  final Duration initialLoadingDuration;

  const DashboardScreen({
    super.key,
    required this.onNavigateToAttendance,
    required this.onNavigateToLeave,
    required this.onNavigateToSync,
    required this.onNavigateToHistory,
    required this.onNavigateToEventDetails,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardError) {
          return Scaffold(
            body: SafeArea(
              child: ErrorStateView(
                message: state.message,
                onRetry: () => context.read<DashboardBloc>().add(
                  const LoadDashboardData(),
                ),
              ),
            ),
          );
        }

        final isLoading = state is DashboardLoading || _isInitialLoading;
        if (isLoading) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: const [
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primaryAccent,
                  ),
                  Expanded(
                    child: PageSkeletonView(
                      firstCardHeight: 110,
                      secondCardHeight: 140,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! DashboardLoaded) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: EmptyStateView(
                  icon: Icons.inbox_outlined,
                  title: 'No Data Available',
                  description: 'No dashboard records found.',
                ),
              ),
            ),
          );
        }

        final data = state.data;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => context.read<DashboardBloc>().add(
                const RefreshDashboardData(),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(
                      employeeName: data.employee.name,
                      onSyncTap: widget.onNavigateToSync,
                      pendingSyncCount: data.pendingSyncCount,
                    ),
                    DashboardBodyContent(
                      data: data,
                      onAttendanceTap: widget.onNavigateToAttendance,
                      onLeaveTap: widget.onNavigateToLeave,
                      onSyncTap: widget.onNavigateToSync,
                      onHistoryTap: widget.onNavigateToHistory,
                      onRecordTap: widget.onNavigateToEventDetails,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
