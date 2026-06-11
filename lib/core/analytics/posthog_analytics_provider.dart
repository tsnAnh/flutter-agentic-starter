import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'analytics_service.dart';

/// Analytics provider backed by PostHog.
///
/// PostHog offers event capture, screen tracking, user identification,
/// feature flags, and optional session replay.
///
/// ## Configuration
/// TODO: Supply the PostHog API key via environment config or
/// [FlavorConfigurations] before calling [initialize]. Do not hardcode.
///
/// ## Graceful degradation
/// All calls are wrapped in try-catch. If PostHog is unavailable or
/// not yet set up, operations are silently skipped.
@LazySingleton()
class PostHogAnalyticsProvider implements AnalyticsService {
  bool _initialized = false;

  /// Tracks the last userId supplied to [setUserId] so [setUserProperty] can
  /// call identify with the correct ID instead of an empty string.
  String? _currentUserId;

  final _posthog = Posthog();

  @override
  Future<void> initialize() async {
    // TODO: Replace the empty string with your PostHog API key sourced from
    // environment configuration (e.g. FlavorConfigurations.posthogApiKey).
    // Do NOT hardcode the key here.
    const apiKey = String.fromEnvironment('POSTHOG_API_KEY', defaultValue: '');
    const host = String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://app.posthog.com',
    );

    if (apiKey.isEmpty) {
      debugPrint('[PostHog] API key not set — analytics disabled');
      return;
    }

    try {
      final config = PostHogConfig(apiKey)
        ..debug = kDebugMode
        ..host = host
        ..captureApplicationLifecycleEvents = false;

      await _posthog.setup(config);
      _initialized = true;
      debugPrint('[PostHog] Initialized');
    } on Exception catch (e) {
      debugPrint('[PostHog] initialize failed: $e');
    }
  }

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_initialized) return;
    try {
      final props = _toObjectMap(properties);
      await _posthog.capture(eventName: name, properties: props);
    } on Exception catch (e) {
      debugPrint('[PostHog] trackEvent "$name" failed: $e');
    }
  }

  @override
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_initialized) return;
    try {
      final props = _toObjectMap(properties);
      await _posthog.screen(screenName: screenName, properties: props);
    } on Exception catch (e) {
      debugPrint('[PostHog] trackScreen "$screenName" failed: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_initialized) return;
    if (userId == null) {
      _currentUserId = null;
      await reset();
      return;
    }
    try {
      _currentUserId = userId;
      await _posthog.identify(userId: userId);
    } on Exception catch (e) {
      debugPrint('[PostHog] setUserId failed: $e');
    }
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    if (!_initialized) return;
    try {
      // PostHog user properties are set via identify's userProperties map.
      // We must supply the current userId — using an empty string would
      // override the active user identity with an anonymous empty-string ID.
      final userId = _currentUserId;
      if (userId != null) {
        await _posthog.identify(userId: userId, userProperties: {key: value});
      } else {
        // No identified user yet — capture as an event property instead so
        // the property is not lost and no phantom user is created.
        await _posthog.capture(eventName: r'$set', properties: {key: value});
      }
    } on Exception catch (e) {
      debugPrint('[PostHog] setUserProperty "$key" failed: $e');
    }
  }

  @override
  Future<void> reset() async {
    if (!_initialized) return;
    try {
      await _posthog.reset();
      debugPrint('[PostHog] reset');
    } on Exception catch (e) {
      debugPrint('[PostHog] reset failed: $e');
    }
  }

  // PostHog requires Map<String, Object> — filter null values.
  Map<String, Object>? _toObjectMap(Map<String, dynamic>? input) {
    if (input == null) return null;
    final result = <String, Object>{};
    for (final entry in input.entries) {
      if (entry.value != null) result[entry.key] = entry.value as Object;
    }
    return result.isEmpty ? null : result;
  }
}
