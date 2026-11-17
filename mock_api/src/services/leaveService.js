const db = require('./databaseService');
const { calculateCalendarDays } = require('../utils/dateUtils');

/**
 * Service managing leave applications, quota calculations, and conflict detection.
 */
class LeaveService {
  getLeaveBalance(employeeId) {
    const balance = db.getLeaveBalance(employeeId);
    if (!balance) {
      const err = new Error(`Leave balance not found for employee '${employeeId}'.`);
      err.status = 404;
      throw err;
    }
    return balance;
  }

  getLeaveRequests(employeeId) {
    return db.getLeaveRequests(employeeId);
  }

  applyLeave(employeeId, requestData) {
    const leave_type = requestData.leave_type || requestData.leaveType;
    const start_date = requestData.start_date || requestData.startDate;
    const end_date = requestData.end_date || requestData.endDate;
    const number_of_days = requestData.number_of_days || requestData.numberOfDays;
    const reason = requestData.reason;

    // 1. Required fields
    if (!leave_type || !start_date || !end_date || !reason) {
      const err = new Error('Missing required fields: leave_type, start_date, end_date, and reason are mandatory.');
      err.status = 400;
      throw err;
    }

    // 2. Reason length check (min 10 non-whitespace characters)
    const cleanReason = String(reason).replace(/\s/g, '');
    if (cleanReason.length < 10) {
      const err = new Error('Reason must contain at least 10 non-whitespace characters.');
      err.status = 422;
      throw err;
    }

    // 3. Date validity & start <= end check
    const start = new Date(start_date);
    const end = new Date(end_date);
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      const err = new Error('Invalid date format for start_date or end_date. ISO YYYY-MM-DD expected.');
      err.status = 400;
      throw err;
    }
    if (end < start) {
      const err = new Error('End date cannot be earlier than start date.');
      err.status = 422;
      throw err;
    }

    // 4. Inclusive calendar days calculation
    const calculatedDays = calculateCalendarDays(start_date, end_date);
    const requestedDays = number_of_days && number_of_days > 0 ? number_of_days : calculatedDays;

    // 5. Balance check
    const balance = db.getLeaveBalance(employeeId);
    if (!balance) {
      const err = new Error('Leave quota not found for employee.');
      err.status = 404;
      throw err;
    }

    const normalizedType = leave_type.toLowerCase().includes('sick') ? 'sick' : 'casual';
    const typeBalance = balance.leave_type_breakdown[normalizedType];

    if (!typeBalance || typeBalance.available < requestedDays) {
      const available = typeBalance ? typeBalance.available : 0;
      const err = new Error(`Insufficient leave balance. Requested ${requestedDays} days exceeds available ${available} days.`);
      err.status = 422;
      throw err;
    }

    // 6. Overlapping requests validation
    const existingRequests = db.getLeaveRequests(employeeId);
    const hasOverlap = existingRequests.some((r) => {
      if (r.request_status === 'rejected') return false;
      const rStart = new Date(r.start_date);
      const rEnd = new Date(r.end_date);
      return start <= rEnd && end >= rStart;
    });

    if (hasOverlap) {
      const err = new Error('Overlapping leave request exists for the selected date range.');
      err.status = 409;
      throw err;
    }

    // 7. Deduct from available and add to pending
    typeBalance.available -= requestedDays;
    typeBalance.pending = (typeBalance.pending || 0) + requestedDays;
    balance.available_leave -= requestedDays;
    balance.pending_leave = (balance.pending_leave || 0) + requestedDays;
    db.updateLeaveBalance(employeeId, balance);

    // 8. Create leave request
    const newRequest = {
      request_id: `LEV-${Date.now().toString().slice(-6)}`,
      employee_id: employeeId,
      leave_type: normalizedType === 'sick' ? 'Sick Leave' : 'Casual Leave',
      start_date,
      end_date,
      number_of_days: requestedDays,
      reason,
      request_status: 'pending',
      applied_date: new Date().toISOString().split('T')[0],
      rejection_reason: null
    };

    return db.addLeaveRequest(newRequest);
  }
}

module.exports = new LeaveService();

