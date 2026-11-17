import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/attendance_record_tile.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import 'history_month_selector.dart';

/// Minimal body content for Screen 3: Attendance History.
class AttendanceHistoryBody extends StatelessWidget {
  final String selectedMonth;
  final List<String> availableMonths;
  final ValueChanged<String> onMonthChanged;
  final List<AttendanceRecord> records;
  final ValueChanged<AttendanceRecord> onRecordTap;

  const AttendanceHistoryBody({
    super.key,
    required this.selectedMonth,
    required this.availableMonths,
    required this.onMonthChanged,
    required this.records,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
        vertical: 12,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryMonthSelector(
            selectedMonth: selectedMonth,
            availableMonths: availableMonths,
            onMonthChanged: onMonthChanged,
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const EmptyStateView(
              icon: Icons.event_busy_outlined,
              title: 'No Records Found',
              description: 'No attendance records found for this month.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final rec = records[index];
                return AttendanceRecordTile(
                  record: rec,
                  onTap: () => onRecordTap(rec),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
