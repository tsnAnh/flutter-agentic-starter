import 'package:fpdart/fpdart.dart';

import '../models/dtos/city.dart';

abstract class CityRepository {
  Future<Option<List<City>>> getCities();
}
