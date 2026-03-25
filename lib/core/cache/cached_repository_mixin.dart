import 'cache_manager.dart';
import 'cache_policy.dart';

/// Mixin for repository classes that want transparent cache support.
///
/// Requires the implementing class to provide a [cacheManager] instance.
///
/// Usage:
/// ```dart
/// class UserRepository with CachedRepositoryMixin {
///   UserRepository(this.cacheManager);
///
///   @override
///   final CacheManager cacheManager;
///
///   Future<User?> getUser(String id) => cachedGet(
///     'user:$id',
///     () => _api.fetchUser(id),
///     policy: CachePolicy.networkFirst,
///   );
/// }
/// ```
mixin CachedRepositoryMixin {
  /// Provide a [CacheManager] instance from the implementing class.
  CacheManager get cacheManager;

  /// Retrieves [T] from cache or fetches it fresh via [fetcher].
  Future<T?> cachedGet<T>(
    String key,
    Future<T> Function() fetcher, {
    CachePolicy policy = CachePolicy.networkFirst,
    Duration? ttl,
  }) {
    return cacheManager.get<T>(key, policy, fetcher, ttl: ttl);
  }

  /// Invalidates the cached value for [key].
  Future<void> invalidateCache(String key) => cacheManager.invalidate(key);

  /// Clears the entire cache.
  Future<void> clearCache() => cacheManager.clearAll();
}
