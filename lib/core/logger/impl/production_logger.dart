import 'dart:developer';

import 'package:injectable/injectable.dart';

import '../../di/get_it.dart';
import '../logger.dart';

@production
@Singleton(as: Logger)
final class ProductionLogger implements Logger {
  @override
  void call(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void v(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }

  @override
  void wtf(String message, {Object? error, StackTrace? stackTrace}) {
    log(message);
  }
}
