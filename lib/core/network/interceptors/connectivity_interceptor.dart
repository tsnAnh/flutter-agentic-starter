import 'package:dio/dio.dart';

import '../../connectivity/connectivity_service.dart';

/// Fail-fast interceptor — rejects requests immediately when the device is offline.
///
/// This prevents queuing requests that will inevitably time out.
/// Request queuing for offline scenarios is handled in Phase 8 (OfflineQueue).
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivityService);

  final ConnectivityService _connectivityService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_connectivityService.isOnline) {
      return handler.reject(
        DioException(
          requestOptions: options,
          message: 'No internet connection.',
          type: DioExceptionType.connectionError,
        ),
      );
    }
    handler.next(options);
  }
}
