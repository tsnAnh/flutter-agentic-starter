import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../flavor_configurations.dart';

/// Logs Dio request/response details in dev and staging flavors only.
///
/// Auth-related headers are redacted before logging — never log tokens.
/// Production builds emit nothing from this interceptor.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({Logger? logger})
      : _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  /// Flavors where logging is active.
  static const _loggingFlavors = {'development', 'staging'};

  /// Header keys whose values are always redacted.
  static const _sensitiveHeaders = {
    'authorization',
    'x-api-key',
    'cookie',
    'set-cookie',
  };

  bool get _isEnabled =>
      _loggingFlavors.contains(ConfigurationProfile.current.name);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isEnabled) {
      _logger.d(
        '[REQ] ${options.method} ${options.uri}\n'
        'Headers: ${_redactHeaders(options.headers)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isEnabled) {
      _logger.i(
        '[RES] ${response.statusCode} '
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isEnabled) {
      _logger.e(
        '[ERR] ${err.type.name} '
        '${err.requestOptions.method} ${err.requestOptions.uri}\n'
        'Message: ${err.message}',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _sensitiveHeaders.contains(entry.key.toLowerCase())
            ? '***REDACTED***'
            : entry.value,
    };
  }
}
