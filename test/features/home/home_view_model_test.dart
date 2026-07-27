import 'dart:async';

import 'package:flutter_agentic_starter/core/error.dart' as app_error;
import 'package:flutter_agentic_starter/features/home/domain/models/city.dart';
import 'package:flutter_agentic_starter/features/home/domain/repositories/city_repository.dart';
import 'package:flutter_agentic_starter/features/home/domain/use_cases/get_cities.dart';
import 'package:flutter_agentic_starter/features/home/presentation/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:signals/signals.dart';

void main() {
  test('starts empty, then exposes loading and city data', () async {
    final repository = _ControlledCityRepository();
    final viewModel = HomeViewModel(GetCities(repository));

    expect(viewModel.cities.value, isNull);

    final load = viewModel.loadCities();
    expect(viewModel.cities.value, isA<AsyncLoading<List<City>>>());

    const cities = [City(id: '1', name: 'Da Nang')];
    repository.complete(right(cities));
    await load;

    expect(viewModel.cities.value, isA<AsyncData<List<City>>>());
    expect(viewModel.cities.value?.value, cities);
  });

  test('exposes a typed error when loading fails', () async {
    final repository = _ControlledCityRepository();
    final viewModel = HomeViewModel(GetCities(repository));
    final error = app_error.Timeout(exception: Exception('timed out'));

    final load = viewModel.loadCities();
    repository.complete(left(error));
    await load;

    expect(viewModel.cities.value, isA<AsyncError<List<City>>>());
    expect(viewModel.cities.value?.error, same(error));
  });
}

final class _ControlledCityRepository implements CityRepository {
  final _result = Completer<Either<app_error.NetworkError, List<City>>>();

  @override
  Future<Either<app_error.NetworkError, List<City>>> getCities() =>
      _result.future;

  void complete(Either<app_error.NetworkError, List<City>> result) {
    _result.complete(result);
  }
}
