/// Core custom exception types thrown across data layers.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Thrown when local device network or connectivity issues occur.
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection available']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when local Hive storage or cache operations fail.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when request payload fails validation criteria before sending.
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
