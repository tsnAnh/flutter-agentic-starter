import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Fan-out analytics provider that forwards every call to all registered
/// [providers] in parallel.
///
/// Each provider is called independently inside its own try-catch so that
/// a failure in one provider never blocks or affects the others.
///
/// Registered manually in [RegisterModule] (get_it.dart) because injectable
/// cannot auto-inject a [List<AnalyticsService>] constructor parameter:
/// ```dart
/// getIt.registerLazySingleton<AnalyticsService>(
///   () => CompositeAnalyticsProvider([
///     getIt<FirebaseAnalyticsProvider>(),
///     getIt<PostHogAnalyticsProvider>(),
///   ]),
/// );
/// ```
class CompositeAnalyticsProvider implements AnalyticsService {
  CompositeAnalyticsProvider(this.providers);

  /// The list of providers to fan out to.
  final List<AnalyticsService> providers;

  @override
  Future<void> initialize() => _fanOut((p) => p.initialize(), 'initialize');

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) =>
      _fanOut(
        (p) => p.trackEvent(name, properties: properties),
        'trackEvent($name)',
      );

  @override
  Future<void> trackScreen(
    String screenName, {
    Map<String, dynamic>? properties,
  }) =>
      _fanOut(
        (p) => p.trackScreen(screenName, properties: properties),
        'trackScreen($screenName)',
      );

  @override
  Future<void> setUserId(String? userId) =>
      _fanOut((p) => p.setUserId(userId), 'setUserId');

  @override
  Future<void> setUserProperty(String key, String value) =>
      _fanOut((p) => p.setUserProperty(key, value), 'setUserProperty($key)');

  @override
  Future<void> reset() => _fanOut((p) => p.reset(), 'reset');

  // ---------------------------------------------------------------------------
  // Internal fan-out helper
  // ---------------------------------------------------------------------------

  /// Calls [action] on every provider in parallel.
  ///
  /// Each provider call is wrapped in an individual try-catch so one
  /// failure cannot propagate to others. [label] is used for debug logs.
  Future<void> _fanOut(
    Future<void> Function(AnalyticsService) action,
    String label,
  ) async {
    await Future.wait(
      providers.map((provider) async {
        try {
          await action(provider);
        } on Exception catch (e) {
          debugPrint(
            '[CompositeAnalytics] $label failed on '
            '${provider.runtimeType}: $e',
          );
        }
      }),
    );
  }
}
