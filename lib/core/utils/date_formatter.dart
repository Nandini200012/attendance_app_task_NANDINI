/// Utility class for formatting dates and timestamps consistently across the app.
///
/// Implemented using standard Dart DateTime capabilities to avoid heavy external dependencies.
abstract final class DateFormatter {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Formats date as '16 Nov 2026'
  static String formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  /// Formats date with weekday, e.g. 'Mon, 16 Nov 2026'
  static String formatDateWithDay(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    return '$weekday, ${formatShortDate(date)}';
  }

  /// Formats time in 12-hour AM/PM format, e.g. '09:15 AM'
  static String formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(
      2,
      '0',
    );
    return '$standardHour:$minute $period';
  }

  /// Formats full timestamp with seconds, e.g. '16 Nov 2026, 09:15:32 AM'
  static String formatTimestamp(DateTime date) {
    final second = date.second.toString().padLeft(2, '0');
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(
      2,
      '0',
    );
    return '${formatShortDate(date)}, $standardHour:$minute:$second $period';
  }
}
