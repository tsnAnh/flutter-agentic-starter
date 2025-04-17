import 'package:dart3z/dartz.dart';

import '../models/dtos/city.dart';

abstract class CityRepository {
  Future<Option<List<City>>> getCities();
}
