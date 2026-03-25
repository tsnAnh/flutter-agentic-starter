/// Sealed class hierarchy for pagination strategies.
///
/// Use [OffsetPagination] for page/offset-based APIs.
/// Use [CursorPagination] for cursor-based APIs (e.g. GraphQL, social feeds).
sealed class PaginationParams {
  const PaginationParams({required this.limit});

  final int limit;

  Map<String, dynamic> toQueryParams();
}

/// Standard page + limit pagination.
final class OffsetPagination extends PaginationParams {
  const OffsetPagination({required this.page, super.limit = 20});

  final int page;

  @override
  Map<String, dynamic> toQueryParams() => {
        'page': page,
        'limit': limit,
      };

  OffsetPagination nextPage() => OffsetPagination(page: page + 1, limit: limit);

  @override
  String toString() => 'OffsetPagination(page: $page, limit: $limit)';
}

/// Cursor-based pagination — suitable for infinite scroll with stable ordering.
final class CursorPagination extends PaginationParams {
  const CursorPagination({this.cursor, super.limit = 20});

  final String? cursor;

  @override
  Map<String, dynamic> toQueryParams() => {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      };

  CursorPagination withCursor(String nextCursor) =>
      CursorPagination(cursor: nextCursor, limit: limit);

  @override
  String toString() => 'CursorPagination(cursor: $cursor, limit: $limit)';
}
