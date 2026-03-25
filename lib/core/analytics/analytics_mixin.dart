import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Mixin for Cubits and BLoCs that need analytics tracking.
///
/// Implementing class must provide an [analyticsService] instance (typically
/// injected via constructor). Tracking calls are fire-and-forget — they never
/// throw to the caller.
///
/// Usage:
/// ```dart
/// class ProductCubit extends Cubit<ProductState> with AnalyticsMixin {
///   ProductCubit(this.analyticsService) : super(ProductInitial());
///
///   @override
///   final AnalyticsService analyticsService;
///
///   void onAddToCart(String productId) {
///     trackAction('add_to_cart', props: {'product_id': productId});
///   }
/// }
/// ```
///
/// ## PII reminder
/// Never pass emails, phone numbers, or names in [action] or [props].
mixin AnalyticsMixin {
  /// Provide the [AnalyticsService] from the implementing class.
  AnalyticsService get analyticsService;

  /// Set to true to automatically track every [onChange] / [onTransition]
  /// call via [trackStateChange]. Override in subclass to enable.
  bool get enableStateTracking => false;

  /// Tracks a user action event.
  ///
  /// [action] must be snake_case (e.g. `button_tapped`).
  /// [props] must not contain PII.
  void trackAction(String action, {Map<String, dynamic>? props}) {
    analyticsService.trackEvent(action, properties: props).catchError((Object e) {
      debugPrint('[AnalyticsMixin] trackAction "$action" error: $e');
    });
  }

  /// Tracks a screen view.
  ///
  /// Call this on screen mount (e.g. in the Cubit constructor or a
  /// dedicated `onScreenMounted` method).
  /// [screenName] must be snake_case (e.g. `product_detail`).
  void trackScreenView(String screenName, {Map<String, dynamic>? props}) {
    analyticsService
        .trackScreen(screenName, properties: props)
        .catchError((Object e) {
      debugPrint('[AnalyticsMixin] trackScreenView "$screenName" error: $e');
    });
  }

  /// Tracks a state change. Only fires when [enableStateTracking] is true.
  ///
  /// [stateName] should be the runtime type name of the new state.
  /// Override [enableStateTracking] to activate.
  void trackStateChange(String stateName, {Map<String, dynamic>? props}) {
    if (!enableStateTracking) return;
    analyticsService
        .trackEvent('state_changed', properties: {
          'state': stateName,
          ...?props,
        })
        .catchError((Object e) {
          debugPrint('[AnalyticsMixin] trackStateChange error: $e');
        });
  }
}
