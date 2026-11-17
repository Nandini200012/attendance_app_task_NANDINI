import 'package:flutter/material.dart';
import '../../../../shared/models/attendance_record.dart';
import '../../../../shared/widgets/attendance_record_tile.dart';
import '../../../../shared/widgets/section_header.dart';

/// Renders recent attendance records with view history shortcut.
class AttendanceRecentSection extends StatelessWidget {
  final List<AttendanceRecord> records;
  final VoidCallback onViewFullHistory;
  final ValueChanged<AttendanceRecord> onRecordTap;

  const AttendanceRecentSection({
    super.key,
    required this.records,
    required this.onViewFullHistory,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activity',
          trailing: TextButton(
            onPressed: onViewFullHistory,
            child: const Text('View Full History'),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (ctx, index) {
            final rec = records[index];
            return AttendanceRecordTile(
              record: rec,
              onTap: () => onRecordTap(rec),
            );
          },
        ),
      ],
    );
  }
}
