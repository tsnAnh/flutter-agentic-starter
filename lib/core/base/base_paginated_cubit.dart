import 'package:flutter_bloc/flutter_bloc.dart';

import 'data_state.dart';

/// State for paginated lists.
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.dataState = const DataStateInitial(),
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final DataState<List<T>> dataState;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    DataState<List<T>>? dataState,
  }) =>
      PaginatedState<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        dataState: dataState ?? this.dataState,
      );
}

/// Abstract cubit for paginated data. Accepts a [fetchPage] callback
/// so it remains BLoC-agnostic and easily testable.
abstract class BasePaginatedCubit<T> extends Cubit<PaginatedState<T>> {
  BasePaginatedCubit() : super(const PaginatedState());

  /// Override to load a page of items. Return fewer than [pageSize]
  /// items to signal the end of the list.
  Future<List<T>> fetchPage(int page);

  static const int pageSize = 20;

  /// Loads the first page, replacing any existing items.
  Future<void> refresh() async {
    if (isClosed) return;
    emit(state.copyWith(
      page: 1,
      items: [],
      hasMore: true,
      dataState: const DataStateLoading(),
    ));
    await _loadPage(1, replace: true);
  }

  /// Loads the next page and appends to existing items.
  Future<void> loadMore() async {
    if (!state.hasMore || isClosed) return;
    if (state.dataState is DataStateLoading) return;
    await _loadPage(state.page);
  }

  Future<void> _loadPage(int page, {bool replace = false}) async {
    try {
      final newItems = await fetchPage(page);
      final allItems =
          replace ? newItems : [...state.items, ...newItems];
      final hasMore = newItems.length >= pageSize;
      if (!isClosed) {
        emit(state.copyWith(
          items: allItems,
          page: page + 1,
          hasMore: hasMore,
          dataState: DataStateLoaded(allItems),
        ));
      }
    } on Object catch (e, st) {
      if (!isClosed) {
        emit(state.copyWith(dataState: DataStateError(e.toString(), st)));
      }
    }
  }
}
