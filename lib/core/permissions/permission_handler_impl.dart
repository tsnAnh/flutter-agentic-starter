import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'permission_service.dart';

/// Maps app-specific [AppPermission] to permission_handler [ph.Permission].
ph.Permission _toPhPermission(AppPermission permission) {
  switch (permission) {
    case AppPermission.camera:
      return ph.Permission.camera;
    case AppPermission.photos:
      return ph.Permission.photos;
    case AppPermission.location:
      return ph.Permission.location;
    case AppPermission.notifications:
      return ph.Permission.notification;
    case AppPermission.microphone:
      return ph.Permission.microphone;
    case AppPermission.storage:
      return ph.Permission.storage;
  }
}

/// Maps permission_handler [ph.PermissionStatus] to [AppPermissionStatus].
AppPermissionStatus _toAppStatus(ph.PermissionStatus status) {
  switch (status) {
    case ph.PermissionStatus.granted:
      return AppPermissionStatus.granted;
    case ph.PermissionStatus.denied:
      return AppPermissionStatus.denied;
    case ph.PermissionStatus.permanentlyDenied:
      return AppPermissionStatus.permanentlyDenied;
    case ph.PermissionStatus.restricted:
      return AppPermissionStatus.restricted;
    case ph.PermissionStatus.limited:
      return AppPermissionStatus.limited;
    case ph.PermissionStatus.provisional:
      return AppPermissionStatus.granted;
  }
}

/// Concrete [PermissionService] backed by the permission_handler package.
@LazySingleton(as: PermissionService)
class PermissionHandlerImpl implements PermissionService {
  @override
  Future<AppPermissionStatus> check(AppPermission permission) async {
    final status = await _toPhPermission(permission).status;
    return _toAppStatus(status);
  }

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async {
    final status = await _toPhPermission(permission).request();
    return _toAppStatus(status);
  }

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}
