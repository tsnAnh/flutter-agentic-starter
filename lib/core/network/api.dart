import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

import '../error.dart';
import '../flavor_configurations.dart';
import 'status_code.dart';

abstract base class Api {
  final Dio dio;

  const Api(this.dio);

  Future<Either<NetworkError, T>> withTimeoutRequest<T>(
      Future<T> Function() request) async {
    try {
      final either = await TaskEither<Object, T>.tryCatch(
        () => request(),
        (err, _) => err,
      ).run().timeout(
        Duration(milliseconds: ConfigurationProfile.current.connectTimeout),
      );
      return either.mapLeft((err) => mapErrorToNetworkError(err));
    } on TimeoutException catch (timeoutException) {
      return Either.left(Timeout(exception: timeoutException));
    }
  }

  Future<Option<T>> withTimeoutRequestOption<T>(
      Future<T> Function() request) async {
    try {
      final either = await TaskEither<Object, T>.tryCatch(
        () => request(),
        (err, _) => err,
      ).run().timeout(
        Duration(milliseconds: ConfigurationProfile.current.connectTimeout),
      );
      return either.toOption();
    } on TimeoutException {
      return Option.none();
    }
  }

  NetworkError mapErrorToNetworkError(Object? error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == null) return UnknownNetworkError();

      switch (code) {
        case NetworkStatusCode.notFound:
          return NotFound(exception: error);
        case NetworkStatusCode.badRequest:
          return BadRequest(exception: error);
        case NetworkStatusCode.forbidden:
          return Forbidden(exception: error);
        case NetworkStatusCode.internalServerError:
          return InternalServerError(exception: error);
        case NetworkStatusCode.unauthorized:
          return Unauthorized(exception: error);
        default:
          return UnknownNetworkError();
      }
    } else if (error is TimeoutException) {
      return Timeout(exception: error);
    }

    // TODO: Add more exception
    return UnknownNetworkError();
  }
}
