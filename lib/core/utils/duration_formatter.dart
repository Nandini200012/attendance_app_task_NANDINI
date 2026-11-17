/// Utility to format working durations into human-readable strings.
///
/// Converts Durations or minute counts into formats like '8h 15m'.
abstract final class DurationFormatter {
  /// Converts minutes into 'Xh Ym' format
  static String formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) return '0h 00m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final paddedMinutes = minutes.toString().padLeft(2, '0');
    return '${hours}h ${paddedMinutes}m';
  }

  /// Converts a [Duration] object into 'Xh Ym' format
  static String formatDuration(Duration duration) {
    return formatMinutes(duration.inMinutes);
  }

  /// Calculates duration between check-in and check-out timestamps
  static String calculateWorkingDuration({
    required DateTime checkIn,
    DateTime? checkOut,
  }) {
    final end = checkOut ?? DateTime.now();
    final difference = end.difference(checkIn);
    if (difference.isNegative) return '0h 00m';
    return formatDuration(difference);
  }
}
