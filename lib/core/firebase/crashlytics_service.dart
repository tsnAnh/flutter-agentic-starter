import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'firebase_initializer.dart';

/// Service wrapping Firebase Crashlytics for error reporting and breadcrumbs.
///
/// All methods are no-ops when Firebase is not initialized or in debug mode
/// (Crashlytics collection is disabled in debug). Consumers do not need to
/// guard calls — this service handles it internally.
@LazySingleton()
class CrashlyticsService {
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  bool get _canReport =>
      FirebaseInitializer.isInitialized && !kDebugMode;

  /// Records a non-fatal error with optional stack trace.
  ///
  /// Set [fatal] to true for errors that should be treated as fatal crashes
  /// (e.g. uncaught isolate errors).
  void logError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_canReport) {
      debugPrint('[Crashlytics] logError (no-op): $error');
      return;
    }
    _crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Logs a breadcrumb message visible in the Crashlytics dashboard.
  void logMessage(String message) {
    if (!_canReport) {
      debugPrint('[Crashlytics] logMessage (no-op): $message');
      return;
    }
    _crashlytics.log(message);
  }

  /// Sets the user identifier shown on crash reports.
  ///
  /// Pass an empty string to clear the identifier (e.g. on sign-out).
  void setUserIdentifier(String id) {
    if (!FirebaseInitializer.isInitialized) return;
    _crashlytics.setUserIdentifier(id);
  }

  /// Attaches a custom key-value pair to subsequent crash reports.
  ///
  /// [value] must be a bool, int, double, or String.
  void setCustomKey(String key, Object value) {
    if (!FirebaseInitializer.isInitialized) return;
    _crashlytics.setCustomKey(key, value);
  }

  /// Records a Flutter framework error (e.g. from FlutterError.onError).
  ///
  /// Wire this into [FlutterError.onError] in app initialisation:
  /// ```dart
  /// FlutterError.onError = (details) {
  ///   crashlyticsService.recordFlutterError(details);
  /// };
  /// ```
  void recordFlutterError(FlutterErrorDetails details) {
    if (!_canReport) {
      debugPrint('[Crashlytics] recordFlutterError (no-op): ${details.summary}');
      FlutterError.presentError(details);
      return;
    }
    _crashlytics.recordFlutterFatalError(details);
  }
}
