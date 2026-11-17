import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../widgets/event_detail_info_section.dart';
import '../widgets/event_rejection_card.dart';
import '../widgets/primary_event_card.dart';

/// Screen 4: Attendance Event Details with initial skeleton loading.
class AttendanceEventDetailsScreen extends StatefulWidget {
  final AttendanceEvent? initialEvent;
  final Duration initialLoadingDuration;

  const AttendanceEventDetailsScreen({
    super.key,
    this.initialEvent,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<AttendanceEventDetailsScreen> createState() =>
      _AttendanceEventDetailsScreenState();
}

class _AttendanceEventDetailsScreenState
    extends State<AttendanceEventDetailsScreen> {
  AttendanceEvent? _currentEvent;
  bool _isInitialLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.initialEvent;
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
        title: const Text('Event Details', style: AppTypography.headingMedium),
      ),
      body: _isInitialLoading
          ? const PageSkeletonView(
              firstCardHeight: 140,
              secondCardHeight: 180,
              listCount: 2,
              showHeader: false,
            )
          : _currentEvent == null
              ? const Center(
                  child: EmptyStateView(
                    icon: Icons.info_outline,
                    title: 'No Event Details',
                    description: 'No attendance event was selected.',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenHorizontalPadding,
                    vertical: 12,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      PrimaryEventCard(event: _currentEvent!),
                      if (_currentEvent!.syncStatus == SyncStatus.rejected &&
                          _currentEvent!.rejectionReason != null) ...[
                        const SizedBox(height: 12),
                        EventRejectionCard(
                          rejectionReason: _currentEvent!.rejectionReason!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      EventDetailInfoSection(event: _currentEvent!),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
