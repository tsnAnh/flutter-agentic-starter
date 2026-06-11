import 'package:flutter_bloc/flutter_bloc.dart';
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
        builder: (_, _) => BlocProvider(
          create: (_) => getIt<HomeBloc>(),
          child: const HomeScreen(),
        ),
      ),
    ],
    errorBuilder: (_, _) => const ErrorScreen(),
  );
}
