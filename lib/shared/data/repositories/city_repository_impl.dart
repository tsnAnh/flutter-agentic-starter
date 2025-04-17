import 'package:dart3z/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/remote.dart';
import '../models/dtos/city.dart';
import 'city_repository.dart';

@LazySingleton(as: CityRepository)
final class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl(this.cityApi);

  final ICityApi cityApi;

  @override
  Future<Option<List<City>>> getCities() => cityApi.getCities();
}
