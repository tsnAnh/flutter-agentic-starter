import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'connectivity_service.dart';

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class ConnectivityState extends Equatable {
  const ConnectivityState();

  bool get isOnline => this is ConnectivityOnline;

  @override
  List<Object?> get props => [];
}

final class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();

  @override
  String toString() => 'ConnectivityOnline';
}

final class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();

  @override
  String toString() => 'ConnectivityOffline';
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

/// Cubit that tracks online/offline state via [ConnectivityService].
///
/// Register as a lazySingleton so the single subscription is shared app-wide.
@lazySingleton
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._service)
      : super(
          _service.isOnline
              ? const ConnectivityOnline()
              : const ConnectivityOffline(),
        );

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  /// Starts listening to [ConnectivityService]. Call once during app init.
  void startMonitoring() {
    _subscription = _service.onConnectivityChanged.listen((online) {
      emit(online ? const ConnectivityOnline() : const ConnectivityOffline());
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
