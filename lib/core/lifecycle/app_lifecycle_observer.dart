import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// Wraps [WidgetsBindingObserver] and exposes a [Stream<AppLifecycleState>]
/// plus add/remove listener helpers for clean subscription management.
///
/// ## Initialisation order — IMPORTANT
/// The constructor calls [WidgetsBinding.instance.addObserver], which requires
/// [WidgetsFlutterBinding.ensureInitialized()] (or [runApp]) to have been
/// called first. As a lazy singleton this is normally safe because DI is set
/// up after [ensureInitialized] in `main.dart`. However, in unit tests you
/// MUST call [WidgetsFlutterBinding.ensureInitialized()] in `setUp` before
/// resolving this class from the container — otherwise [WidgetsBinding.instance]
/// will throw a [StateError].
///
/// Registered as a lazy singleton — [WidgetsBinding] is only touched after
/// the Flutter engine is ready.
@LazySingleton()
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  final StreamController<AppLifecycleState> _controller =
      StreamController<AppLifecycleState>.broadcast();

  final List<void Function(AppLifecycleState)> _listeners = [];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Stream of lifecycle state changes broadcast to all listeners.
  Stream<AppLifecycleState> get lifecycleStream => _controller.stream;

  /// Registers a callback that fires on every lifecycle change.
  void addListener(void Function(AppLifecycleState) callback) {
    _listeners.add(callback);
  }

  /// Removes a previously registered [callback]. No-op if not found.
  void removeListener(void Function(AppLifecycleState) callback) {
    _listeners.remove(callback);
  }

  // ---------------------------------------------------------------------------
  // WidgetsBindingObserver
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.add(state);
    for (final cb in List.of(_listeners)) {
      cb(state);
    }

    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
      case AppLifecycleState.paused:
        onPaused();
      case AppLifecycleState.detached:
        onDetached();
      case AppLifecycleState.inactive:
        onInactive();
      case AppLifecycleState.hidden:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Overridable lifecycle hooks
  // ---------------------------------------------------------------------------

  /// Called when the app comes to the foreground.
  void onResumed() {}

  /// Called when the app goes to the background (screen off, minimised).
  void onPaused() {}

  /// Called when the Flutter engine is about to be detached from the process.
  void onDetached() {}

  /// Called when the app is inactive (e.g. incoming call, app switcher).
  void onInactive() {}

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Unregisters this observer and closes the broadcast stream.
  ///
  /// Call during app dispose — not normally needed for a singleton.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
    _listeners.clear();
  }
}
