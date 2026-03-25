/// Defines how a cache consumer should balance freshness vs. speed.
///
/// - [cacheFirst]: serve cache immediately; fall back to network on miss.
/// - [networkFirst]: always try network; fall back to cache on failure.
/// - [cacheOnly]: never touch network; fail if cache miss.
/// - [networkOnly]: never touch cache; always fresh data.
/// - [staleWhileRevalidate]: serve stale cache instantly, refresh in background.
enum CachePolicy {
  cacheFirst,
  networkFirst,
  cacheOnly,
  networkOnly,
  staleWhileRevalidate,
}
