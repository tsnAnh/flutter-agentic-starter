import 'package:go_router/go_router.dart';

import '../error_screen.dart';
import '../di/get_it.dart';
import '../../features/home/home.dart';

abstract class AppRouter {
  AppRouter._();

  static final routerConfig = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => HomeScreen(viewModel: getIt<HomeViewModel>()),
      ),
    ],
    errorBuilder: (_, _) => const ErrorScreen(),
  );
}
