import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../firebase/remote_config_service.dart';

/// Possible outcomes of [AppUpdateChecker.checkForUpdate].
enum UpdateStatus {
  /// App version meets or exceeds the minimum required.
  upToDate,

  /// App version is below minimum but the update is not forced.
  softUpdate,

  /// App version is below minimum AND force_update_enabled is true.
  forceUpdate,

  /// Service is in maintenance mode — app should show maintenance screen.
  maintenance,
}

/// Reads Remote Config flags to determine whether the running app needs an update.
///
/// Remote Config keys consumed:
/// - `minimum_app_version` (String) — e.g. "2.1.0"
/// - `force_update_enabled` (bool)  — if true + version outdated → forceUpdate
/// - `maintenance_mode`     (bool)  — if true → maintenance (checked first)
@LazySingleton()
class AppUpdateChecker {
  AppUpdateChecker(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [UpdateStatus] for the currently running app build.
  ///
  /// Fetches [PackageInfo] from the OS and compares against Remote Config.
  /// Never throws — falls back to [UpdateStatus.upToDate] on any error.
  Future<UpdateStatus> checkForUpdate() async {
    try {
      // 1. Maintenance takes precedence over everything else.
      if (_remoteConfig.getBool('maintenance_mode')) {
        return UpdateStatus.maintenance;
      }

      final info = await PackageInfo.fromPlatform();
      final current = _parseVersion(info.version);
      final minimum = _parseVersion(
        _remoteConfig.getString(
          'minimum_app_version',
          defaultValue: '1.0.0',
        ),
      );

      if (current == null || minimum == null) return UpdateStatus.upToDate;

      final outdated = _isOlderThan(current, minimum);
      if (!outdated) return UpdateStatus.upToDate;

      // 2. Version is below minimum — check force flag.
      final forced = _remoteConfig.getBool('force_update_enabled');
      return forced ? UpdateStatus.forceUpdate : UpdateStatus.softUpdate;
    } on Exception catch (e) {
      debugPrint('[AppUpdateChecker] checkForUpdate error: $e');
      return UpdateStatus.upToDate;
    }
  }

  // ---------------------------------------------------------------------------
  // Semantic version helpers
  // ---------------------------------------------------------------------------

  /// Parses a "major.minor.patch" string into a list of three ints.
  ///
  /// Returns null if the string is malformed.
  List<int>? _parseVersion(String raw) {
    final parts = raw.trim().split('.');
    if (parts.length < 3) return null;
    final ints = parts.take(3).map(int.tryParse).toList();
    if (ints.any((v) => v == null)) return null;
    return ints.cast<int>();
  }

  /// Returns true when [a] is strictly older than [b] (major.minor.patch).
  bool _isOlderThan(List<int> a, List<int> b) {
    for (var i = 0; i < 3; i++) {
      if (a[i] < b[i]) return true;
      if (a[i] > b[i]) return false;
    }
    return false; // equal — not older
  }
}
