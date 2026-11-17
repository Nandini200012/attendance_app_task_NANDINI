const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, '../data/database.json');

/**
 * Service managing in-memory and file persistence for JSON seed database.
 */
class DatabaseService {
  constructor() {
    this.data = this._loadData();
  }

  _loadData() {
    try {
      const raw = fs.readFileSync(DB_PATH, 'utf-8');
      return JSON.parse(raw);
    } catch (err) {
      console.error('Failed to load database.json:', err);
      return {
        employees: [],
        leaveBalances: {},
        leaveRequests: [],
        attendanceRecords: [],
        attendanceEvents: []
      };
    }
  }

  save() {
    try {
      fs.writeFileSync(DB_PATH, JSON.stringify(this.data, null, 2), 'utf-8');
    } catch (err) {
      console.error('Failed to persist database.json:', err);
    }
  }

  getEmployeeById(id) {
    return this.data.employees.find((e) => e.id === id || e.employee_id === id);
  }

  getEmployees() {
    return this.data.employees;
  }

  getAttendanceRecords(employeeId, month) {
    return this.data.attendanceRecords.filter((rec) => {
      const matchesEmp =
        rec.employee_id === employeeId ||
        (employeeId === 'emp-001' && rec.employee_id === 'EMP-2048') ||
        (employeeId === 'EMP-2048' && rec.employee_id === 'emp-001');
      if (!month) return matchesEmp;
      return matchesEmp && rec.attendance_date.startsWith(month);
    });
  }

  addAttendanceRecord(record) {
    this.data.attendanceRecords.unshift(record);
    this.save();
    return record;
  }

  updateAttendanceRecord(id, updates) {
    const idx = this.data.attendanceRecords.findIndex((r) => r.id === id);
    if (idx !== -1) {
      this.data.attendanceRecords[idx] = { ...this.data.attendanceRecords[idx], ...updates };
      this.save();
      return this.data.attendanceRecords[idx];
    }
    return null;
  }

  getAttendanceEvents(employeeId) {
    return this.data.attendanceEvents.filter((ev) => ev.employee_id === employeeId);
  }

  addAttendanceEvent(event) {
    this.data.attendanceEvents.unshift(event);
    this.save();
    return event;
  }

  findAttendanceEventById(eventId) {
    return this.data.attendanceEvents.find((e) => e.event_id === eventId);
  }

  getLeaveBalance(employeeId) {
    return this.data.leaveBalances[employeeId] || null;
  }

  updateLeaveBalance(employeeId, balance) {
    this.data.leaveBalances[employeeId] = balance;
    this.save();
    return balance;
  }

  getLeaveRequests(employeeId) {
    return this.data.leaveRequests.filter((r) => r.employee_id === employeeId);
  }

  addLeaveRequest(request) {
    this.data.leaveRequests.unshift(request);
    this.save();
    return request;
  }
}

module.exports = new DatabaseService();

