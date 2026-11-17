import 'dart:math';
import '../constants/app_constants.dart';

/// Haversine GPS distance calculator and geofence validator.
class LocationCalculator {
  static const double earthRadiusMeters = 6371e3;

  /// Calculates geographical distance in meters between two coordinates.
  static double calculateDistanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);

    final lat1 = _toRadians(startLatitude);
    final lat2 = _toRadians(endLatitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadiusMeters * c;
    return double.parse(distance.toStringAsFixed(1));
  }

  /// Calculates distance from given coordinates to the configured office location.
  static double distanceFromOffice({
    required double latitude,
    required double longitude,
    double? officeLatitude,
    double? officeLongitude,
  }) {
    return calculateDistanceInMeters(
      startLatitude: latitude,
      startLongitude: longitude,
      endLatitude: officeLatitude ?? AppConstants.officeLatitude,
      endLongitude: officeLongitude ?? AppConstants.officeLongitude,
    );
  }

  /// Validates whether employee coordinates are within allowed office perimeter.
  static bool isWithinOfficeGeofence({
    required double latitude,
    required double longitude,
    double? customRadiusMeters,
  }) {
    final distance = distanceFromOffice(
      latitude: latitude,
      longitude: longitude,
    );
    final allowedRadius = customRadiusMeters ?? AppConstants.allowedRadiusMeters;
    return distance <= allowedRadius;
  }

  static double _toRadians(double degree) => degree * pi / 180.0;
}

