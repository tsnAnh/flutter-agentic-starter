import 'package:fpdart/fpdart.dart';

import '../error.dart';

/// Abstract CRUD repository contract.
/// [T] — the entity type, [ID] — the primary key type.
///
/// All operations return [Either<DataSourceError, R>] so
/// callers can handle data-source failures functionally.
abstract class BaseRepository<T, ID> {
  const BaseRepository();

  /// Returns all entities.
  Future<Either<DataSourceError, List<T>>> getAll();

  /// Returns a single entity by [id], or a [DataSourceError] if not found.
  Future<Either<DataSourceError, T>> getById(ID id);

  /// Persists a new [entity] and returns the saved instance.
  Future<Either<DataSourceError, T>> create(T entity);

  /// Updates an existing [entity] and returns the updated instance.
  Future<Either<DataSourceError, T>> update(T entity);

  /// Deletes the entity with [id]. Returns true on success.
  Future<Either<DataSourceError, bool>> delete(ID id);
}
