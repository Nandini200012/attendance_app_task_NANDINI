const db = require('../services/databaseService');
const config = require('../config');
const { sendSuccess, sendError } = require('../middleware/responseHandler');

/**
 * Controller handling employee profile retrieval.
 */
class EmployeeController {
  getMe(req, res, next) {
    try {
      const employeeId = req.headers['x-employee-id'] || config.defaultEmployeeId;
      const employee = db.getEmployeeById(employeeId);

      if (!employee) {
        return sendError(res, `Employee with ID '${employeeId}' was not found.`, 'Employee Not Found', 404);
      }

      return sendSuccess(res, employee, 'Employee Profile', 'Employee profile retrieved successfully');
    } catch (err) {
      next(err);
    }
  }

  getAll(req, res, next) {
    try {
      const employees = db.getEmployees();
      return sendSuccess(res, employees, 'Employees List', 'All employees retrieved successfully');
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new EmployeeController();

