import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'firebase_initializer.dart';

/// Service wrapping Firebase Cloud Messaging (FCM) for push notifications.
///
/// Handles permission requests, token retrieval, foreground/background message
/// streams, and topic subscriptions. All operations are no-ops when Firebase
/// is not initialized.
///
/// Wire [initialize] into app startup after [FirebaseInitializer.initialize].
@LazySingleton()
class PushNotificationService {
  final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Requests notification permission, retrieves the FCM token, and wires up
  /// foreground message listeners.
  ///
  /// Safe to call when Firebase is not initialized — returns immediately.
  Future<void> initialize() async {
    if (!FirebaseInitializer.isInitialized) {
      debugPrint('[FCM] Skipping init — Firebase not initialized');
      return;
    }
    try {
      await _requestPermission();
      await _logToken();
      _setupForegroundHandler();
      _setupTokenRefresh();
      debugPrint('[FCM] PushNotificationService initialized');
    } on Exception catch (e) {
      debugPrint('[FCM] initialize error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      // Provisional permission on iOS: delivers quietly without asking upfront.
      provisional: defaultTargetPlatform == TargetPlatform.iOS,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  Future<void> _logToken() async {
    final token = await _messaging.getToken();
    // Never log tokens in production — only in debug.
    if (kDebugMode) debugPrint('[FCM] Token: $token');
  }

  void _setupTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed');
      // TODO(consumer): persist the refreshed token to your backend.
    });
  }

  /// Returns the current FCM registration token, or null if unavailable.
  ///
  /// Tokens should be sent to your server to enable targeted notifications.
  /// Never log tokens outside of debug builds.
  Future<String?> getToken() async {
    if (!FirebaseInitializer.isInitialized) return null;
    try {
      return await _messaging.getToken();
    } on Exception catch (e) {
      debugPrint('[FCM] getToken error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Message streams
  // ---------------------------------------------------------------------------

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      _onMessageController.add(message);
    });
  }

  /// Stream of messages received while the app is in the foreground.
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  /// Stream of messages that caused the app to open from a notification tap.
  ///
  /// Emits when the user taps a notification that was displayed while the app
  /// was in the background (but not terminated).
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Returns the [RemoteMessage] that launched the app from a terminated state,
  /// or null if the app was opened normally.
  Future<RemoteMessage?> getInitialMessage() async {
    if (!FirebaseInitializer.isInitialized) return null;
    try {
      return await _messaging.getInitialMessage();
    } on Exception catch (e) {
      debugPrint('[FCM] getInitialMessage error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Topics
  // ---------------------------------------------------------------------------

  /// Subscribes the device to an FCM topic for broadcast notifications.
  Future<void> subscribeToTopic(String topic) async {
    if (!FirebaseInitializer.isInitialized) return;
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to topic: $topic');
    } on Exception catch (e) {
      debugPrint('[FCM] subscribeToTopic($topic) error: $e');
    }
  }

  /// Unsubscribes the device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!FirebaseInitializer.isInitialized) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[FCM] Unsubscribed from topic: $topic');
    } on Exception catch (e) {
      debugPrint('[FCM] unsubscribeFromTopic($topic) error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Disposes the foreground message stream controller.
  void dispose() {
    _onMessageController.close();
  }
}
