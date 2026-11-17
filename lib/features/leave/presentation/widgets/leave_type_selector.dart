import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/leave_enums.dart';
import '../../../../shared/widgets/app_card.dart';

/// Segmented toggle for choosing between Casual Leave and Sick Leave categories.
class LeaveTypeSelector extends StatelessWidget {
  final LeaveType selectedType;
  final ValueChanged<LeaveType> onTypeChanged;
  final int casualAvailable;
  final int sickAvailable;

  const LeaveTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.casualAvailable,
    required this.sickAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Leave Category', style: AppTypography.headingSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeCard(
                title: 'Casual Leave',
                subtitle: '$casualAvailable days available',
                isSelected: selectedType == LeaveType.casual,
                accentColor: AppColors.primaryAccent,
                bgLight: AppColors.primaryAccentLight,
                icon: Icons.beach_access_rounded,
                onTap: () => onTypeChanged(LeaveType.casual),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeCard(
                title: 'Sick Leave',
                subtitle: '$sickAvailable days available',
                isSelected: selectedType == LeaveType.sick,
                accentColor: AppColors.purpleAccent,
                bgLight: AppColors.purpleAccentLight,
                icon: Icons.local_hospital_rounded,
                onTap: () => onTypeChanged(LeaveType.sick),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final Color bgLight;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.bgLight,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      backgroundColor: isSelected ? bgLight : AppColors.card,
      borderColor: isSelected ? accentColor : AppColors.border,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? accentColor : AppColors.secondaryText,
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, size: 18, color: accentColor)
              else
                const Icon(
                  Icons.circle_outlined,
                  size: 18,
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? accentColor : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
