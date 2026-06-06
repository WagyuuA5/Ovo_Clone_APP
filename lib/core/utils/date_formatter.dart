import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullFormatter =
      DateFormat('d MMMM yyyy, HH:mm', 'id');
  static final DateFormat _shortFormatter = DateFormat('d MMM yyyy', 'id');
  static final DateFormat _timeFormatter = DateFormat('HH:mm', 'id');
  static final DateFormat _monthFormatter = DateFormat('MMMM yyyy', 'id');

  /// Full date and time.
  /// Example: DateTime(2025, 6, 6, 14, 30) → '6 Juni 2025, 14:30'
  static String format(DateTime date) {
    return _fullFormatter.format(date);
  }

  /// Short date without time.
  /// Example: DateTime(2025, 6, 6) → '6 Jun 2025'
  static String formatShort(DateTime date) {
    return _shortFormatter.format(date);
  }

  /// Time only.
  /// Example: DateTime(2025, 6, 6, 14, 30) → '14:30'
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Relative human-readable date in Indonesian.
  /// - Same day → 'Hari ini'
  /// - Previous day → 'Kemarin'
  /// - 2-6 days ago → 'X hari lalu'
  /// - Older → short date format
  static String formatRelative(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDay = DateTime(date.year, date.month, date.day);
    final int diffDays = today.difference(targetDay).inDays;

    if (diffDays == 0) return 'Hari ini';
    if (diffDays == 1) return 'Kemarin';
    if (diffDays <= 6) return '$diffDays hari lalu';
    return formatShort(date);
  }

  /// Month and year.
  /// Example: DateTime(2025, 6, 1) → 'Juni 2025'
  static String formatMonth(DateTime date) {
    return _monthFormatter.format(date);
  }
}
