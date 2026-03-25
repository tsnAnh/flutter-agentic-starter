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

  /// Holds the deep-link path that arrived while the user was unauthenticated.
  /// After a successful login the app should navigate here instead of [AppRoutes.home].
  static String? _pendingDeepLink;

  /// Call this from the deep link handler when a link arrives and the user is
  /// not yet authenticated.  The router's redirect will consume it after login.
  static void setPendingDeepLink(String path) => _pendingDeepLink = path;

  /// Returns and clears the pending deep link (one-shot).
  static String? consumePendingDeepLink() {
    final path = _pendingDeepLink;
    _pendingDeepLink = null;
    return path;
  }

  static final routerConfig = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = context.read<AuthenticationCubit>().state;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated) {
        // Save deep link destination for after login if not already heading there.
        if (!isOnLogin && state.matchedLocation != AppRoutes.home) {
          _pendingDeepLink ??= state.uri.toString();
        }
        return isOnLogin ? null : AppRoutes.login;
      }

      // Authenticated — consume pending deep link and redirect there.
      final pending = consumePendingDeepLink();
      if (pending != null && pending != state.matchedLocation) {
        return pending;
      }

      // Authenticated and on login → go home.
      if (isOnLogin) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    ],
    errorBuilder: (_, _) => const ErrorScreen(),
  );
}
