/// App-specific permission types — decoupled from permission_handler package.
enum AppPermission {
  camera,
  photos,
  location,
  notifications,
  microphone,
  storage,
}

/// App-specific permission status — mirrors permission_handler statuses.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

/// Abstract contract for checking and requesting platform permissions.
abstract class PermissionService {
  /// Checks current status of [permission] without prompting the user.
  Future<AppPermissionStatus> check(AppPermission permission);

  /// Requests [permission] from the user; returns updated status.
  Future<AppPermissionStatus> request(AppPermission permission);

  /// Opens the app settings page for the user to change permissions manually.
  Future<bool> openSettings();
}
