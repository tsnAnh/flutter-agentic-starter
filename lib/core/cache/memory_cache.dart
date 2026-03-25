/// In-memory LRU cache with per-entry TTL support.
///
/// Evicts the least-recently-used entry when [maxSize] is exceeded.
/// Expired entries are treated as misses on [get].
class MemoryCache {
  MemoryCache({this.maxSize = 100, this.defaultTtl = const Duration(minutes: 5)});

  final int maxSize;
  final Duration defaultTtl;

  // LinkedHashMap insertion order = access order when we re-insert on hit.
  final _store = <String, _CacheEntry>{};

  /// Returns the cached value for [key], or null if missing / expired.
  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }

    // Promote to most-recently-used by re-inserting at the end.
    _store.remove(key);
    _store[key] = entry;

    return entry.value as T?;
  }

  /// Stores [value] under [key] with optional per-entry [ttl].
  void put<T>(String key, T value, {Duration? ttl}) {
    // Evict LRU entry if at capacity.
    if (_store.length >= maxSize && !_store.containsKey(key)) {
      _evictLru();
    }

    _store[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
  }

  /// Removes a specific entry.
  void evict(String key) => _store.remove(key);

  /// Clears all entries.
  void clear() => _store.clear();

  /// Returns true if a non-expired entry exists for [key].
  bool containsKey(String key) => get<Object>(key) != null;

  int get size => _store.length;

  void _evictLru() {
    if (_store.isEmpty) return;
    // First key in LinkedHashMap is least recently used.
    _store.remove(_store.keys.first);
  }
}

class _CacheEntry {
  _CacheEntry({required this.value, required this.expiresAt});

  final Object? value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
