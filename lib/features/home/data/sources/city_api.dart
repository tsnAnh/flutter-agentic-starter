import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error.dart';
import '../../../../core/network/api.dart';
import '../../../../core/network/dio.dart';
import '../../domain/models/city.dart';

abstract interface class CityApi {
  Future<Either<NetworkError, List<City>>> getCities();
}

@LazySingleton(as: CityApi)
final class CityApiImpl extends Api implements CityApi {
  const CityApiImpl(@nonAuthDio super.dio);

  @override
  Future<Either<NetworkError, List<City>>> getCities() =>
      withTimeoutRequest(() async {
        final response = await dio.get<List<dynamic>>('/cities');
        return (response.data as List<dynamic>)
            .map((e) => City.fromJson(e as Map<String, dynamic>))
            .toList();
      });
}
