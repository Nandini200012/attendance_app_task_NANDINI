import 'package:flutter/foundation.dart';

/// Centralized logger recording outgoing HTTP requests, parameters, and responses.
abstract final class NetworkLogger {
  /// Logs outgoing request details including endpoint, query params, and body.
  static void logRequest({
    required String method,
    required Uri uri,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚀 [API REQUEST] $method ${uri.path}');
    debugPrint('📍 Full URL: $uri');
    if (queryParams != null && queryParams.isNotEmpty) {
      debugPrint('🔍 Query Parameters: $queryParams');
    }
    if (body != null) {
      debugPrint('📦 Payload Parameters: $body');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Logs incoming HTTP response with status code and body.
  static void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String responseBody,
  }) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📥 [API RESPONSE $statusCode] $method ${uri.path}');
    debugPrint('📍 Full URL: $uri');
    debugPrint('📄 Response Body: $responseBody');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Logs network or HTTP level exceptions.
  static void logError({
    required String method,
    required Uri uri,
    required Object error,
  }) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ [API ERROR] $method ${uri.path}');
    debugPrint('📍 Full URL: $uri');
    debugPrint('⚠️ Failure: $error');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

