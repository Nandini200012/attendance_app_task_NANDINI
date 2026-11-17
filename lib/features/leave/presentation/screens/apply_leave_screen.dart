import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/widgets/action_dialog.dart';
import '../../../../shared/widgets/page_skeleton_view.dart';
import '../../bloc/leave_bloc.dart';
import '../../bloc/leave_event.dart';
import '../../bloc/leave_state.dart';
import '../utils/leave_validator.dart';
import '../widgets/apply_leave_body.dart';

/// Screen 6: Apply Leave form with strict validation and server error handling.
class ApplyLeaveScreen extends StatefulWidget {
  final Duration initialLoadingDuration;

  const ApplyLeaveScreen({
    super.key,
    this.initialLoadingDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  bool _isInitialLoading = true;
  Timer? _timer;
  LeaveType _selectedType = LeaveType.casual;
  late DateTime _startDate;
  late DateTime _endDate;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
    _timer = Timer(widget.initialLoadingDuration, () {
      if (mounted) setState(() => _isInitialLoading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reasonController.dispose();
    super.dispose();
  }

  int get _requestedDays => _endDate.isBefore(_startDate)
      ? 0
      : _endDate.difference(_startDate).inDays + 1;

  void _onStartDateChanged(DateTime d) => setState(() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _startDate = d.isBefore(today) ? today : DateTime(d.year, d.month, d.day);
    if (_endDate.isBefore(_startDate)) _endDate = _startDate;
  });

  void _onEndDateChanged(DateTime d) => setState(() {
    final norm = DateTime(d.year, d.month, d.day);
    _endDate = norm.isBefore(_startDate) ? _startDate : norm;
  });

  void _handleSubmit(LeaveBalance balance, List<LeaveRequest> existing) {
    final reason = _reasonController.text.trim();
    final err = LeaveValidator.validate(
      startDate: _startDate, endDate: _endDate, requestedDays: _requestedDays,
      reason: reason, selectedType: _selectedType, balance: balance, existingRequests: existing,
    );
    if (err != null) return _showError(err);

    context.read<LeaveBloc>().add(SubmitLeaveApplication(
      leaveType: _selectedType, startDate: _startDate, endDate: _endDate,
      numberOfDays: _requestedDays, reason: reason,
    ));
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveSubmitSuccess) {
          ActionDialog.show(context,
            title: 'Application Submitted',
            message: 'Leave request for $_requestedDays days registered.',
            confirmLabel: 'Done',
            onConfirm: () => Navigator.of(context).pop(),
          );
        } else if (state is LeaveSubmitFailure) {
          _showError(state.error);
        }
      },
      builder: (context, state) {
        final b = state is LeaveLoaded ? state.balance : LeaveBalance.empty;
        final existing = state is LeaveLoaded ? state.requests : <LeaveRequest>[];
        final dateErr = LeaveValidator.validateDateRange(
          startDate: _startDate, endDate: _endDate, requestedDays: _requestedDays,
          selectedType: _selectedType, balance: b, existingRequests: existing,
        );
        final isValid = dateErr == null && LeaveValidator.isValid(
          startDate: _startDate, endDate: _endDate, requestedDays: _requestedDays,
          reason: _reasonController.text.trim(), selectedType: _selectedType,
          balance: b, existingRequests: existing,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Apply for Leave', style: AppTypography.headingMedium)),
          body: _isInitialLoading
              ? const PageSkeletonView(firstCardHeight: 90, secondCardHeight: 180, listCount: 2, showHeader: false)
              : ApplyLeaveBody(
                  selectedType: _selectedType, balance: b, startDate: _startDate,
                  endDate: _endDate, requestedDays: _requestedDays,
                  reasonController: _reasonController, isSubmitting: state is LeaveSubmitting,
                  isValid: isValid, dateErrorMessage: dateErr,
                  onTypeChanged: (t) => setState(() => _selectedType = t),
                  onStartDateChanged: _onStartDateChanged,
                  onEndDateChanged: _onEndDateChanged,
                  onReasonChanged: () => setState(() {}),
                  onSubmit: () => _handleSubmit(b, existing),
                ),
        );
      },
    );
  }
}
