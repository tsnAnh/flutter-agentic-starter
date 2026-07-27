import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:signals/signals.dart';

/// Wraps [Connectivity] and exposes simplified online/offline signals.
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
  final _online = signal(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Reactive network-interface availability.
  ReadonlySignal<bool> get online => _online;

  /// Reactive inverse of [online].
  late final ReadonlySignal<bool> offline = computed(() => !_online.value);

  bool get isOnline => _online.value;

  /// Start listening. Call once during app initialisation.
  Future<void> init() async {
    // Seed with current state.
    final results = await _connectivity.checkConnectivity();
    _online.value = _resultsToOnline(results);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _resultsToOnline(results);
      if (online != _online.value) _online.value = online;
    });
  }

  /// Performs an on-demand connectivity check and updates [online].
  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    _online.value = _resultsToOnline(results);
    return _online.value;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    offline.dispose();
    _online.dispose();
  }

  static bool _resultsToOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
