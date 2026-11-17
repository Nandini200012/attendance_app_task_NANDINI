import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../models/leave_model.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Reusable tile presenting an employee leave application with status badge.
class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback? onTap;

  const LeaveRequestTile({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final startStr = DateFormatter.formatShortDate(request.startDate);
    final endStr = DateFormatter.formatShortDate(request.endDate);
    final daysLabel =
        '${request.requestedDays} ${request.requestedDays == 1 ? 'day' : 'days'}';
    final isCasual = request.leaveType == LeaveType.casual;
    final iconColor = isCasual
        ? AppColors.primaryAccent
        : AppColors.purpleAccent;
    final iconBg = isCasual
        ? AppColors.primaryAccentLight
        : AppColors.purpleAccentLight;
    final icon = isCasual
        ? Icons.beach_access_rounded
        : Icons.local_hospital_rounded;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.leaveType.label,
                    style: AppTypography.headingSmall,
                  ),
                ],
              ),
              StatusBadge.fromLeaveStatus(request.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 14,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                '$startStr - $endStr ($daysLabel)',
                style: AppTypography.bodyMediumBold,
              ),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(request.reason, style: AppTypography.bodySmall, maxLines: 2),
          ],
          if (request.status == LeaveStatus.rejected &&
              request.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rejection reason: ${request.rejectionReason}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Applied on ${DateFormatter.formatShortDate(request.submissionDate)}',
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
