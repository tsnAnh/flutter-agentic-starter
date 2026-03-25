import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'firebase_initializer.dart';

/// Service wrapping Firebase Remote Config with typed getters and feature flags.
///
/// Default values are always set before fetching so the app works correctly
/// even without a network connection or before the first successful fetch.
/// All methods fall back to their [defaultValue] parameters when Firebase is
/// not initialized.
@LazySingleton()
class RemoteConfigService {
  // ---------------------------------------------------------------------------
  // Default values — features are OFF by default for safe rollout
  // ---------------------------------------------------------------------------

  /// Default remote config values used before any fetch completes.
  static const Map<String, dynamic> _defaults = {
    'force_update_enabled': false,
    'minimum_app_version': '1.0.0',
    'maintenance_mode': false,
    'onboarding_v2_enabled': false,
    'new_dashboard_enabled': false,
    'max_retry_count': 3,
    'api_timeout_seconds': 30,
    'support_email': 'support@example.com',
  };

  FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Applies default values and performs an initial fetch + activate.
  ///
  /// Safe to call even if [FirebaseInitializer.isInitialized] is false —
  /// the method returns immediately without throwing.
  Future<void> initialize() async {
    if (!FirebaseInitializer.isInitialized) {
      debugPrint('[RemoteConfig] Skipping init — Firebase not initialized');
      return;
    }
    try {
      await _remoteConfig.setDefaults(_defaults);
      await fetchAndActivate();
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] initialize error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Typed getters
  // ---------------------------------------------------------------------------

  /// Returns a bool value for [key], falling back to [defaultValue].
  bool getBool(String key, {bool defaultValue = false}) {
    if (!FirebaseInitializer.isInitialized) return defaultValue;
    try {
      return _remoteConfig.getBool(key);
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] getBool($key) error: $e');
      return defaultValue;
    }
  }

  /// Returns a String value for [key], falling back to [defaultValue].
  String getString(String key, {String defaultValue = ''}) {
    if (!FirebaseInitializer.isInitialized) return defaultValue;
    try {
      return _remoteConfig.getString(key);
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] getString($key) error: $e');
      return defaultValue;
    }
  }

  /// Returns an int value for [key], falling back to [defaultValue].
  int getInt(String key, {int defaultValue = 0}) {
    if (!FirebaseInitializer.isInitialized) return defaultValue;
    try {
      return _remoteConfig.getInt(key);
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] getInt($key) error: $e');
      return defaultValue;
    }
  }

  /// Returns a double value for [key], falling back to [defaultValue].
  double getDouble(String key, {double defaultValue = 0.0}) {
    if (!FirebaseInitializer.isInitialized) return defaultValue;
    try {
      return _remoteConfig.getDouble(key);
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] getDouble($key) error: $e');
      return defaultValue;
    }
  }

  // ---------------------------------------------------------------------------
  // Feature flags
  // ---------------------------------------------------------------------------

  /// Convenience wrapper: returns true when the boolean flag [featureKey] is
  /// enabled in Remote Config.
  ///
  /// All feature flags default to false for safe rollout.
  bool isFeatureEnabled(String featureKey) =>
      getBool(featureKey, defaultValue: false);

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  /// Fetches the latest values from the Firebase backend and activates them.
  ///
  /// Returns true if new values were fetched and activated.
  Future<bool> fetchAndActivate() async {
    if (!FirebaseInitializer.isInitialized) return false;
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      debugPrint('[RemoteConfig] fetchAndActivate — updated: $updated');
      return updated;
    } on Exception catch (e) {
      debugPrint('[RemoteConfig] fetchAndActivate error: $e');
      return false;
    }
  }
}
