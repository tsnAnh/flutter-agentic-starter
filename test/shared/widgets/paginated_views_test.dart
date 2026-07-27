import 'package:flutter/material.dart';
import 'package:flutter_agentic_starter/shared/widgets/paginated_grid_view.dart';
import 'package:flutter_agentic_starter/shared/widgets/paginated_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pagination views rebuild from loading to empty', (tester) async {
    final views = <Widget>[
      PaginatedListView<int>(
        fetchPage: (_) async => [],
        itemBuilder: (_, item, _) => Text('$item'),
      ),
      PaginatedGridView<int>(
        fetchPage: (_) async => [],
        itemBuilder: (_, item, _) => Text('$item'),
      ),
    ];

    for (final view in views) {
      await tester.pumpWidget(MaterialApp(home: view));
      await tester.pumpAndSettle();
      expect(find.text('No items found'), findsOneWidget);
    }
  });
}
