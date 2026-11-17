const db = require('./databaseService');
const config = require('../config');
const { calculateDistanceInMeters } = require('../utils/distanceCalculator');
const { calculateWorkingHours, formatShortDate } = require('../utils/dateUtils');

/**
 * Service orchestrating attendance event processing, geofence verification,
 * duplicate detection, and daily rollups.
 */
class AttendanceService {
  getAttendanceHistory(employeeId, month) {
    return db.getAttendanceRecords(employeeId, month);
  }

  processAttendanceEvent(eventData) {
    const {
      event_id,
      employee_id,
      event_type,
      timestamp,
      latitude,
      longitude,
      location,
      device_info
    } = eventData;

    // 1. Required fields validation
    if (!event_id || !employee_id || !event_type || !timestamp) {
      const err = new Error('Missing required fields: event_id, employee_id, event_type, and timestamp are mandatory.');
      err.status = 400;
      throw err;
    }

    // 2. Event type validation
    if (event_type !== 'check_in' && event_type !== 'check_out') {
      const err = new Error("Invalid event_type. Must be 'check_in' or 'check_out'.");
      err.status = 400;
      throw err;
    }

    // 3. Duplicate event ID check
    const existingEvent = db.findAttendanceEventById(event_id);
    if (existingEvent) {
      const err = new Error(`Duplicate event detected. Event with ID '${event_id}' has already been processed.`);
      err.status = 409;
      throw err;
    }

    // 4. Timestamp parsing
    const eventTime = new Date(timestamp);
    if (isNaN(eventTime.getTime())) {
      const err = new Error('Invalid timestamp format. ISO-8601 string expected.');
      err.status = 400;
      throw err;
    }

    // 5. GPS Geofence validation
    let distanceMeters = 0;
    let isWithinGeofence = true;
    let rejectionReason = null;

    if (typeof latitude === 'number' && typeof longitude === 'number') {
      distanceMeters = calculateDistanceInMeters(
        latitude,
        longitude,
        config.officeLocation.latitude,
        config.officeLocation.longitude
      );

      if (distanceMeters > config.officeLocation.allowedRadiusMeters) {
        isWithinGeofence = false;
        rejectionReason = `Outside allowed geofence perimeter (${distanceMeters}m > ${config.officeLocation.allowedRadiusMeters}m limit).`;
      }
    }

    const eventStatus = isWithinGeofence ? 'synced' : 'rejected';
    const dateStr = formatShortDate(eventTime);

    // 6. Sequence validation against today's records if within geofence
    const existingRecords = db.getAttendanceRecords(employee_id, dateStr.substring(0, 7));
    const activeCheckedIn = existingRecords.find(
      (r) => r.attendance_date === dateStr && r.attendance_status === 'Checked In'
    );

    if (isWithinGeofence) {
      if (event_type === 'check_in' && activeCheckedIn) {
        const err = new Error(`Employee is currently checked in for date ${dateStr}. Please check out before checking in again.`);
        err.status = 422;
        throw err;
      }

      if (event_type === 'check_out') {
        if (!activeCheckedIn) {
          const err = new Error(`Cannot check out without an active check-in for date ${dateStr}.`);
          err.status = 422;
          throw err;
        }
      }
    }

    // 7. Store the attendance event
    const recordedEvent = {
      event_id,
      employee_id,
      event_type,
      timestamp: eventTime.toISOString(),
      latitude: latitude || config.officeLocation.latitude,
      longitude: longitude || config.officeLocation.longitude,
      distance_meters: distanceMeters,
      location: location || (isWithinGeofence ? 'REBS HQ' : 'Outside Office Radius'),
      device_info: device_info || 'Unknown Device',
      sync_status: eventStatus,
      rejection_reason: rejectionReason
    };
    db.addAttendanceEvent(recordedEvent);

    // 8. Update consolidated daily attendance records (supports multiple sessions)
    if (isWithinGeofence) {
      if (event_type === 'check_in') {
        const sessionSuffix = Date.now().toString().slice(-4);
        db.addAttendanceRecord({
          id: `REC-${dateStr.replace(/-/g, '')}-${sessionSuffix}`,
          employee_id,
          attendance_date: dateStr,
          check_in_time: eventTime.toISOString(),
          check_out_time: null,
          working_hours: '0h 00m',
          attendance_status: 'Checked In',
          location: 'REBS HQ',
          sync_status: 'Synced'
        });
      } else if (event_type === 'check_out' && activeCheckedIn) {
        const hours = calculateWorkingHours(activeCheckedIn.check_in_time, eventTime.toISOString());
        db.updateAttendanceRecord(activeCheckedIn.id, {
          check_out_time: eventTime.toISOString(),
          working_hours: hours,
          attendance_status: 'Checked Out',
          sync_status: 'Synced'
        });
      }
    }

    return {
      event_id,
      status: eventStatus,
      server_timestamp: new Date().toISOString(),
      distance_meters: distanceMeters,
      rejection_reason: rejectionReason,
      message: isWithinGeofence
        ? `Attendance ${event_type.replace('_', ' ')} recorded successfully.`
        : `Attendance rejected: ${rejectionReason}`
    };
  }
}

module.exports = new AttendanceService();

