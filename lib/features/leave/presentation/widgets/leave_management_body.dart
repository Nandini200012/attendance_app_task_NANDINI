import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/leave_request_tile.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import 'leave_balance_card.dart';

/// Body content for Screen 5: Leave Management.
class LeaveManagementBody extends StatelessWidget {
  final LeaveBalance balance;
  final List<LeaveRequest> requests;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onApplyLeave;
  final RefreshCallback onRefresh;

  const LeaveManagementBody({
    super.key,
    required this.balance,
    required this.requests,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.onApplyLeave,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenHorizontalPadding,
          vertical: 12,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeaveBalanceCard(balance: balance),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Apply for Leave',
              icon: Icons.add_rounded,
              onPressed: onApplyLeave,
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Application History'),
            _buildFilterChips(),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              const EmptyStateView(
                icon: Icons.assignment_late_outlined,
                title: 'No Applications',
                description: 'No leave applications match this filter.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) =>
                    LeaveRequestTile(request: requests[index]),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selectedFilterIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(i),
              selectedColor: AppColors.primaryAccent,
            ),
          );
        }),
      ),
    );
  }
}
