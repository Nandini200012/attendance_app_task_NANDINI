/**
 * Central configuration for REBS HRMS Mock REST API.
 */
module.exports = {
  port: process.env.PORT || 3000,
  officeLocation: {
    name: 'REBS HQ (Temporary Site)',
    latitude: 10.6940374,
    longitude: 76.7345539,
    allowedRadiusMeters: 200.0
  },
  defaultEmployeeId: 'emp-001',
  defaultEmployeeCode: 'EMP-2048'
};

