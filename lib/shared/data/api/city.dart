import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/api.dart';
import '../../../core/network/dio.dart';
import '../models/dtos/city.dart';

abstract interface class CityApi {
  Future<Option<List<City>>> getCities();
}

@LazySingleton(as: CityApi)
final class CityApiImpl extends Api implements CityApi {
  const CityApiImpl(@nonAuthDio super.dio);

  @override
  Future<Option<List<City>>> getCities() => withTimeoutRequestOption(() async {
    final response = await dio.get<List<dynamic>>('/cities');
    return (response.data as List<dynamic>)
        .map((e) => City.fromJson(e as Map<String, dynamic>))
        .toList();
  });
}
