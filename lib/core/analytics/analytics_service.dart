/// Abstract interface for analytics providers.
///
/// All implementations must be safe to call at any time — including before
/// initialization completes. Failures must be swallowed internally; the
/// app must never crash due to an analytics error.
///
/// ## PII Policy (MANDATORY)
/// - NEVER pass email addresses, phone numbers, full names, or any other
///   Personally Identifiable Information as event names or property values.
/// - User IDs must be opaque identifiers (e.g. UUID), never emails.
/// - Screen names and event names must be generic, not user-derived strings.
///
/// ## Naming Convention
/// - Event names: snake_case (e.g. `button_tapped`, `purchase_completed`)
/// - Screen names: snake_case (e.g. `home_screen`, `product_detail`)
/// - Property keys: snake_case
abstract class AnalyticsService {
  /// Initializes the analytics provider.
  ///
  /// Must be idempotent — safe to call multiple times.
  Future<void> initialize();

  /// Tracks a named event with optional properties.
  ///
  /// [name] must be snake_case. [properties] values must be
  /// String, num, bool, or null. Never include PII.
  Future<void> trackEvent(String name, {Map<String, dynamic>? properties});

  /// Tracks a screen view.
  ///
  /// [screenName] should match a route name (snake_case).
  /// [properties] are optional additional context.
  Future<void> trackScreen(String screenName, {Map<String, dynamic>? properties});

  /// Associates subsequent events with the given user ID.
  ///
  /// [userId] must be an opaque identifier (e.g. UUID). Pass null to
  /// clear the association (e.g. on sign-out).
  Future<void> setUserId(String? userId);

  /// Attaches a persistent user property to all subsequent events.
  ///
  /// [key] and [value] must not contain PII.
  Future<void> setUserProperty(String key, String value);

  /// Clears user identity and session data.
  ///
  /// Call on sign-out to prevent cross-session data leakage.
  Future<void> reset();
}
