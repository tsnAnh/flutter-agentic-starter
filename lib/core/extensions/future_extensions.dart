/// Future utility extensions for timing and safety wrappers.
extension FutureExtensions<T> on Future<T> {
  /// Ensures the future takes at least [minDuration] before completing.
  /// Useful for preventing UI flicker on fast operations.
  Future<T> withMinDuration(Duration minDuration) async {
    final results = await Future.wait<dynamic>([this, Future<void>.delayed(minDuration)]);
    return results[0] as T;
  }

  /// Completes with a [TimeoutException] if the future exceeds [duration].
  Future<T> withTimeout(Duration duration, {T Function()? onTimeout}) =>
      timeout(duration, onTimeout: onTimeout);

  /// Ignores any error thrown by this future (completes silently).
  Future<void> get ignoreError => catchError((_) {});
}

/// Nullable future extensions.
extension NullableFutureExtensions<T> on Future<T?> {
  /// Returns [fallback] if the future resolves to null.
  Future<T> orElse(T fallback) async => (await this) ?? fallback;
}
