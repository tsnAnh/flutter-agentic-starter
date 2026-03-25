import 'cache_policy.dart';
import 'disk_cache.dart';
import 'memory_cache.dart';

/// Orchestrates memory (L1) and disk (L2) caches according to [CachePolicy].
///
/// Registered via [RegisterModule] in get_it.dart (not annotated) to avoid
/// injectable trying to inject optional [MemoryCache] / [DiskCache] params.
class CacheManager {
  CacheManager({
    MemoryCache? memoryCache,
    DiskCache? diskCache,
  })  : _memory = memoryCache ?? MemoryCache(),
        _disk = diskCache ?? DiskCache();

  final MemoryCache _memory;
  final DiskCache _disk;

  bool _diskReady = false;

  /// Call once at app startup (after Hive.initFlutter).
  Future<void> init() async {
    await _disk.init();
    _diskReady = true;
  }

  /// Retrieves or fetches a value according to [policy].
  ///
  /// [key]     — cache key (typically URL + query string).
  /// [policy]  — how to balance cache vs. network.
  /// [fetcher] — async function that produces fresh data.
  /// [ttl]     — optional per-call TTL override.
  Future<T?> get<T>(
    String key,
    CachePolicy policy,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    switch (policy) {
      case CachePolicy.cacheFirst:
        return _cacheFirst<T>(key, fetcher, ttl: ttl);
      case CachePolicy.networkFirst:
        return _networkFirst<T>(key, fetcher, ttl: ttl);
      case CachePolicy.cacheOnly:
        return _fromCache<T>(key);
      case CachePolicy.networkOnly:
        return _networkOnly<T>(key, fetcher, ttl: ttl);
      case CachePolicy.staleWhileRevalidate:
        return _staleWhileRevalidate<T>(key, fetcher, ttl: ttl);
    }
  }

  /// Invalidates a single key from both layers.
  Future<void> invalidate(String key) async {
    _memory.evict(key);
    if (_diskReady) await _disk.evict(key);
  }

  /// Clears all entries from both layers.
  Future<void> clearAll() async {
    _memory.clear();
    if (_diskReady) await _disk.clear();
  }

  // ---------------------------------------------------------------------------
  // Private policy implementations
  // ---------------------------------------------------------------------------

  Future<T?> _cacheFirst<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    final cached = _fromCache<T>(key);
    if (cached != null) return cached;
    return _fetchAndStore<T>(key, fetcher, ttl: ttl);
  }

  Future<T?> _networkFirst<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    try {
      return await _fetchAndStore<T>(key, fetcher, ttl: ttl);
    } on Exception catch (_) {
      return _fromCache<T>(key);
    }
  }

  Future<T?> _networkOnly<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    final value = await fetcher();
    if (value != null) await _store<T>(key, value, ttl: ttl);
    return value;
  }

  Future<T?> _staleWhileRevalidate<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    final cached = _fromCache<T>(key);
    // Kick off background refresh without awaiting.
    _fetchAndStore<T>(key, fetcher, ttl: ttl).ignore();
    return cached; // may be null if first call
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  T? _fromCache<T>(String key) {
    return _memory.get<T>(key) ?? (_diskReady ? _disk.get<T>(key) : null);
  }

  Future<T?> _fetchAndStore<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    final value = await fetcher();
    if (value != null) await _store<T>(key, value, ttl: ttl);
    return value;
  }

  Future<void> _store<T>(String key, T value, {Duration? ttl}) async {
    _memory.put<T>(key, value, ttl: ttl);
    if (_diskReady) await _disk.put<T>(key, value, ttl: ttl);
  }
}
