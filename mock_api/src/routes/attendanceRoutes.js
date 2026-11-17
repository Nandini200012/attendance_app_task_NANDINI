const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendanceController');

router.get('/', (req, res, next) => attendanceController.getAttendance(req, res, next));
router.post('/events', (req, res, next) => attendanceController.postEvent(req, res, next));

module.exports = router;

