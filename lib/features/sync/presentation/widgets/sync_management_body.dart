import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/sync_model.dart';
import '../../../../shared/models/sync_operation.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import 'sync_event_tile.dart';
import 'sync_stats_card.dart';
import 'sync_status_card.dart';
import 'sync_tab_selector.dart';

/// Body content for Screen 7: Sync Management.
class SyncManagementBody extends StatelessWidget {
  final SyncStats stats;
  final bool isSyncing;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final List<SyncOperation> operations;
  final VoidCallback onSyncNow;
  final ValueChanged<SyncOperation> onOperationTap;

  const SyncManagementBody({
    super.key,
    required this.stats,
    required this.isSyncing,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.operations,
    required this.onSyncNow,
    required this.onOperationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.screenHorizontalPadding,
          12,
          AppConstants.screenHorizontalPadding,
          32,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SyncStatusCard(
              isOnline: stats.isOnline,
              isSyncing: isSyncing,
              lastSyncTime: stats.lastSyncTime,
              onSyncNow: onSyncNow,
            ),
            const SizedBox(height: 12),
            SyncStatsCard(
              pendingCount: stats.pendingCount,
              syncedCount: stats.syncedCount,
              rejectedCount: stats.rejectedCount,
            ),
            const SizedBox(height: 16),
            SyncTabSelector(
              selectedIndex: selectedTabIndex,
              onTabSelected: onTabSelected,
              pendingCount: stats.pendingCount,
              syncedCount: stats.syncedCount,
              failedCount: stats.rejectedCount,
            ),
            const SizedBox(height: 12),
            if (operations.isEmpty)
              const EmptyStateView(
                icon: Icons.done_all_rounded,
                title: 'Queue Clean',
                description: 'No operations under the selected queue filter.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: operations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final op = operations[idx];
                  return SyncEventTile(
                    operation: op,
                    onTap: () => onOperationTap(op),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
