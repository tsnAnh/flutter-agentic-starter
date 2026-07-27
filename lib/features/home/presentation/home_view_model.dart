import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

import '../domain/models/city.dart';
import '../domain/use_cases/get_cities.dart';

@injectable
final class HomeViewModel {
  HomeViewModel(this._getCities);

  final GetCities _getCities;
  final _cities = signal<AsyncState<List<City>>?>(null);

  ReadonlySignal<AsyncState<List<City>>?> get cities => _cities;

  Future<void> loadCities() async {
    if (_cities.value is AsyncLoading<List<City>>) return;

    _cities.value = AsyncState.loading();
    final result = await _getCities();
    result.fold(
      (error) => _cities.value = AsyncState.error(error),
      (cities) => _cities.value = AsyncState.data(cities),
    );
  }
}
