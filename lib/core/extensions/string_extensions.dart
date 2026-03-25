/// String utility extensions for common transformations and validation.
extension StringExtensions on String {
  /// Capitalizes the first character of the string.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns true if the string is a valid email address.
  bool get isEmail => RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Returns true if the string is a valid HTTP/HTTPS URL.
  bool get isUrl => RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}'
        r'\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$',
      ).hasMatch(this);

  /// Truncates to [maxLength] characters, appending [ellipsis] if trimmed.
  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  /// Converts the string to a URL-friendly slug (lowercase, hyphens).
  String get toSlug => toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns the string or an empty string if null.
  String get orEmpty => this ?? '';
}
