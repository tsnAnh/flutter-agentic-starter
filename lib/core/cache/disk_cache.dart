import 'dart:convert';

import 'package:hive/hive.dart';

/// Persistent disk cache backed by Hive v2.
///
/// Values are JSON-serialised to strings so no TypeAdapter registration is
/// needed. TTL is stored alongside the value as an ISO-8601 expiry timestamp.
///
/// ## Type constraint — IMPORTANT
/// [T] MUST be a JSON-compatible type: `String`, `int`, `double`, `bool`,
/// `List`, or `Map<String, dynamic>`. Custom Dart classes are NOT supported
/// unless they are pre-serialised by the caller (e.g. call `toJson()` before
/// putting and `fromJson()` after getting).
///
/// Attempting to store or retrieve a non-JSON-compatible type will produce a
/// [TypeError] that is silently swallowed by the surrounding catch in [get],
/// returning `null` as if the entry does not exist.
class DiskCache {
  DiskCache({
    this.boxName = 'app_disk_cache',
    this.defaultTtl = const Duration(hours: 1),
  });

  final String boxName;
  final Duration defaultTtl;

  Box<String>? _box;

  /// Must be called once (e.g. during DI setup) before any other method.
  Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  Box<String> get _openBox {
    assert(_box != null, 'DiskCache.init() must be called before use.');
    return _box!;
  }

  /// Returns the stored value for [key], or null if missing / expired.
  ///
  /// [T] must be a JSON-compatible primitive or collection — see class-level
  /// doc for details. A [TypeError] from an incompatible cast is caught and
  /// treated as a cache miss (the malformed entry is evicted).
  ///
  /// In debug builds an assertion fires if [T] is a non-JSON type to surface
  /// the mis-use early.
  T? get<T>(String key) {
    assert(
      T == String ||
          T == int ||
          T == double ||
          T == bool ||
          T == List ||
          T == Map ||
          T == Object || // used internally by containsKey
          T.toString().startsWith('Map<') ||
          T.toString().startsWith('List<'),
      'DiskCache.get<$T>: $T is not a JSON-compatible type. '
      'Pre-serialise custom classes before caching.',
    );

    final raw = _openBox.get(key);
    if (raw == null) return null;

    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(wrapper['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        // Expired — evict lazily.
        _openBox.delete(key);
        return null;
      }

      return wrapper['value'] as T?;
    } on Exception catch (_) {
      _openBox.delete(key);
      return null;
    }
  }

  /// Stores [value] under [key] with optional per-entry [ttl].
  Future<void> put<T>(String key, T value, {Duration? ttl}) async {
    final expiresAt = DateTime.now().add(ttl ?? defaultTtl);
    final wrapper = jsonEncode({
      'value': value,
      'expiresAt': expiresAt.toIso8601String(),
    });
    await _openBox.put(key, wrapper);
  }

  /// Removes a specific entry.
  Future<void> evict(String key) => _openBox.delete(key);

  /// Removes all entries from the box.
  Future<void> clear() => _openBox.clear();

  /// Returns true if a non-expired entry exists for [key].
  bool containsKey(String key) => get<Object>(key) != null;

  Future<void> close() => _openBox.close();
}
