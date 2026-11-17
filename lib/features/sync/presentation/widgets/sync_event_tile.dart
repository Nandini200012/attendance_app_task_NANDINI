import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/models/sync_operation.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Reusable tile presenting an operation in the persistent synchronization queue.
class SyncEventTile extends StatelessWidget {
  final SyncOperation operation;
  final VoidCallback onTap;

  SyncEventTile({
    super.key,
    SyncOperation? operation,
    AttendanceEvent? event,
    required this.onTap,
  }) : operation = operation ??
           SyncOperation(
             id: event!.eventId,
             type: event.eventType == AttendanceEventType.checkOut
                 ? SyncOperationType.checkOut
                 : SyncOperationType.checkIn,
             payload: event.toJson(),
             createdAt: event.timestamp,
             status: event.syncStatus == SyncStatus.synced
                 ? SyncOpStatus.synced
                 : event.syncStatus == SyncStatus.rejected
                 ? SyncOpStatus.failed
                 : SyncOpStatus.pending,
           );

  @override
  Widget build(BuildContext context) {
    final isCheckIn = operation.type == SyncOperationType.checkIn;
    final isLeave = operation.type == SyncOperationType.leaveApplication;
    final typeColor = isCheckIn
        ? AppColors.tealAccent
        : isLeave ? AppColors.primaryAccent : AppColors.pending;
    final typeBg = isCheckIn
        ? AppColors.tealAccentLight
        : isLeave ? AppColors.primaryAccentLight : AppColors.pendingLight;
    final typeIcon = isCheckIn
        ? Icons.login_rounded
        : isLeave ? Icons.event_note_rounded : Icons.logout_rounded;
    final subtitle = isLeave
        ? 'Leave: ${operation.payload['leave_type'] ?? operation.payload['leaveType'] ?? 'General'}'
        : operation.type.label;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(typeIcon, size: 16, color: typeColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: AppTypography.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge.fromSyncOpStatus(operation.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.tag_rounded, size: 14, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  operation.displayId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormatter.formatTimestamp(operation.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          if (isLeave) ...[
            const SizedBox(height: 6),
            Text(
              '${operation.payload['start_date']} to ${operation.payload['end_date']} • ${operation.payload['number_of_days']} day(s)',
              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.primaryText),
            ),
          ],
          if (operation.errorMessage != null && operation.status == SyncOpStatus.failed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Failed (Retries: ${operation.retryCount}): ${operation.errorMessage}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
