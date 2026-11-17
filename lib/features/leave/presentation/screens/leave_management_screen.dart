import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/leave_bloc.dart';
import '../../bloc/leave_event.dart';
import '../../bloc/leave_state.dart';
import '../widgets/leave_management_body.dart';

/// Screen 5: Leave Management with status filtering and offline caching.
class LeaveManagementScreen extends StatefulWidget {
  final VoidCallback onNavigateToApplyLeave;
  final Duration initialLoadingDuration;

  const LeaveManagementScreen({
    super.key,
    required this.onNavigateToApplyLeave,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  bool _isInitialLoading = true;
  Timer? _timer;
  int _selectedFilterIndex = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management', style: AppTypography.headingMedium),
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state is LeaveLoading || _isInitialLoading) {
            return const PageSkeletonView(
              firstCardHeight: 110,
              secondCardHeight: 50,
              listCount: 3,
              showHeader: false,
            );
          }

          final loaded = state is LeaveLoaded ? state : null;
          final balance = loaded?.balance ?? LeaveBalance.empty;
          final allRequests = loaded?.requests ?? const [];

          final filtered = allRequests.where((r) {
            if (_selectedFilterIndex == 1) return r.status == LeaveStatus.pending;
            if (_selectedFilterIndex == 2) return r.status == LeaveStatus.approved;
            if (_selectedFilterIndex == 3) return r.status == LeaveStatus.rejected;
            return true;
          }).toList();

          return LeaveManagementBody(
            balance: balance,
            requests: filtered,
            selectedFilterIndex: _selectedFilterIndex,
            onFilterChanged: (i) => setState(() => _selectedFilterIndex = i),
            onApplyLeave: widget.onNavigateToApplyLeave,
            onRefresh: () async =>
                context.read<LeaveBloc>().add(const LoadLeaveData()),
          );
        },
      ),
    );
  }
}
