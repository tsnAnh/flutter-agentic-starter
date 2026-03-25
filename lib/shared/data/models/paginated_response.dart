/// Generic paginated response wrapper for list endpoints.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalItems;

  /// Returns true when there are more pages to load.
  bool get hasMore => page < totalPages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>? ?? []).map(fromJsonT).toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'page': page,
      'totalPages': totalPages,
      'totalItems': totalItems,
    };
  }

  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? page,
    int? totalPages,
    int? totalItems,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  String toString() =>
      'PaginatedResponse(page: $page/$totalPages, items: ${items.length}, total: $totalItems)';
}
