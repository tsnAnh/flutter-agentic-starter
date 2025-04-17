import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../flavor_configurations.dart';
import '../extensions/duration.dart';
import 'interceptors/authentication_interceptor.dart';

class DioClient {
  DioClient() {
    final baseOptions = createBaseOptions();
    authDio = Dio(baseOptions)..interceptors.add(AuthenticationInterceptor());
    dio = Dio(baseOptions);
  }

  BaseOptions createBaseOptions() {
    final config = ConfigurationProfile.current;
    return BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout.milliseconds,
      receiveTimeout: config.receiveTimeout.milliseconds,
      sendTimeout: config.sendTimeout.milliseconds,
    );
  }

  late final Dio authDio;
  late final Dio dio;
}

const authDio = Named('AuthDio');
const nonAuthDio = Named('NonAuthDio');
