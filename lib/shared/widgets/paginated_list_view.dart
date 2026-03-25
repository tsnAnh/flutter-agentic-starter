import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'app_error_widget.dart';
import 'app_empty_widget.dart';
import 'app_loading_widget.dart';

/// BLoC-agnostic paginated list view backed by [infinite_scroll_pagination] v5.
///
/// Pagination is driven by a [fetchPage] callback — no state management
/// coupling. Works equally with BLoC, Riverpod, or plain Futures.
///
/// The page key is always an [int] (1-based page number).
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.emptyWidget,
    this.errorWidget,
    this.loadingWidget,
    this.separatorBuilder,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.firstPageKey = 1,
  });

  /// Called with the next page number (starting at [firstPageKey]).
  /// Must return the items for that page.
  /// Return an empty list to signal end of data.
  final Future<List<T>> Function(int page) fetchPage;

  /// Builds a single list item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  /// Optional separator between items.
  final IndexedWidgetBuilder? separatorBuilder;

  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int firstPageKey;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late final PagingController<int, T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PagingController<int, T>(
      getNextPageKey: (state) {
        // No items yet → start at firstPageKey.
        if (state.keys == null || state.keys!.isEmpty) {
          return widget.firstPageKey;
        }
        final lastPage = state.keys!.last;
        final lastItems = state.pages?.last ?? [];
        // Empty page means no more data.
        return lastItems.isEmpty ? null : lastPage + 1;
      },
      fetchPage: (pageKey) => widget.fetchPage(pageKey),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delegate = PagedChildBuilderDelegate<T>(
      itemBuilder: widget.itemBuilder,
      firstPageProgressIndicatorBuilder: (_) =>
          widget.loadingWidget ?? const AppLoadingWidget(),
      newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator.adaptive()),
      noItemsFoundIndicatorBuilder: (_) =>
          widget.emptyWidget ??
          const AppEmptyWidget(message: 'No items found'),
      firstPageErrorIndicatorBuilder: (ctx) =>
          widget.errorWidget ??
          AppErrorWidget(
            message: _controller.value.error?.toString() ?? 'An error occurred',
            onRetry: _controller.refresh,
          ),
      newPageErrorIndicatorBuilder: (ctx) => AppErrorWidget(
        message: 'Failed to load more',
        onRetry: _controller.fetchNextPage,
      ),
    );

    if (widget.separatorBuilder != null) {
      return PagedListView<int, T>.separated(
        state: _controller.value,
        fetchNextPage: _controller.fetchNextPage,
        builderDelegate: delegate,
        separatorBuilder: widget.separatorBuilder!,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
      );
    }

    return PagedListView<int, T>(
      state: _controller.value,
      fetchNextPage: _controller.fetchNextPage,
      builderDelegate: delegate,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
    );
  }
}
