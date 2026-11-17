import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../models/attendance_record.dart';
import 'app_card.dart';
import 'calendar_date_badge.dart';
import 'status_badge.dart';

/// Reusable list tile representing a daily attendance record.
class AttendanceRecordTile extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback? onTap;

  const AttendanceRecordTile({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final checkInStr = record.checkInTime != null
        ? DateFormatter.formatTime(record.checkInTime!)
        : '--:--';
    final checkOutStr = record.checkOutTime != null
        ? DateFormatter.formatTime(record.checkOutTime!)
        : '--:--';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarDateBadge(date: record.date),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.formatDateWithDay(record.date),
                      style: AppTypography.bodyMediumBold,
                    ),
                    StatusBadge.fromSyncStatus(record.syncStatus),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TimeItem(
                        label: 'In',
                        time: checkInStr,
                        color: AppColors.tealAccent,
                      ),
                    ),
                    Expanded(
                      child: _TimeItem(
                        label: 'Out',
                        time: checkOutStr,
                        color: AppColors.pending,
                      ),
                    ),
                    Expanded(
                      child: _TimeItem(
                        label: 'Duration',
                        time: record.workingDuration,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _TimeItem({
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
