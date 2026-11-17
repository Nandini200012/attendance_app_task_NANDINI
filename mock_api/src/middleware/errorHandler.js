const { sendError } = require('./responseHandler');

/**
 * Global Express error handling middleware.
 */
function errorHandler(err, req, res, next) {
  console.error('Unhandled API Error:', err);
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';
  return sendError(res, message, 'Server Error', status);
}

module.exports = errorHandler;

