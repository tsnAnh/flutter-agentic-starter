import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/analytics/analytics_service.dart';
import 'core/app_bloc_observer.dart';
import 'core/cache/cache_manager.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/connectivity/offline_queue_service.dart';
import 'core/di/get_it.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/logger/logger.dart';
import 'core/router/router.dart';
import 'core/theme/theme.dart';
import 'core/utils/utils.dart';
import 'shared/blocs/authentication_cubit.dart';
import 'shared/i18n/generated/app_localizations.dart';

Future<void> initializeFlutterApp() async {
  // 1. Flutter engine must be ready before any platform channel calls.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase — graceful fallback if config files are absent.
  await FirebaseInitializer.initialize();

  // 3. Hive — required by DiskCache and OfflineQueueService.
  await Hive.initFlutter();

  // 4. HydratedBloc persistent storage.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        HydratedStorageDirectory((await getApplicationSupportDirectory()).path),
  );

  // 5. Dependency injection — all @LazySingleton/@Injectable classes registered.
  configureDependencies();

  // 6. Register CompositeAnalyticsProvider as AnalyticsService after DI is ready.
  registerCompositeAnalytics();

  // 7. Initialise CacheManager disk layer (opens Hive box).
  await getIt<CacheManager>().init();

  // 8. Start connectivity monitoring before any network calls.
  await getIt<ConnectivityService>().init();
  getIt<ConnectivityCubit>().startMonitoring();

  // 9. Initialise OfflineQueueService (opens Hive box, subscribes connectivity).
  await getIt<OfflineQueueService>().initialize();

  // 10. Logger + BLoC observer.
  final logger = getIt<Logger>();
  final observer = getIt<AppBlocObserver>();

  // 11. Wire error handlers to Crashlytics (no-op in debug / without Firebase).
  FlutterError.onError = (FlutterErrorDetails details) {
    logger(details.exceptionAsString(), stackTrace: details.stack);
    getIt<CrashlyticsService>().recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger(error.toString(), error: error, stackTrace: stack);
    getIt<CrashlyticsService>().logError(error, stack, fatal: true);
    return true;
  };

  // 12. Equatable + BLoC observer.
  EquatableConfig.stringify = true;
  Bloc.observer = observer;

  // 13. Analytics — runs after DI and Firebase are both ready.
  await getIt<AnalyticsService>().initialize();

  runApp(const App());
}

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthenticationCubit(),
        ),
        BlocProvider(
          // ConnectivityCubit is a lazySingleton — share the same instance.
          create: (_) => getIt<ConnectivityCubit>(),
        ),
      ],
      child: const AppView(),
    );
  }
}

final class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => AppViewState();

  static AppViewState of(BuildContext context) =>
      context.findAncestorStateOfType<AppViewState>()!;
}

final class AppViewState extends State<AppView> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    safeSetState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.routerConfig,
        themeMode: _themeMode,
      ),
    );
  }
}
