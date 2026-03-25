import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'app_error_widget.dart';
import 'app_empty_widget.dart';
import 'app_loading_widget.dart';

/// BLoC-agnostic paginated grid view backed by [infinite_scroll_pagination] v5.
///
/// Same callback pattern as [PaginatedListView] — no state management coupling.
class PaginatedGridView<T> extends StatefulWidget {
  const PaginatedGridView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1.0,
    this.emptyWidget,
    this.errorWidget,
    this.loadingWidget,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.firstPageKey = 1,
  });

  /// Called with the next page number. Return empty list to signal end of data.
  final Future<List<T>> Function(int page) fetchPage;

  /// Builds a single grid item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int firstPageKey;

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  late final PagingController<int, T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PagingController<int, T>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) {
          return widget.firstPageKey;
        }
        final lastPage = state.keys!.last;
        final lastItems = state.pages?.last ?? [];
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
    return PagedGridView<int, T>(
      state: _controller.value,
      fetchNextPage: _controller.fetchNextPage,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      builderDelegate: PagedChildBuilderDelegate<T>(
        itemBuilder: widget.itemBuilder,
        firstPageProgressIndicatorBuilder: (_) =>
            widget.loadingWidget ?? const AppLoadingWidget(),
        newPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator.adaptive()),
        noItemsFoundIndicatorBuilder: (_) =>
            widget.emptyWidget ??
            const AppEmptyWidget(message: 'No items found'),
        firstPageErrorIndicatorBuilder: (_) =>
            widget.errorWidget ??
            AppErrorWidget(
              message:
                  _controller.value.error?.toString() ?? 'An error occurred',
              onRetry: _controller.refresh,
            ),
        newPageErrorIndicatorBuilder: (_) => AppErrorWidget(
          message: 'Failed to load more',
          onRetry: _controller.fetchNextPage,
        ),
      ),
    );
  }
}
