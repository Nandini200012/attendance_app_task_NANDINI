import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/sync_model.dart';
import '../../../../shared/models/sync_operation.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/sync_bloc.dart';
import '../../bloc/sync_event.dart';
import '../../bloc/sync_state.dart';
import '../widgets/sync_management_body.dart';

/// Screen 7: Sync Management with unified offline queue telemetry and live updates.
class SyncManagementScreen extends StatefulWidget {
  final ValueChanged<AttendanceEvent> onNavigateToEventDetails;
  final Duration initialLoadingDuration;

  const SyncManagementScreen({
    super.key,
    required this.onNavigateToEventDetails,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<SyncManagementScreen> createState() => _SyncManagementScreenState();
}

class _SyncManagementScreenState extends State<SyncManagementScreen> {
  bool _isInitialLoading = true;
  Timer? _timer;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(const LoadSyncData());
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
    return BlocConsumer<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state is SyncLoaded && state.notificationMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.notificationMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Sync Management',
              style: AppTypography.headingMedium,
            ),
          ),
          body: (state is SyncInitial || _isInitialLoading)
              ? const PageSkeletonView(
                  firstCardHeight: 120,
                  secondCardHeight: 120,
                  listCount: 3,
                  showHeader: false,
                )
              : _buildLoadedContent(state),
        );
      },
    );
  }

  Widget _buildLoadedContent(SyncState state) {
    final loaded = state is SyncLoaded ? state : null;
    final stats = loaded?.stats ?? SyncStats.empty;
    final isSyncing = loaded?.isSyncing ?? false;

    List<SyncOperation> ops = [];
    if (_selectedTabIndex == 0) {
      ops = loaded?.pendingOperations ?? const [];
    } else if (_selectedTabIndex == 1) {
      ops = loaded?.syncedOperations ?? const [];
    } else {
      ops = loaded?.failedOperations ?? const [];
    }

    return SyncManagementBody(
      stats: stats,
      isSyncing: isSyncing,
      selectedTabIndex: _selectedTabIndex,
      onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
      operations: ops,
      onSyncNow: () => context.read<SyncBloc>().add(const TriggerSyncNow()),
      onOperationTap: (op) {
        if (op.isAttendance) {
          widget.onNavigateToEventDetails(op.toAttendanceEvent());
        }
      },
    );
  }
}
