import 'package:flutter/material.dart';
import 'package:flutter_agentic_starter/core/error.dart';
import 'package:flutter_agentic_starter/core/di/get_it.dart';
import 'package:flutter_agentic_starter/core/router/router.dart';
import 'package:flutter_agentic_starter/features/home/domain/models/city.dart';
import 'package:flutter_agentic_starter/features/home/domain/repositories/city_repository.dart';
import 'package:flutter_agentic_starter/features/home/domain/use_cases/get_cities.dart';
import 'package:flutter_agentic_starter/features/home/presentation/home_view_model.dart';
import 'package:flutter_agentic_starter/shared/i18n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  setUpAll(() {
    configureDependencies();
    getIt.unregister<HomeViewModel>();
    getIt.registerFactory(
      () => HomeViewModel(GetCities(const _CityRepository())),
    );
  });

  testWidgets('app router loads cities with Signals', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.routerConfig,
      ),
    );
    await tester.pump();

    expect(AppRouter.routerConfig.routeInformationProvider.value.uri.path, '/');
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Load cities'), findsOneWidget);

    await tester.tap(find.text('Load cities'));
    await tester.pumpAndSettle();

    expect(find.text('Da Nang'), findsOneWidget);
  });
}

final class _CityRepository implements CityRepository {
  const _CityRepository();

  @override
  Future<Either<NetworkError, List<City>>> getCities() async =>
      right(const [City(id: '1', name: 'Da Nang')]);
}
