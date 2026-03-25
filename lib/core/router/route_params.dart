import 'package:go_router/go_router.dart';

/// Type-safe extraction helpers for [GoRouterState] path and query parameters.
///
/// Usage:
/// ```dart
/// final id = state.intParam('id');           // path parameter
/// final name = state.stringParam('name');    // path parameter
/// final active = state.boolQuery('active');  // query parameter
/// final page = state.intQuery('page');       // query parameter
/// ```
extension GoRouterStateX on GoRouterState {
  /// Extracts a path parameter as [int], returns `null` if missing or invalid.
  int? intParam(String key) => int.tryParse(pathParameters[key] ?? '');

  /// Extracts a path parameter as [String], returns `null` if absent.
  String? stringParam(String key) => pathParameters[key];

  /// Extracts a query parameter as [bool]; `true` only when value == `'true'`.
  bool boolQuery(String key) => uri.queryParameters[key] == 'true';

  /// Extracts a query parameter as [int], returns `null` if missing or invalid.
  int? intQuery(String key) =>
      int.tryParse(uri.queryParameters[key] ?? '');

  /// Extracts a query parameter as [String], returns `null` if absent.
  String? stringQuery(String key) => uri.queryParameters[key];

  /// Extracts a query parameter as [double], returns `null` if missing or invalid.
  double? doubleQuery(String key) =>
      double.tryParse(uri.queryParameters[key] ?? '');
}
