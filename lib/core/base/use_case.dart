import 'package:fpdart/fpdart.dart';

import '../error.dart';

/// Marker class for use cases that require no input parameters.
class NoParams {
  const NoParams();
}

/// Abstract use case following the callable class pattern.
/// [Input] — the parameter type (use [NoParams] when none needed).
/// [Output] — the success value type.
///
/// Returns [Either<DataSourceError, Output>] so callers can
/// handle failures without try/catch.
abstract class UseCase<Input, Output> {
  const UseCase();

  Future<Either<DataSourceError, Output>> call(Input params);
}
