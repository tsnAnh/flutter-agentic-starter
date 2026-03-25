import 'dart:async';

import 'package:flutter/foundation.dart';

/// Ensures [run] executes at most once per [milliseconds] window.
/// Subsequent calls within the window are ignored.
class Throttler {
  Throttler({this.milliseconds = 300});

  final int milliseconds;
  Timer? _timer;
  bool _isReady = true;

  /// Executes [action] immediately if ready, then blocks for [milliseconds].
  void run(VoidCallback action) {
    if (!_isReady) return;
    _isReady = false;
    action();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _isReady = true;
    });
  }

  /// Cancels any active throttle window. Call in dispose().
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isReady = true;
  }
}
