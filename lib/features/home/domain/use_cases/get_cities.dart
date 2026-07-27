import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error.dart';
import '../models/city.dart';
import '../repositories/city_repository.dart';

@injectable
final class GetCities {
  const GetCities(this._repository);

  final CityRepository _repository;

  Future<Either<NetworkError, List<City>>> call() => _repository.getCities();
}
