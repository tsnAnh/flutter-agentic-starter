/// Sealed state class representing async data lifecycle.
/// Use pattern matching to handle each state in UI layers.
sealed class DataState<T> {
  const DataState();
}

/// Initial / idle state — no load has been requested yet.
final class DataStateInitial<T> extends DataState<T> {
  const DataStateInitial();
}

/// Loading state — a request is in progress.
final class DataStateLoading<T> extends DataState<T> {
  const DataStateLoading();
}

/// Loaded state — request succeeded and [data] is available.
final class DataStateLoaded<T> extends DataState<T> {
  const DataStateLoaded(this.data);

  final T data;
}

/// Error state — request failed with a [message] and optional [error] object.
final class DataStateError<T> extends DataState<T> {
  const DataStateError(this.message, [this.error]);

  final String message;
  final Object? error;
}
