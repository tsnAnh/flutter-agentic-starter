// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
import '../analytics/firebase_analytics_provider.dart' as _i506;
import '../analytics/posthog_analytics_provider.dart' as _i382;
import '../app_bloc_observer.dart' as _i744;
import '../auth/secure_storage_service.dart' as _i921;
import '../auth/session_manager.dart' as _i287;
import '../auth/token_manager.dart' as _i428;
import '../cache/cache_manager.dart' as _i326;
import '../connectivity/connectivity_cubit.dart' as _i690;
import '../connectivity/connectivity_service.dart' as _i528;
import '../connectivity/offline_queue_service.dart' as _i1052;
import '../firebase/app_check_service.dart' as _i399;
import '../firebase/crashlytics_service.dart' as _i364;
import '../firebase/push_notification_service.dart' as _i511;
import '../firebase/remote_config_service.dart' as _i130;
import '../lifecycle/app_lifecycle_observer.dart' as _i947;
import '../lifecycle/app_update_checker.dart' as _i866;
import '../logger/impl/debug_logger.dart' as _i803;
import '../logger/impl/production_logger.dart' as _i67;
import '../logger/logger.dart' as _i512;
import '../network/remote.dart' as _i612;
import '../permissions/permission_cubit.dart' as _i835;
import '../permissions/permission_handler_impl.dart' as _i440;
import '../permissions/permission_service.dart' as _i271;
import '../router/deep_link_handler.dart' as _i605;
import 'get_it.dart' as _i241;

const String _development = 'development';
const String _production = 'production';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i506.FirebaseAnalyticsProvider>(
      () => _i506.FirebaseAnalyticsProvider(),
    );
    gh.lazySingleton<_i382.PostHogAnalyticsProvider>(
      () => _i382.PostHogAnalyticsProvider(),
    );
    gh.lazySingleton<_i612.DioClient>(() => registerModule.dioClient);
    gh.lazySingleton<_i528.ConnectivityService>(
      () => registerModule.connectivityService,
    );
    gh.lazySingleton<_i326.CacheManager>(() => registerModule.cacheManager);
    gh.lazySingleton<_i921.SecureStorageService>(
      () => registerModule.secureStorageService,
    );
    gh.lazySingleton<_i287.SessionManager>(() => registerModule.sessionManager);
    gh.lazySingleton<_i605.DeepLinkHandler>(
      () => registerModule.deepLinkHandler,
    );
    gh.lazySingleton<_i399.AppCheckService>(() => _i399.AppCheckService());
    gh.lazySingleton<_i364.CrashlyticsService>(
      () => _i364.CrashlyticsService(),
    );
    gh.lazySingleton<_i511.PushNotificationService>(
      () => _i511.PushNotificationService(),
    );
    gh.lazySingleton<_i130.RemoteConfigService>(
      () => _i130.RemoteConfigService(),
    );
    gh.lazySingleton<_i947.AppLifecycleObserver>(
      () => _i947.AppLifecycleObserver(),
    );
    gh.factory<_i361.Dio>(
      () => registerModule.dioAuth,
      instanceName: 'AuthDio',
    );
    gh.factory<_i361.Dio>(
      () => registerModule.dioNonAuth,
      instanceName: 'NonAuthDio',
    );
    gh.lazySingleton<_i866.AppUpdateChecker>(
      () => _i866.AppUpdateChecker(gh<_i130.RemoteConfigService>()),
    );
    gh.lazySingleton<_i271.PermissionService>(
      () => _i440.PermissionHandlerImpl(),
    );
    gh.factory<_i835.PermissionCubit>(
      () => _i835.PermissionCubit(gh<_i271.PermissionService>()),
    );
    gh.lazySingleton<_i428.TokenManager>(
      () => _i428.TokenManager(gh<_i921.SecureStorageService>()),
    );
    gh.lazySingleton<_i690.ConnectivityCubit>(
      () => _i690.ConnectivityCubit(gh<_i528.ConnectivityService>()),
    );
    gh.singleton<_i512.Logger>(
      () => _i803.DebugLogger(),
      registerFor: {_development},
    );
    gh.lazySingleton<_i1052.OfflineQueueService>(
      () => _i1052.OfflineQueueService(
        gh<_i428.TokenManager>(),
        gh<_i690.ConnectivityCubit>(),
        gh<_i361.Dio>(instanceName: 'NonAuthDio'),
      ),
    );
    gh.lazySingleton<_i737.CityApi>(
      () => _i737.CityApiImpl(gh<_i361.Dio>(instanceName: 'NonAuthDio')),
    );
    gh.lazySingleton<_i288.CityRepository>(
      () => _i841.CityRepositoryImpl(gh<_i737.CityApi>()),
    );
    gh.singleton<_i512.Logger>(
      () => _i67.ProductionLogger(),
      registerFor: {_production},
    );
    gh.factory<_i854.HomeBloc>(
      () => _i854.HomeBloc(gh<_i288.CityRepository>()),
    );
    gh.factory<_i1032.HomeCubit>(
      () => _i1032.HomeCubit(gh<_i288.CityRepository>()),
    );
    gh.lazySingleton<_i744.AppBlocObserver>(
      () => _i744.AppBlocObserver(logger: gh<_i512.Logger>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i241.RegisterModule {}
