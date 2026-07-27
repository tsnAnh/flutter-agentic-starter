import 'package:flutter/material.dart';
import 'package:flutter_agentic_starter/shared/widgets/platform_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the inherited theme platform', (tester) async {
    Future<void> pumpFor(TargetPlatform platform) {
      return tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: const PlatformWidget(
            material: Text('Material'),
            cupertino: Text('Cupertino'),
          ),
        ),
      );
    }

    await pumpFor(TargetPlatform.iOS);
    expect(find.text('Cupertino'), findsOneWidget);
    expect(find.text('Material'), findsNothing);

    await pumpFor(TargetPlatform.android);
    await tester.pumpAndSettle();
    expect(find.text('Material'), findsOneWidget);
    expect(find.text('Cupertino'), findsNothing);
  });
}
