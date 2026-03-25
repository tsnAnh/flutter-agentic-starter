import 'package:intl/intl.dart';

/// DateTime utility extensions for common date comparisons and formatting.
extension DateTimeExtensions on DateTime {
  /// Returns true if this date falls on today (local time).
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date falls on yesterday (local time).
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns a human-readable relative time string (e.g. "3 hours ago").
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return format('MMM d, y');
  }

  /// Returns midnight (00:00:00.000) of this date.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the last moment (23:59:59.999) of this date.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Formats the date using the given [pattern] (e.g. 'yyyy-MM-dd').
  String format(String pattern, {String? locale}) =>
      DateFormat(pattern, locale).format(this);
}
