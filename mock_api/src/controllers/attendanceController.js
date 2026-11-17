const attendanceService = require('../services/attendanceService');
const config = require('../config');
const { sendSuccess, sendError } = require('../middleware/responseHandler');

/**
 * Controller handling attendance history and punch event synchronization.
 */
class AttendanceController {
  getAttendance(req, res, next) {
    try {
      const employeeId = req.headers['x-employee-id'] || config.defaultEmployeeId;
      const month = req.query.month; // Optional YYYY-MM

      const records = attendanceService.getAttendanceHistory(employeeId, month);
      return sendSuccess(res, records, 'Attendance Records', `Retrieved ${records.length} records successfully`);
    } catch (err) {
      next(err);
    }
  }

  postEvent(req, res, next) {
    try {
      const employeeId = req.body.employee_id || req.headers['x-employee-id'] || config.defaultEmployeeId;
      const eventData = { ...req.body, employee_id: employeeId };

      const result = attendanceService.processAttendanceEvent(eventData);

      if (result.status === 'rejected') {
        return sendError(res, result.rejection_reason, 'Attendance Rejected', 422);
      }

      return sendSuccess(res, result, 'Attendance Event Synced', result.message, 201);
    } catch (err) {
      if (err.status) {
        return sendError(res, err.message, 'Event Validation Failed', err.status);
      }
      next(err);
    }
  }
}

module.exports = new AttendanceController();

