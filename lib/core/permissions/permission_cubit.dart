import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'permission_service.dart';

/// Reactive cubit that tracks [AppPermissionStatus] for each [AppPermission].
///
/// Integrates [WidgetsBindingObserver] to automatically re-check previously
/// requested permissions when the app resumes (user may have changed settings).
@injectable
class PermissionCubit extends Cubit<Map<AppPermission, AppPermissionStatus>>
    with WidgetsBindingObserver {
  PermissionCubit(this._service) : super(const {}) {
    WidgetsBinding.instance.addObserver(this);
  }

  final PermissionService _service;

  /// Checks the current status first; only requests if [denied].
  /// Updates internal state and returns the resulting [AppPermissionStatus].
  Future<AppPermissionStatus> checkAndRequest(AppPermission permission) async {
    var status = await _service.check(permission);

    if (status == AppPermissionStatus.denied) {
      status = await _service.request(permission);
    }

    _updateState(permission, status);
    return status;
  }

  /// Re-checks all permissions that have been previously requested.
  Future<void> recheckAll() async {
    if (state.isEmpty) return;

    final updated = Map<AppPermission, AppPermissionStatus>.from(state);
    for (final permission in state.keys) {
      updated[permission] = await _service.check(permission);
    }
    if (!isClosed) emit(updated);
  }

  /// Returns true if [permission] is currently [AppPermissionStatus.granted]
  /// or [AppPermissionStatus.limited].
  bool isGranted(AppPermission permission) {
    final status = state[permission];
    return status == AppPermissionStatus.granted ||
        status == AppPermissionStatus.limited;
  }

  /// Opens app settings for the user to adjust permissions manually.
  Future<bool> openSettings() => _service.openSettings();

  // ── WidgetsBindingObserver ─────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      recheckAll();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _updateState(AppPermission permission, AppPermissionStatus status) {
    if (!isClosed) {
      emit({...state, permission: status});
    }
  }
}
