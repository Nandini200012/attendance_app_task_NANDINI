const express = require('express');
const router = express.Router();
const employeeController = require('../controllers/employeeController');

router.get('/me', (req, res, next) => employeeController.getMe(req, res, next));
router.get('/', (req, res, next) => employeeController.getAll(req, res, next));

module.exports = router;

