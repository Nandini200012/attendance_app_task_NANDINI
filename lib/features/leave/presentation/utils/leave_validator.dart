import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/leave_model.dart';

/// Validation logic for employee leave applications.
class LeaveValidator {
  static String? validateDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required int requestedDays,
    required LeaveType selectedType,
    required LeaveBalance balance,
    List<LeaveRequest>? existingRequests,
  }) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    if (startDate.isBefore(todayNorm)) {
      return 'Start date cannot be before the current company date.';
    }
    if (endDate.isBefore(startDate)) {
      return 'End date cannot be before the start date.';
    }
    if (requestedDays <= 0) {
      return 'Please select a valid date range.';
    }
    final quota = selectedType == LeaveType.casual
        ? balance.casualAvailable
        : balance.sickAvailable;
    if (requestedDays > quota) {
      return 'Requested days ($requestedDays) exceed the available balance ($quota available).';
    }

    if (existingRequests != null) {
      for (final req in existingRequests) {
        if (req.status == LeaveStatus.pending ||
            req.status == LeaveStatus.approved) {
          final rStart = DateTime(req.startDate.year, req.startDate.month, req.startDate.day);
          final rEnd = DateTime(req.endDate.year, req.endDate.month, req.endDate.day);
          final sNorm = DateTime(startDate.year, startDate.month, startDate.day);
          final eNorm = DateTime(endDate.year, endDate.month, endDate.day);

          if (!sNorm.isAfter(rEnd) && !eNorm.isBefore(rStart)) {
            if (sNorm == rStart && eNorm == rEnd) {
              return 'You already applied for leave on this date (${req.startDate.day}/${req.startDate.month}) with status ${req.status.label}.';
            }
            return 'Dates overlap with an existing ${req.status.label} leave request (${req.startDate.day}/${req.startDate.month} - ${req.endDate.day}/${req.endDate.month}).';
          }
        }
      }
    }
    return null;
  }

  static String? validate({
    required DateTime startDate,
    required DateTime endDate,
    required int requestedDays,
    required String reason,
    required LeaveType selectedType,
    required LeaveBalance balance,
    List<LeaveRequest>? existingRequests,
  }) {
    final dateErr = validateDateRange(
      startDate: startDate,
      endDate: endDate,
      requestedDays: requestedDays,
      selectedType: selectedType,
      balance: balance,
      existingRequests: existingRequests,
    );
    if (dateErr != null) return dateErr;

    final cleanReason = reason.replaceAll(RegExp(r'\s'), '');
    if (cleanReason.length < AppConstants.minLeaveReasonLength) {
      return 'Reason must contain at least ${AppConstants.minLeaveReasonLength} non-whitespace characters.';
    }
    return null;
  }

  static bool isValid({
    required DateTime startDate,
    required DateTime endDate,
    required int requestedDays,
    required String reason,
    required LeaveType selectedType,
    required LeaveBalance balance,
    List<LeaveRequest>? existingRequests,
  }) =>
      validate(
        startDate: startDate,
        endDate: endDate,
        requestedDays: requestedDays,
        reason: reason,
        selectedType: selectedType,
        balance: balance,
        existingRequests: existingRequests,
      ) ==
      null;
}
