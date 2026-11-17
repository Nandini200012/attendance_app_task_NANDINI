import 'package:flutter/material.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/attendance_record_tile.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/section_header.dart';

/// Renders the 5 most recent attendance records on the employee dashboard.
class DashboardRecentList extends StatelessWidget {
  final List<AttendanceRecord> records;
  final VoidCallback onViewAllTap;
  final ValueChanged<AttendanceRecord> onRecordTap;

  const DashboardRecentList({
    super.key,
    required this.records,
    required this.onViewAllTap,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Attendance',
          trailing: TextButton(
            onPressed: onViewAllTap,
            child: const Text('View All'),
          ),
        ),
        if (records.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: EmptyStateView(
              icon: Icons.history_rounded,
              title: 'No Recent Attendance',
              description: 'No attendance records recorded yet.',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.take(5).length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final record = records[index];
              return AttendanceRecordTile(
                record: record,
                onTap: () => onRecordTap(record),
              );
            },
          ),
      ],
    );
  }
}
