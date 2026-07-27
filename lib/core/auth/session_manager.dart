import 'dart:async';

import 'package:signals/signals.dart';

/// Events emitted by [SessionManager].
enum SessionEvent {
  /// The user's session has expired due to inactivity.
  sessionExpired,

  /// A session was explicitly ended (logout).
  sessionEnded,
}

/// Tracks user session activity and emits [SessionEvent]s via a broadcast stream.
///
/// Usage:
/// ```dart
/// sessionManager.startSession();
/// sessionManager.recordActivity(); // call on user interaction
/// sessionManager.events.listen((e) { ... });
/// ```
///
/// Phase 8 (AppLifecycleObserver) should call [recordActivity] on foreground
/// resume and [endSession] when the app is terminated.
///
/// Registered via [RegisterModule] in get_it.dart (not annotated) to avoid
/// injectable trying to inject the optional [Duration] typed param.
class SessionManager {
  SessionManager({Duration? inactivityTimeout})
    : _inactivityTimeout = inactivityTimeout ?? const Duration(minutes: 30);

  final Duration _inactivityTimeout;

  final _controller = StreamController<SessionEvent>.broadcast();
  final _active = signal(false);
  Timer? _inactivityTimer;

  /// Stream of [SessionEvent]s — subscribe before calling [startSession].
  Stream<SessionEvent> get events => _controller.stream;

  /// Reactive session state. New app launches always start signed out.
  ReadonlySignal<bool> get active => _active;

  /// Whether a session is currently active.
  bool get isActive => _active.value;

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  /// Starts a new session and kicks off the inactivity timer.
  ///
  /// Safe to call multiple times; redundant calls are no-ops.
  ///
  /// TOCTOU note: the check-then-set pattern on [_active] is safe here because
  /// Dart's event loop is single-threaded. No other microtask or event can
  /// interleave between reading and updating the signal, so
  /// there is no observable race condition.
  void startSession() {
    if (_active.value) return;
    _active.value = true;
    _resetTimer();
  }

  /// Records user activity — resets the inactivity countdown.
  ///
  /// No-op when no session is active.
  void recordActivity() {
    if (!_active.value) return;
    _resetTimer();
  }

  /// Ends the session explicitly (e.g. user logout) and emits [SessionEvent.sessionEnded].
  void endSession() {
    if (!_active.value) return;
    _cancelTimer();
    _active.value = false;
    _emit(SessionEvent.sessionEnded);
  }

  /// Releases all resources. Call once when the app is disposed.
  void dispose() {
    _cancelTimer();
    _active.dispose();
    _controller.close();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _resetTimer() {
    _cancelTimer();
    _inactivityTimer = Timer(_inactivityTimeout, _onInactivityTimeout);
  }

  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _onInactivityTimeout() {
    _active.value = false;
    _emit(SessionEvent.sessionExpired);
  }

  void _emit(SessionEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }
}
