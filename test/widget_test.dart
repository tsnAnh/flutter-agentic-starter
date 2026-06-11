import 'package:flutter/material.dart';
import 'package:flutter_bloc_base_source_code/core/di/get_it.dart';
import 'package:flutter_bloc_base_source_code/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    configureDependencies();
  });

  testWidgets('app router opens the home route', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.routerConfig),
    );
    await tester.pump();

    expect(AppRouter.routerConfig.routeInformationProvider.value.uri.path, '/');
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Load cities'), findsOneWidget);
  });
}
