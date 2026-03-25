import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../api/city.dart';
import '../models/dtos/city.dart';
import 'city_repository.dart';

@LazySingleton(as: CityRepository)
final class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl(this.cityApi);

  final CityApi cityApi;

  @override
  Future<Option<List<City>>> getCities() async => cityApi.getCities();
}