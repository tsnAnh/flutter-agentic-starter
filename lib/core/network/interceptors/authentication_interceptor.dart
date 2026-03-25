import 'dart:async';

import 'package:dio/dio.dart';

import '../../auth/token_manager.dart';

/// Callback invoked when a token refresh attempt fails.
///
/// The app should use this to force-logout the user.
typedef OnRefreshFailed = void Function();

/// Intercepts every request to inject a Bearer token and handles 401 responses
/// by refreshing the access token exactly once — even if multiple requests
/// fail concurrently.
///
/// Concurrent 401 handling strategy:
/// - A [Completer] acts as a mutex: the first failing request triggers refresh;
///   subsequent 401s wait on the same future and then retry with the new token.
/// - If refresh fails, all queued requests receive the error and [onRefreshFailed]
///   is called so the app can navigate to the login screen.
///
/// Registered manually via [DioClient] constructor — not auto-injectable because
/// [refreshPath] and [onRefreshFailed] are runtime values, not DI-resolvable.
///
/// Security: token values are NEVER logged inside this interceptor.
class AuthenticationInterceptor extends Interceptor {
  AuthenticationInterceptor({
    required TokenManager tokenManager,
    required Dio refreshDio,
    required String refreshPath,
    OnRefreshFailed? onRefreshFailed,
  })  : _tokenManager = tokenManager,
        _refreshDio = refreshDio,
        _refreshPath = refreshPath,
        _onRefreshFailed = onRefreshFailed;

  final TokenManager _tokenManager;

  /// A separate [Dio] instance used exclusively for the refresh call so that
  /// the refresh request does not pass through this interceptor again.
  final Dio _refreshDio;

  final String _refreshPath;
  final OnRefreshFailed? _onRefreshFailed;

  /// Non-null while a token refresh is in flight.
  Completer<bool>? _refreshCompleter;

  // ---------------------------------------------------------------------------
  // onRequest — inject Bearer token
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // onError — handle 401 with Completer lock
  // ---------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid retry loops for the refresh call itself.
    if (err.requestOptions.extra['_isRefreshRequest'] == true) {
      await _tokenManager.clearTokens();
      _onRefreshFailed?.call();
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return handler.next(err);
    }

    final bool refreshSucceeded;

    if (_refreshCompleter != null) {
      // Another request is already refreshing — wait for its outcome.
      refreshSucceeded = await _refreshCompleter!.future;
    } else {
      // This request is first — own the refresh.
      // try/finally guarantees the Completer is ALWAYS completed even if
      // _performRefresh throws an Error (not caught by `on Exception`).
      _refreshCompleter = Completer<bool>();
      try {
        refreshSucceeded = await _performRefresh();
      } finally {
        if (!_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
        _refreshCompleter = null;
      }
    }

    if (!refreshSucceeded) {
      return handler.next(err);
    }

    // Retry the original request with the new token.
    try {
      final retryOptions = err.requestOptions;
      final newToken = await _tokenManager.accessToken;
      if (newToken != null) {
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
      }
      // Use the refresh dio (without auth interceptor) to avoid interception loop.
      final response = await _refreshDio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Calls the refresh endpoint and saves new tokens on success.
  ///
  /// Returns `true` on success, `false` on any failure.
  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await _tokenManager.refreshToken;
      if (refreshToken == null) {
        await _tokenManager.clearTokens();
        _onRefreshFailed?.call();
        return false;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'_isRefreshRequest': true}),
      );

      final data = response.data;
      if (data == null) {
        await _tokenManager.clearTokens();
        _onRefreshFailed?.call();
        return false;
      }

      await _tokenManager.saveTokens(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String? ?? refreshToken,
        expiry: _parseExpiry(data),
      );
      return true;
    } on Exception catch (_) {
      await _tokenManager.clearTokens();
      _onRefreshFailed?.call();
      return false;
    }
  }

  /// Parses expiry from response map; defaults to 1 hour from now.
  DateTime _parseExpiry(Map<String, dynamic> data) {
    final raw = data['expires_at'] as String?;
    if (raw != null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    final expiresIn = data['expires_in'] as int?;
    return DateTime.now().add(Duration(seconds: expiresIn ?? 3600));
  }
}
