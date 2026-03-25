import 'dart:async';

import 'package:app_links/app_links.dart';

/// Handles incoming deep links and universal links via the app_links package.
///
/// Converts incoming [Uri] to GoRouter-compatible paths.
/// Configurable via [allowedHosts] and [allowedSchemes].
///
/// Registered via [RegisterModule] in get_it.dart (not annotated) to avoid
/// injectable trying to inject optional [List<String>] typed params.
class DeepLinkHandler {
  DeepLinkHandler({
    List<String>? allowedHosts,
    List<String>? allowedSchemes,
  })  : _allowedHosts = allowedHosts ?? const ['app.example.com'],
        _allowedSchemes = allowedSchemes ?? const ['https', 'myapp'],
        _appLinks = AppLinks();

  final AppLinks _appLinks;
  final List<String> _allowedHosts;
  final List<String> _allowedSchemes;

  /// Stream of validated incoming deep link [Uri]s after app is running.
  Stream<Uri> get onDeepLink => _appLinks.uriLinkStream.where(_isAllowed);

  /// Returns the initial deep link [Uri] that launched the app cold, if any.
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } on Exception {
      return null;
    }
  }

  /// Converts a validated deep link [Uri] to a GoRouter path string.
  ///
  /// Example: `https://app.example.com/feature/123?tab=overview`
  ///       → `/feature/123?tab=overview`
  ///
  /// Returns `null` if the URI does not map to a known route.
  String? mapDeepLinkToRoute(Uri uri) {
    if (!_isAllowed(uri)) return null;

    final path = uri.path.isEmpty ? '/' : uri.path;
    final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
    return '$path$query';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isAllowed(Uri uri) {
    final schemeOk = _allowedSchemes.contains(uri.scheme);
    // For http/https schemes validate host; custom schemes skip host check.
    final hostOk = (uri.scheme == 'http' || uri.scheme == 'https')
        ? _allowedHosts.contains(uri.host)
        : true;
    return schemeOk && hostOk;
  }
}
