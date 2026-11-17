import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/attendance_enums.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/metric_item_box.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Card managing check-in and check-out triggers along with current day punch times.
class TodayAttendanceCard extends StatelessWidget {
  final AttendanceStatus status;
  final String checkInTime;
  final String checkOutTime;
  final String workingDuration;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final bool isWithinRadius;

  const TodayAttendanceCard({
    super.key,
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingDuration,
    required this.onCheckIn,
    required this.onCheckOut,
    this.isWithinRadius = true,
  });

  @override
  Widget build(BuildContext context) {
    final canCheckIn =
        isWithinRadius && status != AttendanceStatus.checkedIn;
    final canCheckOut =
        isWithinRadius && status == AttendanceStatus.checkedIn;

    return AppCard(
      padding: const EdgeInsets.all(18),
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
                      color: AppColors.primaryAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Today's Attendance",
                    style: AppTypography.headingSmall,
                  ),
                ],
              ),
              StatusBadge.fromAttendanceStatus(status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MetricItemBox(
                  label: 'Check In',
                  value: checkInTime,
                  icon: Icons.login_rounded,
                  color: AppColors.tealAccent,
                  bgColor: AppColors.tealAccentLight,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              Expanded(
                child: MetricItemBox(
                  label: 'Check Out',
                  value: checkOutTime,
                  icon: Icons.logout_rounded,
                  color: AppColors.pending,
                  bgColor: AppColors.pendingLight,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.border),
              Expanded(
                child: MetricItemBox(
                  label: 'Duration',
                  value: workingDuration,
                  icon: Icons.timer_outlined,
                  color: AppColors.primaryAccent,
                  bgColor: AppColors.primaryAccentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Check In',
                  icon: Icons.login_rounded,
                  onPressed: canCheckIn ? onCheckIn : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Check Out',
                  icon: Icons.logout_rounded,
                  onPressed: canCheckOut ? onCheckOut : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
