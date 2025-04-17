// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/home/bloc/home_bloc.dart' as _i854;
import '../../features/home/cubit/home_cubit.dart' as _i1032;
import '../../shared/data/api/city.dart' as _i737;
import '../../shared/data/repositories/city_repository.dart' as _i288;
import '../../shared/data/repositories/city_repository_impl.dart' as _i841;
import '../app_bloc_observer.dart' as _i744;
import '../logger/impl/debug_logger.dart' as _i803;
import '../logger/impl/production_logger.dart' as _i67;
import '../logger/logger.dart' as _i512;
import '../network/remote.dart' as _i612;
import 'get_it.dart' as _i241;

const String _development = 'development';
const String _production = 'production';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i612.DioClient>(() => registerModule.dioClient);
    gh.factory<_i361.Dio>(
      () => registerModule.dioAuth,
      instanceName: 'AuthDio',
    );
    gh.factory<_i361.Dio>(
      () => registerModule.dioNonAuth,
      instanceName: 'NonAuthDio',
    );
    gh.lazySingleton<_i737.CityApi>(
        () => _i737.CityApiImpl(gh<_i361.Dio>(instanceName: 'NonAuthDio')));
    gh.lazySingleton<_i288.CityRepository>(
        () => _i841.CityRepositoryImpl(gh<_i737.CityApi>()));
    gh.factory<_i1032.HomeCubit>(
        () => _i1032.HomeCubit(gh<_i288.CityRepository>()));
    gh.factory<_i854.HomeBloc>(
        () => _i854.HomeBloc(gh<_i288.CityRepository>()));
    gh.singleton<_i512.Logger>(
      () => _i803.DebugLogger(),
      registerFor: {_development},
    );
    gh.singleton<_i512.Logger>(
      () => _i67.ProductionLogger(),
      registerFor: {_production},
    );
    gh.lazySingleton<_i744.AppBlocObserver>(
        () => _i744.AppBlocObserver(logger: gh<_i512.Logger>()));
    return this;
  }
}

class _$RegisterModule extends _i241.RegisterModule {}
