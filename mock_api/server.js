const express = require('express');
const cors = require('cors');
const config = require('./src/config');
const routes = require('./src/routes');
const requestLogger = require('./src/middleware/requestLogger');
const errorHandler = require('./src/middleware/errorHandler');
const { sendError } = require('./src/middleware/responseHandler');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

// API routes mounted at root and /api
app.use('/', routes);

// 404 Handler for undefined routes
app.use((req, res) => {
  return sendError(res, `Route '${req.originalUrl}' not found on REBS HRMS API.`, 'Not Found', 404);
});

// Centralized error handler
app.use(errorHandler);

// Start server
const server = app.listen(config.port, () => {
  console.log(`=======================================================`);
  console.log(` REBS HRMS Mock REST API Server running on port ${config.port}`);
  console.log(` Health Check: http://localhost:${config.port}/health`);
  console.log(` Employee:     http://localhost:${config.port}/employee/me`);
  console.log(` Attendance:   http://localhost:${config.port}/attendance`);
  console.log(` Leave:        http://localhost:${config.port}/leave/balance`);
  console.log(`=======================================================`);
});

module.exports = { app, server };

