import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/attendance_bloc.dart';
import '../../bloc/attendance_event.dart';
import '../../bloc/attendance_state.dart';
import '../widgets/attendance_history_body.dart';

/// Screen 3: Minimal Attendance History showing the pure records list.
class AttendanceHistoryScreen extends StatefulWidget {
  final ValueChanged<AttendanceRecord> onNavigateToEventDetails;
  final Duration initialLoadingDuration;

  const AttendanceHistoryScreen({
    super.key,
    required this.onNavigateToEventDetails,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _isInitialLoading = true;
  Timer? _timer;
  String _selectedMonth = 'November 2026';
  final List<String> _months = [
    'November 2026',
    'October 2026',
    'September 2026',
  ];

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

  String _formatMonthParam(String monthLabel) {
    if (monthLabel.contains('October')) return '2026-10';
    if (monthLabel.contains('September')) return '2026-09';
    return '2026-11';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History', style: AppTypography.headingMedium),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading || _isInitialLoading) {
            return const PageSkeletonView(
              firstCardHeight: 50,
              secondCardHeight: 120,
              listCount: 4,
              showHeader: false,
            );
          }

          final loaded = state is AttendanceLoaded ? state : null;
          final records = loaded?.records ?? const [];

          return AttendanceHistoryBody(
            selectedMonth: _selectedMonth,
            availableMonths: _months,
            onMonthChanged: (m) {
              setState(() => _selectedMonth = m);
              context.read<AttendanceBloc>().add(
                LoadAttendanceMonth(_formatMonthParam(m)),
              );
            },
            records: records,
            onRecordTap: widget.onNavigateToEventDetails,
          );
        },
      ),
    );
  }
}
