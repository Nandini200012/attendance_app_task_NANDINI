import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Central API routing and network configuration constants for REBS HRMS.
abstract final class ApiConstants {
  /// Base endpoint URL for the REBS Node.js mock backend service.
  /// Resolves to:
  /// 1. `--dart-define=API_BASE_URL=...` when explicitly passed.
  /// 2. 'http://10.0.2.2:3000' on Android emulator by default.
  /// 3. 'http://localhost:3000' on iOS, macOS, Web, and automated tests.
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  /// Endpoint path for fetching the authenticated employee's profile.
  static const String employeeMe = '/employee/me';

  /// Endpoint path for querying monthly attendance records.
  static const String attendance = '/attendance';

  /// Endpoint path for posting check-in and check-out telemetry events.
  static const String attendanceEvents = '/attendance/events';

  /// Endpoint path for retrieving casual and sick leave quotas.
  static const String leaveBalance = '/leave/balance';

  /// Endpoint path for fetching or submitting employee leave requests.
  static const String leaveRequests = '/leave/requests';

  /// Health check endpoint path.
  static const String health = '/health';

  /// Global HTTP client timeout duration.
  static const Duration connectionTimeout = Duration(seconds: 8);
}
