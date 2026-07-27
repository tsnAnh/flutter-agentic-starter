import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/analytics/analytics_service.dart';
import 'core/cache/cache_manager.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/connectivity/offline_queue_service.dart';
import 'core/di/get_it.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/logger/logger.dart';
import 'core/router/router.dart';
import 'core/theme/theme.dart';
import 'core/utils/utils.dart';
import 'shared/i18n/generated/app_localizations.dart';

Future<void> initializeFlutterApp() async {
  // 1. Flutter engine must be ready before any platform channel calls.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase — graceful fallback if config files are absent.
  await FirebaseInitializer.initialize();

  // 3. Hive — required by DiskCache and OfflineQueueService.
  await Hive.initFlutter();

  // 4. Dependency injection — all @LazySingleton/@Injectable classes registered.
  configureDependencies();

  // 5. Register CompositeAnalyticsProvider as AnalyticsService after DI is ready.
  registerCompositeAnalytics();

  // 6. Initialise CacheManager disk layer (opens Hive box).
  await getIt<CacheManager>().init();

  // 7. Start connectivity monitoring before any network calls.
  await getIt<ConnectivityService>().init();

  // 8. Initialise OfflineQueueService (opens Hive box, subscribes connectivity).
  await getIt<OfflineQueueService>().initialize();

  // 9. Logger.
  final logger = getIt<Logger>();

  // 10. Wire error handlers to Crashlytics (no-op in debug / without Firebase).
  FlutterError.onError = (FlutterErrorDetails details) {
    logger(details.exceptionAsString(), stackTrace: details.stack);
    getIt<CrashlyticsService>().recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger(error.toString(), error: error, stackTrace: stack);
    getIt<CrashlyticsService>().logError(error, stack, fatal: true);
    return true;
  };

  // 11. Analytics — runs after DI and Firebase are both ready.
  await getIt<AnalyticsService>().initialize();

  runApp(const App());
}

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const AppView();
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
