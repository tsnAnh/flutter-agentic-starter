/// Package-free key/value storage for auth state.
///
/// Values live in memory only. Restarting the app clears all auth state.
///
/// Registered via [RegisterModule] in get_it.dart (not annotated) to avoid
/// injectable trying to auto-register app storage details.
class SecureStorageService {
  final Map<String, String> _storage = <String, String>{};

  /// Stores [value] under [key]. Both must be non-empty.
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  /// Returns the value stored under [key], or `null` if absent.
  Future<String?> read(String key) async => _storage[key];

  /// Removes the entry for [key]. No-op if the key does not exist.
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  /// Wipes all entries owned by this app.
  Future<void> deleteAll() async {
    _storage.clear();
  }
}
