import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

import 'permission_service.dart';

/// Reactive permission state with app-resume rechecks.
@injectable
final class PermissionViewModel with WidgetsBindingObserver {
  PermissionViewModel(this._service) {
    WidgetsBinding.instance.addObserver(this);
  }

  final PermissionService _service;
  final _statuses = signal(const <AppPermission, AppPermissionStatus>{});

  ReadonlySignal<Map<AppPermission, AppPermissionStatus>> get statuses =>
      _statuses;

  Future<AppPermissionStatus> checkAndRequest(AppPermission permission) async {
    var status = await _service.check(permission);
    if (status == AppPermissionStatus.denied) {
      status = await _service.request(permission);
    }
    _statuses.value = {..._statuses.value, permission: status};
    return status;
  }

  Future<void> recheckAll() async {
    final current = _statuses.value;
    if (current.isEmpty) return;

    final updated = Map<AppPermission, AppPermissionStatus>.from(current);
    for (final permission in current.keys) {
      updated[permission] = await _service.check(permission);
    }
    _statuses.value = updated;
  }

  bool isGranted(AppPermission permission) {
    final status = _statuses.value[permission];
    return status == AppPermissionStatus.granted ||
        status == AppPermissionStatus.limited;
  }

  Future<bool> openSettings() => _service.openSettings();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(recheckAll());
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statuses.dispose();
  }
}
