/**
 * Standardized response formatter for REBS HRMS API.
 */
function sendSuccess(res, data, title = 'Success', body = 'Data retrieved successfully', httpStatus = 200) {
  return res.status(httpStatus).json({
    StatusCode: 6000,
    message: {
      title,
      body
    },
    data: data !== undefined ? data : {}
  });
}

function sendError(res, body = 'Something went wrong', title = 'Error', httpStatus = 400) {
  return res.status(httpStatus).json({
    StatusCode: 6001,
    message: {
      title,
      body
    },
    data: null
  });
}

module.exports = {
  sendSuccess,
  sendError
};

