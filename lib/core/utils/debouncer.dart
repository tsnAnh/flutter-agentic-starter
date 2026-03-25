import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays execution of [run] until [milliseconds] have elapsed
/// since the last call. Useful for search inputs and rapid events.
class Debouncer {
  Debouncer({this.milliseconds = 300});

  final int milliseconds;
  Timer? _timer;

  /// Cancels any pending call and schedules [action] after the delay.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels the pending timer. Call in dispose().
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
