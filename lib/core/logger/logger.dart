abstract class Logger {
  void i(String message, {Object? error, StackTrace? stackTrace});
  void v(String message, {Object? error, StackTrace? stackTrace});
  void d(String message, {Object? error, StackTrace? stackTrace});
  void e(String message, {Object? error, StackTrace? stackTrace});
  void w(String message, {Object? error, StackTrace? stackTrace});
  void wtf(String message, {Object? error, StackTrace? stackTrace});
  void call(String message, {Object? error, StackTrace? stackTrace});
}
