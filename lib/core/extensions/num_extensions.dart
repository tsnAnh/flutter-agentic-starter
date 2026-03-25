import 'package:intl/intl.dart';

/// Numeric utility extensions for formatting and clamping.
extension NumExtensions on num {
  /// Formats the number as a currency string with the given [symbol].
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) =>
      NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits)
          .format(this);

  /// Formats the number in compact notation (e.g. 1.2K, 3.4M).
  String toCompact() => NumberFormat.compact().format(this);

  /// Clamps the value between [min] and [max] (inclusive).
  num clampRange(num min, num max) => clamp(min, max);
}

/// Integer convenience extensions.
extension IntExtensions on int {
  /// Returns a [Duration] of this many milliseconds.
  Duration get ms => Duration(milliseconds: this);

  /// Returns a [Duration] of this many seconds.
  Duration get seconds => Duration(seconds: this);

  /// Returns a [Duration] of this many minutes.
  Duration get minutes => Duration(minutes: this);
}
