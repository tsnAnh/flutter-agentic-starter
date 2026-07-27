import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error.dart';
import '../../domain/models/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../sources/city_api.dart';

@LazySingleton(as: CityRepository)
final class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl(this.cityApi);

  final CityApi cityApi;

  @override
  Future<Either<NetworkError, List<City>>> getCities() => cityApi.getCities();
}
