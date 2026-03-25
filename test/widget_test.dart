import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base_source_code/features/login/login_screen.dart';
import 'package:flutter_bloc_base_source_code/shared/blocs/authentication_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthenticationCubit(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
