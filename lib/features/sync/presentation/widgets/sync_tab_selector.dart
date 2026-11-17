import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Segmented tab switcher for filtering queue by Pending, Synced, or Failed.
class SyncTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int pendingCount;
  final int syncedCount;
  final int failedCount;

  const SyncTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.pendingCount = 0,
    this.syncedCount = 0,
    this.failedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabMeta('Pending ($pendingCount)', AppColors.pending),
      _TabMeta('Synced ($syncedCount)', AppColors.success),
      _TabMeta('Failed ($failedCount)', AppColors.error),
    ];

    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = selectedIndex == i;
        final meta = tabs[i];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 6 : 0),
            child: InkWell(
              onTap: () => onTabSelected(i),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? meta.color : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? meta.color : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: meta.color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  meta.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.buttonText
                        : AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TabMeta {
  final String label;
  final Color color;

  _TabMeta(this.label, this.color);
}
