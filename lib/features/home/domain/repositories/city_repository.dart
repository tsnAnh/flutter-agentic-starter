import 'package:fpdart/fpdart.dart';

import '../../../../core/error.dart';
import '../models/city.dart';

abstract class CityRepository {
  Future<Either<NetworkError, List<City>>> getCities();
}
