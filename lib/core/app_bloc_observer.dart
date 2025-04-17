import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'logger/logger.dart';

@lazySingleton
final class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required this.logger});

  static var enableLogging = false;

  final Logger logger;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (!enableLogging) return;
    logger.v('onChange: ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (!enableLogging) return;
    logger.e('onError(${bloc.runtimeType}, $error, $stackTrace)');
  }
}
