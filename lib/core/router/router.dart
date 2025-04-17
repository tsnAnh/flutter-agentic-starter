import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/blocs/authentication_cubit.dart';
import '../error_screen.dart';
import '../../features/home/home.dart';
import '../../features/login/login.dart';

abstract class AppRoutes {
  AppRoutes._();
  static const home = '/home';
  static const login = '/';
}

abstract class AppRouter {
  AppRouter._();

  static final routerConfig = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.login,
    redirect: (context, _) {
      if (context.read<AuthenticationCubit>().state) {
        return AppRoutes.home;
      } else {
        return null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
    ],
    errorBuilder: (_, __) => const ErrorScreen(),
  );
}
