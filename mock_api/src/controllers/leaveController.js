const leaveService = require('../services/leaveService');
const config = require('../config');
const { sendSuccess, sendError } = require('../middleware/responseHandler');

/**
 * Controller handling leave quotas, request history, and application submissions.
 */
class LeaveController {
  getBalance(req, res, next) {
    try {
      const employeeId = req.headers['x-employee-id'] || config.defaultEmployeeId;
      const balance = leaveService.getLeaveBalance(employeeId);
      return sendSuccess(res, balance, 'Leave Balance', 'Leave balance retrieved successfully');
    } catch (err) {
      if (err.status) {
        return sendError(res, err.message, 'Balance Not Found', err.status);
      }
      next(err);
    }
  }

  getRequests(req, res, next) {
    try {
      const employeeId = req.headers['x-employee-id'] || config.defaultEmployeeId;
      const requests = leaveService.getLeaveRequests(employeeId);
      return sendSuccess(res, requests, 'Leave Requests', `Retrieved ${requests.length} leave requests`);
    } catch (err) {
      next(err);
    }
  }

  createRequest(req, res, next) {
    try {
      const employeeId = req.body.employee_id || req.headers['x-employee-id'] || config.defaultEmployeeId;
      const created = leaveService.applyLeave(employeeId, req.body);
      return sendSuccess(res, created, 'Leave Application Submitted', 'Leave application queued successfully', 201);
    } catch (err) {
      if (err.status) {
        return sendError(res, err.message, 'Validation Failed', err.status);
      }
      next(err);
    }
  }
}

module.exports = new LeaveController();

