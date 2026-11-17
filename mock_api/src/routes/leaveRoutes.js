const express = require('express');
const router = express.Router();
const leaveController = require('../controllers/leaveController');

router.get('/balance', (req, res, next) => leaveController.getBalance(req, res, next));
router.get('/requests', (req, res, next) => leaveController.getRequests(req, res, next));
router.post('/requests', (req, res, next) => leaveController.createRequest(req, res, next));

module.exports = router;

