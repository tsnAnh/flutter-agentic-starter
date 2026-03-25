import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'firebase_initializer.dart';

/// Service wrapping Firebase App Check to protect backend resources from abuse.
///
/// App Check attests that requests originate from your genuine app on a
/// legitimate device. Attestation tokens are automatically attached to all
/// Firebase SDK requests once activated.
///
/// Platform providers:
/// - **iOS**: DeviceCheck in release, DebugProvider in debug builds.
/// - **Android**: Play Integrity in release, DebugProvider in debug builds.
///
/// [FirebaseInitializer] activates App Check during its own init sequence.
/// This service exposes [initialize] for explicit re-activation if needed and
/// [getToken] for manual token retrieval (e.g. attaching to non-Firebase APIs).
@LazySingleton()
class AppCheckService {
  FirebaseAppCheck get _appCheck => FirebaseAppCheck.instance;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Activates App Check with the appropriate provider for the current build.
  ///
  /// Normally called automatically by [FirebaseInitializer]. Call this only if
  /// you need to re-activate (e.g. after a provider change at runtime).
  ///
  /// Safe to call when Firebase is not initialized — returns immediately.
  Future<void> initialize() async {
    if (!FirebaseInitializer.isInitialized) {
      debugPrint('[AppCheck] Skipping init — Firebase not initialized');
      return;
    }
    try {
      await _appCheck.activate(
        // Debug builds use DebugProvider which generates a debug token.
        // IMPORTANT: DebugProvider must NEVER reach production — it bypasses
        // attestation entirely. The kDebugMode guard enforces this.
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
      debugPrint('[AppCheck] Activated');
    } on Exception catch (e) {
      debugPrint('[AppCheck] initialize error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  /// Returns the current App Check token, or null if unavailable.
  ///
  /// Use [forceRefresh] to bypass the cache and fetch a fresh token.
  /// Useful for attaching to non-Firebase HTTP requests as a bearer token.
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (!FirebaseInitializer.isInitialized) return null;
    try {
      return await _appCheck.getToken(forceRefresh);
    } on Exception catch (e) {
      debugPrint('[AppCheck] getToken error: $e');
      return null;
    }
  }
}
