import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../firebase/firebase_initializer.dart';
import 'analytics_service.dart';

/// Analytics provider backed by Firebase Analytics.
///
/// All operations are no-ops when Firebase is not initialized.
/// Consumers do not need to guard calls.
@LazySingleton()
class FirebaseAnalyticsProvider implements AnalyticsService {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  bool get _available => FirebaseInitializer.isInitialized;

  @override
  Future<void> initialize() async {
    if (!_available) {
      debugPrint('[FirebaseAnalytics] Skipped — Firebase not initialized');
      return;
    }
    try {
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
      debugPrint('[FirebaseAnalytics] Initialized');
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] initialize failed: $e');
    }
  }

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_available) return;
    try {
      // Cast to Map<String, Object>? as required by Firebase Analytics.
      final params = properties?.map(
        (k, v) => MapEntry(k, v as Object),
      );
      await _analytics.logEvent(name: name, parameters: params);
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] trackEvent "$name" failed: $e');
    }
  }

  @override
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_available) return;
    try {
      await _analytics.logScreenView(screenName: screenName);
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] trackScreen "$screenName" failed: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_available) return;
    try {
      await _analytics.setUserId(id: userId);
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] setUserId failed: $e');
    }
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    if (!_available) return;
    try {
      await _analytics.setUserProperty(name: key, value: value);
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] setUserProperty "$key" failed: $e');
    }
  }

  @override
  Future<void> reset() async {
    if (!_available) return;
    try {
      await _analytics.setUserId(id: null);
      debugPrint('[FirebaseAnalytics] reset');
    } on Exception catch (e) {
      debugPrint('[FirebaseAnalytics] reset failed: $e');
    }
  }
}
