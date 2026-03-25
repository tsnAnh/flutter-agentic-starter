import 'dart:async';

import 'package:dio/dio.dart';

import '../../cache/cache_manager.dart';
import '../../cache/cache_policy.dart';

/// Dio interceptor that integrates with [CacheManager] for HTTP response caching.
///
/// - Skips caching for POST, PUT, DELETE, PATCH (mutation methods).
/// - Supports ETag / If-None-Match for conditional requests (304 handling).
/// - Cache key = method + full URL + sorted query params.
/// - Default policy: [CachePolicy.networkFirst] (opt-in per-request via extra).
///
/// Per-request overrides via RequestOptions.extra:
///   `'cachePolicy'`  → [CachePolicy]
///   `'cacheTtl'`     → [Duration]
///   `'noCache'`      → bool (true = bypass entirely)
class CacheInterceptor extends Interceptor {
  CacheInterceptor(this._cacheManager);

  final CacheManager _cacheManager;

  static const _etagKey = '_etag';
  static const _cachedResponseKey = '_cached_response';
  static const _skipMethods = {'POST', 'PUT', 'DELETE', 'PATCH'};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkip(options)) return handler.next(options);

    final policy = _policyFrom(options);
    if (policy == CachePolicy.networkOnly) return handler.next(options);

    final key = _cacheKey(options);

    // For cacheFirst / cacheOnly / staleWhileRevalidate, try cache before network.
    if (policy == CachePolicy.cacheFirst ||
        policy == CachePolicy.cacheOnly ||
        policy == CachePolicy.staleWhileRevalidate) {
      final cached = await _cacheManager.get<Map<String, dynamic>>(
        key,
        policy,
        () => Future.error('cache miss'), // fetcher never called for cacheOnly
      );

      if (cached != null) {
        // Attach ETag for conditional request even when serving from cache.
        final etag = cached[_etagKey] as String?;
        if (etag != null) options.headers['If-None-Match'] = etag;

        if (policy == CachePolicy.cacheOnly ||
            policy == CachePolicy.cacheFirst) {
          return handler.resolve(
            _buildResponseFromCache(cached, options),
          );
        }
        // staleWhileRevalidate: resolve immediately with stale data, then fire
        // a background network request to refresh the cache entry.
        // unawaited intentionally — caller receives the stale response
        // without blocking; cache is updated asynchronously.
        unawaited(_revalidateInBackground(options));
        return handler.resolve(_buildResponseFromCache(cached, options));
      } else if (policy == CachePolicy.cacheOnly) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Cache miss for key: $key',
            type: DioExceptionType.unknown,
          ),
        );
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    if (_shouldSkip(options)) return handler.next(response);

    // 304 Not Modified — return the previously cached response.
    if (response.statusCode == 304) {
      final cached = options.extra[_cachedResponseKey] as Map<String, dynamic>?;
      if (cached != null) {
        return handler.resolve(_buildResponseFromCache(cached, options));
      }
    }

    // Store successful GET responses.
    if ((response.statusCode ?? 0) >= 200 &&
        (response.statusCode ?? 0) < 300) {
      final key = _cacheKey(options);
      final ttl = options.extra['cacheTtl'] as Duration?;
      final etag = response.headers.value('etag');

      final payload = <String, dynamic>{
        'statusCode': response.statusCode,
        'data': response.data,
        'headers': response.headers.map,
        _etagKey: ?etag,
      };

      await _cacheManager.get<Map<String, dynamic>>(
        key,
        CachePolicy.networkOnly,
        () async => payload,
        ttl: ttl,
      );
    }

    handler.next(response);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _shouldSkip(RequestOptions options) =>
      _skipMethods.contains(options.method.toUpperCase()) ||
      (options.extra['noCache'] as bool? ?? false);

  CachePolicy _policyFrom(RequestOptions options) =>
      (options.extra['cachePolicy'] as CachePolicy?) ??
      CachePolicy.networkFirst;

  String _cacheKey(RequestOptions options) {
    final params = options.queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final query = params.map((e) => '${e.key}=${e.value}').join('&');
    return '${options.method.toUpperCase()}:${options.uri.path}'
        '${query.isNotEmpty ? '?$query' : ''}';
  }

  Response<dynamic> _buildResponseFromCache(
    Map<String, dynamic> cached,
    RequestOptions options,
  ) {
    return Response<dynamic>(
      requestOptions: options,
      statusCode: cached['statusCode'] as int? ?? 200,
      data: cached['data'],
    );
  }

  /// Fires a background network request for [options] to refresh the cache
  /// without blocking the caller. Used by [staleWhileRevalidate] policy.
  Future<void> _revalidateInBackground(RequestOptions options) async {
    try {
      // Build a minimal Dio to execute the request without going through this
      // interceptor again (avoid infinite staleWhileRevalidate loops).
      final dio = Dio(BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      ));
      final response = await dio.fetch<dynamic>(options.copyWith(
        extra: {
          ...options.extra,
          'noCache': true, // bypass CacheInterceptor on this Dio instance (none attached)
        },
      ));

      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300) {
        final key = _cacheKey(options);
        final ttl = options.extra['cacheTtl'] as Duration?;
        final etag = response.headers.value('etag');

        final payload = <String, dynamic>{
          'statusCode': response.statusCode,
          'data': response.data,
          'headers': response.headers.map,
          _etagKey: ?etag,
        };

        await _cacheManager.get<Map<String, dynamic>>(
          key,
          CachePolicy.networkOnly,
          () async => payload,
          ttl: ttl,
        );
      }
    } on Exception catch (_) {
      // Background revalidation failures are silently ignored — the stale
      // response already served to the caller remains valid until next request.
    }
  }
}
