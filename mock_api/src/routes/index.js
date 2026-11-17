const express = require('express');
const router = express.Router();

const employeeRoutes = require('./employeeRoutes');
const attendanceRoutes = require('./attendanceRoutes');
const leaveRoutes = require('./leaveRoutes');

router.use('/employee', employeeRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/leave', leaveRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    StatusCode: 6000,
    message: { title: 'Healthy', body: 'REBS HRMS Mock REST API is online.' },
    data: { uptime: process.uptime(), timestamp: new Date().toISOString() }
  });
});

module.exports = router;

