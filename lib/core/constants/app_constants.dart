/// Global application constants for REBS HRMS.
///
/// Contains geofence thresholds, layout spacing tokens, and default parameters.
abstract final class AppConstants {
  /// Application display name
  static const String appName = 'REBS HRMS';

  /// Maximum allowed geofence radius for attendance check-in/out in meters (configurable)
  static double allowedRadiusMeters = 200.0;

  /// Office Headquarters location coordinates (Single Source of Truth)
  /// Temporary coordinates: 10.6940374, 76.7345539
  static double officeLatitude = 10.6940374;
  static double officeLongitude = 76.7345539;
  static String officeName = 'REBS HQ (Temporary Site)';

  /// Standard card corner radius
  static const double cardRadius = 16.0;

  /// Standard button corner radius
  static const double buttonRadius = 12.0;

  /// Horizontal content padding for screens
  static const double screenHorizontalPadding = 16.0;

  /// Minimum non-whitespace characters required for leave justification
  static const int minLeaveReasonLength = 10;
}
