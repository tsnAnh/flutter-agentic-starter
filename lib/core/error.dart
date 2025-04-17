sealed class DataSourceError {
  final Exception exception;

  const DataSourceError({required this.exception});
}

sealed class DatabaseError extends DataSourceError {
  const DatabaseError({required super.exception});
}

sealed class NetworkError extends DataSourceError {
  const NetworkError({required super.exception});
}

// Unknown error singleton
final class UnknownNetworkError extends NetworkError {
  const UnknownNetworkError._({required super.exception});

  static late final UnknownNetworkError? _instance;

  factory UnknownNetworkError() =>
      _instance ??= UnknownNetworkError._(exception: Exception('Unknown Network Error'));
}

final class NotFound extends NetworkError {
  const NotFound({required super.exception});
}

final class InternalServerError extends NetworkError {
  const InternalServerError({required super.exception});
}

final class Unauthorized extends NetworkError {
  const Unauthorized({required super.exception});
}

final class BadRequest extends NetworkError {
  const BadRequest({required super.exception});
}

final class Timeout extends NetworkError {
  const Timeout({required super.exception});
}

final class Forbidden extends NetworkError {
  const Forbidden({required super.exception});
}
