import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../shared/widgets/paginated_grid_view.dart';
import '../../shared/widgets/paginated_list_view.dart';
import '../../shared/widgets/platform_widget.dart';
import '../../shared/widgets/pull_to_refresh_wrapper.dart';
import '../../shared/widgets/responsive_builder.dart';

@widgetbook.UseCase(name: 'Success', type: PaginatedListView)
Widget paginatedListSuccessUseCase(BuildContext context) =>
    const _CatalogSurface(
      child: _PaginatedListFixture(state: _CollectionState.success),
    );

@widgetbook.UseCase(name: 'Empty', type: PaginatedListView)
Widget paginatedListEmptyUseCase(BuildContext context) => const _CatalogSurface(
  child: _PaginatedListFixture(state: _CollectionState.empty),
);

@widgetbook.UseCase(name: 'Failure', type: PaginatedListView)
Widget paginatedListFailureUseCase(BuildContext context) =>
    const _CatalogSurface(
      child: _PaginatedListFixture(state: _CollectionState.failure),
    );

@widgetbook.UseCase(name: 'Success', type: PaginatedGridView)
Widget paginatedGridSuccessUseCase(BuildContext context) =>
    const _CatalogSurface(
      child: _PaginatedGridFixture(state: _CollectionState.success),
    );

@widgetbook.UseCase(name: 'Empty', type: PaginatedGridView)
Widget paginatedGridEmptyUseCase(BuildContext context) => const _CatalogSurface(
  child: _PaginatedGridFixture(state: _CollectionState.empty),
);

@widgetbook.UseCase(name: 'Failure', type: PaginatedGridView)
Widget paginatedGridFailureUseCase(BuildContext context) =>
    const _CatalogSurface(
      child: _PaginatedGridFixture(state: _CollectionState.failure),
    );

@widgetbook.UseCase(name: 'Pull to refresh', type: PullToRefreshWrapper)
Widget pullToRefreshUseCase(BuildContext context) =>
    const _CatalogSurface(child: _RefreshFixture());

@widgetbook.UseCase(name: 'Breakpoint variants', type: ResponsiveBuilder)
Widget responsiveBuilderUseCase(BuildContext context) {
  return const _CatalogSurface(
    child: ResponsiveBuilder(
      mobile: _VariantPanel(
        name: 'Mobile',
        detail: 'Width below 479 px',
        icon: Icons.smartphone,
        color: Colors.blue,
      ),
      tablet: _VariantPanel(
        name: 'Tablet',
        detail: 'Width from 479 px to 766 px',
        icon: Icons.tablet_mac,
        color: Colors.teal,
      ),
      desktop: _VariantPanel(
        name: 'Desktop',
        detail: 'Width 767 px and above',
        icon: Icons.desktop_windows,
        color: Colors.deepPurple,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Material', type: PlatformWidget)
Widget platformWidgetMaterialUseCase(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(platform: TargetPlatform.android),
    child: const _CatalogSurface(child: _PlatformFixture()),
  );
}

@widgetbook.UseCase(name: 'Cupertino', type: PlatformWidget)
Widget platformWidgetCupertinoUseCase(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
    child: const _CatalogSurface(child: _PlatformFixture()),
  );
}

@widgetbook.UseCase(name: 'Selected viewport', type: PlatformWidget)
Widget platformWidgetViewportUseCase(BuildContext context) =>
    const _CatalogSurface(child: _PlatformFixture());

enum _CollectionState { success, empty, failure }

const _items = [
  _CatalogItem('Atlas', 'Exploration workspace', Icons.explore_outlined),
  _CatalogItem('Beacon', 'Release monitoring', Icons.wifi_tethering),
  _CatalogItem('Canvas', 'Design review', Icons.draw_outlined),
  _CatalogItem('Delta', 'Change tracking', Icons.change_circle_outlined),
  _CatalogItem('Ember', 'Incident response', Icons.local_fire_department),
  _CatalogItem('Forge', 'Build automation', Icons.build_outlined),
];

final class _CatalogItem {
  const _CatalogItem(this.name, this.description, this.icon);

  final String name;
  final String description;
  final IconData icon;
}

Future<List<_CatalogItem>> _fetchItems(_CollectionState state, int page) async {
  if (state == _CollectionState.failure) {
    throw StateError('The local fixture could not load.');
  }
  if (state == _CollectionState.empty || page > 1) {
    return const [];
  }
  return _items;
}

class _PaginatedListFixture extends StatelessWidget {
  const _PaginatedListFixture({required this.state});

  final _CollectionState state;

  @override
  Widget build(BuildContext context) {
    return PaginatedListView<_CatalogItem>(
      fetchPage: (page) => _fetchItems(state, page),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, item, _) => Card(
        child: ListTile(
          leading: Icon(item.icon),
          title: Text(item.name),
          subtitle: Text(item.description),
        ),
      ),
    );
  }
}

class _PaginatedGridFixture extends StatelessWidget {
  const _PaginatedGridFixture({required this.state});

  final _CollectionState state;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return PaginatedGridView<_CatalogItem>(
      fetchPage: (page) => _fetchItems(state, page),
      crossAxisCount: width >= 720 ? 3 : 2,
      childAspectRatio: 1.2,
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, item, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 32),
              const SizedBox(height: 8),
              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefreshFixture extends StatefulWidget {
  const _RefreshFixture();

  @override
  State<_RefreshFixture> createState() => _RefreshFixtureState();
}

class _RefreshFixtureState extends State<_RefreshFixture> {
  var _refreshCount = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() => _refreshCount++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefreshWrapper(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.swipe_down_alt, size: 48),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Completed refreshes: $_refreshCount',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlatformFixture extends StatelessWidget {
  const _PlatformFixture();

  @override
  Widget build(BuildContext context) {
    return const PlatformWidget(
      material: _VariantPanel(
        name: 'Material',
        detail: 'Selected by ThemeData.platform = android',
        icon: Icons.android,
        color: Colors.green,
      ),
      cupertino: _VariantPanel(
        name: 'Cupertino',
        detail: 'Selected by ThemeData.platform = iOS',
        icon: Icons.phone_iphone,
        color: Colors.blue,
      ),
    );
  }
}

class _CatalogSurface extends StatelessWidget {
  const _CatalogSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child));
  }
}

class _VariantPanel extends StatelessWidget {
  const _VariantPanel({
    required this.name,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String name;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: '$name layout',
        child: Card(
          margin: const EdgeInsets.all(24),
          color: color.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 16),
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(detail, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
