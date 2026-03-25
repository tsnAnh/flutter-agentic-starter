import 'dart:math';

import 'package:dio/dio.dart';

/// Configuration for [RetryInterceptor].
class RetryConfig {
  const RetryConfig({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.retryOnStatusCodes = const [500, 502, 503, 504],
  });

  final int maxRetries;
  final Duration retryDelay;
  final double backoffMultiplier;

  /// HTTP status codes that trigger a retry. 4xx codes are never retried.
  final List<int> retryOnStatusCodes;
}

/// Automatically retries failed requests on 5xx responses and network errors.
///
/// - Never retries 4xx (client errors).
/// - Uses exponential backoff with a small random jitter to avoid thundering herd.
/// - Attach after [ConnectivityInterceptor] and before [LoggingInterceptor].
class RetryInterceptor extends Interceptor {
  RetryInterceptor({RetryConfig? config, Dio? dio})
      : _config = config ?? const RetryConfig(),
        _dio = dio;

  final RetryConfig _config;

  /// Optional Dio reference — set after construction when DioClient builds itself.
  Dio? _dio;

  void attachDio(Dio dio) => _dio = dio;

  static const _attemptKey = '_retry_attempt';
  static final _rng = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final currentAttempt =
        (err.requestOptions.extra[_attemptKey] as int?) ?? 0;

    if (!_shouldRetry(err, currentAttempt)) {
      return handler.next(err);
    }

    final delay = _calculateDelay(currentAttempt);
    await Future<void>.delayed(delay);

    err.requestOptions.extra[_attemptKey] = currentAttempt + 1;

    try {
      final response = await _dio!.fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException err, int attempt) {
    if (_dio == null) return false;
    if (attempt >= _config.maxRetries) return false;

    final statusCode = err.response?.statusCode;

    // Network / timeout errors — no status code available.
    if (statusCode == null) {
      return err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.sendTimeout;
    }

    // Only retry on explicitly configured 5xx codes; never on 4xx.
    return statusCode >= 500 &&
        _config.retryOnStatusCodes.contains(statusCode);
  }

  Duration _calculateDelay(int attempt) {
    final base =
        _config.retryDelay.inMilliseconds * pow(_config.backoffMultiplier, attempt);
    // ±20 % jitter.
    final jitter = (_rng.nextDouble() * 0.4 - 0.2) * base;
    return Duration(milliseconds: (base + jitter).round().clamp(0, 30000));
  }
}
