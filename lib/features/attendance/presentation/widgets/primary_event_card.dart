import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/models/attendance_event.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Card showing core event attributes: type, sync status, ID, and timestamp.
class PrimaryEventCard extends StatelessWidget {
  final AttendanceEvent event;

  const PrimaryEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isCheckIn = event.eventType == AttendanceEventType.checkIn;
    final color = isCheckIn ? AppColors.tealAccent : AppColors.pending;
    final bg = isCheckIn ? AppColors.tealAccentLight : AppColors.pendingLight;
    final icon = isCheckIn ? Icons.login_rounded : Icons.logout_rounded;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.eventType.label,
                    style: AppTypography.headingSmall,
                  ),
                ],
              ),
              StatusBadge.fromSyncStatus(event.syncStatus),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: 'Event Identifier',
            value: event.eventId,
            icon: Icons.tag_rounded,
          ),
          InfoRow(
            label: 'Recorded Timestamp',
            value: DateFormatter.formatTimestamp(event.timestamp),
            icon: Icons.schedule_rounded,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
