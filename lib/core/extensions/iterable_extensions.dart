/// Iterable utility extensions for grouping, filtering, sorting and chunking.
extension IterableExtensions<T> on Iterable<T> {
  /// Groups elements by a key derived from [keyOf].
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final element in this) {
      map.putIfAbsent(keyOf(element), () => []).add(element);
    }
    return map;
  }

  /// Returns elements with distinct keys as produced by [keyOf].
  List<T> distinctBy<K>(K Function(T) keyOf) {
    final seen = <K>{};
    return where((e) => seen.add(keyOf(e))).toList();
  }

  /// Returns elements sorted by the comparable key from [keyOf].
  List<T> sortedBy<K extends Comparable<K>>(K Function(T) keyOf) =>
      toList()..sort((a, b) => keyOf(a).compareTo(keyOf(b)));

  /// Splits the iterable into chunks of [size].
  List<List<T>> chunked(int size) {
    assert(size > 0, 'Chunk size must be positive');
    final result = <List<T>>[];
    final list = toList();
    for (var i = 0; i < list.length; i += size) {
      result.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return result;
  }

  /// Returns the first element or null if the iterable is empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element or null if the iterable is empty.
  T? get lastOrNull => isEmpty ? null : last;
}
