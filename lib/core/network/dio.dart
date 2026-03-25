import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../auth/token_manager.dart';
import '../cache/cache_manager.dart';
import '../connectivity/connectivity_service.dart';
import '../extensions/duration.dart';
import '../flavor_configurations.dart';
import 'interceptors/authentication_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Provides two pre-configured [Dio] instances:
/// - [authDio]: includes [AuthenticationInterceptor] for authenticated endpoints.
/// - [dio]: for public/unauthenticated endpoints with cache support.
///
/// Interceptor order:
///   ConnectivityInterceptor → (CacheInterceptor on dio only) →
///   AuthInterceptor (authDio only) → RetryInterceptor → LoggingInterceptor
class DioClient {
  DioClient({
    ConnectivityService? connectivityService,
    CacheManager? cacheManager,
    TokenManager? tokenManager,
    LoggingInterceptor? loggingInterceptor,
    RetryConfig? retryConfig,
  }) {
    final baseOptions = createBaseOptions();

    final connectivityInterceptor = connectivityService != null
        ? ConnectivityInterceptor(connectivityService)
        : null;

    final logging = loggingInterceptor ?? LoggingInterceptor();

    // --- authDio: Connectivity → Auth → Retry → Logging ---
    final authRetry = RetryInterceptor(config: retryConfig);
    authDio = Dio(baseOptions);
    if (connectivityInterceptor != null) {
      authDio.interceptors.add(connectivityInterceptor);
    }
    if (tokenManager != null) {
      // Non-auth Dio used for refresh calls to avoid interceptor loops.
      final nonAuthForRefresh = Dio(baseOptions);
      authDio.interceptors.add(
        AuthenticationInterceptor(
          tokenManager: tokenManager,
          refreshDio: nonAuthForRefresh,
          refreshPath: '/auth/refresh',
        ),
      );
    }
    authDio.interceptors.add(authRetry);
    authDio.interceptors.add(logging);
    authRetry.attachDio(authDio);

    // --- dio: Connectivity → Cache → Retry → Logging ---
    final nonAuthRetry = RetryInterceptor(config: retryConfig);
    dio = Dio(baseOptions);
    if (connectivityInterceptor != null) {
      dio.interceptors.add(connectivityInterceptor);
    }
    if (cacheManager != null) {
      dio.interceptors.add(CacheInterceptor(cacheManager));
    }
    dio.interceptors.add(nonAuthRetry);
    dio.interceptors.add(logging);
    nonAuthRetry.attachDio(dio);
  }

  BaseOptions createBaseOptions() {
    final config = ConfigurationProfile.current;
    return BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout.milliseconds,
      receiveTimeout: config.receiveTimeout.milliseconds,
      sendTimeout: config.sendTimeout.milliseconds,
    );
  }

  late final Dio authDio;
  late final Dio dio;
}

const authDio = Named('AuthDio');
const nonAuthDio = Named('NonAuthDio');
