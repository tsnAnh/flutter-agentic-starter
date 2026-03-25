import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] from connectivity_plus and exposes a simplified
/// online/offline stream.
///
/// Note: connectivity_plus reports network interface availability, not actual
/// internet reachability. For production apps, combine with an HTTP head-check.
///
/// Registered via [RegisterModule] in get_it.dart (not annotated) to avoid
/// injectable trying to inject the optional [Connectivity] typed parameter.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// Broadcast stream of connectivity state — true = online, false = offline.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Start listening. Call once during app initialisation.
  Future<void> init() async {
    // Seed with current state.
    final results = await _connectivity.checkConnectivity();
    _isOnline = _resultsToOnline(results);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _resultsToOnline(results);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
    });
  }

  /// Performs an on-demand connectivity check (does not emit to stream).
  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _resultsToOnline(results);
    return _isOnline;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }

  static bool _resultsToOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
