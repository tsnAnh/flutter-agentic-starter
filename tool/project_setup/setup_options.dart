class ProjectSetupOptions {
  const ProjectSetupOptions({
    required this.appName,
    required this.dartPackageName,
    required this.appId,
    required this.organization,
    this.description,
    this.posthogApiKey,
    this.posthogHost = 'https://app.posthog.com',
    this.firebaseProjectId,
    this.yes = false,
    this.dryRun = false,
    this.skipFirebase = false,
    this.skipPosthog = false,
    this.skipAgentHooks = false,
    this.skipPubGet = false,
    this.skipBuildRunner = false,
  });

  final String appName;
  final String dartPackageName;
  final String appId;
  final String organization;
  final String? description;
  final String? posthogApiKey;
  final String posthogHost;
  final String? firebaseProjectId;
  final bool yes;
  final bool dryRun;
  final bool skipFirebase;
  final bool skipPosthog;
  final bool skipAgentHooks;
  final bool skipPubGet;
  final bool skipBuildRunner;

  List<String> validate() {
    final errors = <String>[];
    if (appName.trim().isEmpty) {
      errors.add('App name is required.');
    }
    if (!_dartPackageNamePattern.hasMatch(dartPackageName)) {
      errors.add('Dart package name must be lower_snake_case, e.g. acme_app.');
    }
    if (!_isValidAppId(appId)) {
      errors.add('App ID must be reverse-domain style, e.g. com.acme.app.');
    }
    if (organization.trim().isEmpty) {
      errors.add('Organization is required.');
    }
    if (!skipPosthog && posthogHost.trim().isEmpty) {
      errors.add('PostHog host is required unless --skip-posthog is set.');
    }
    return errors;
  }

  static String deriveAppName(String packageName) {
    return packageName
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String deriveDartPackageName(String appName) {
    var name = appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    name = name.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (name.isEmpty) return 'my_app';
    if (RegExp(r'^[0-9]').hasMatch(name)) return 'app_$name';
    return name;
  }

  static String deriveAppId(String organization, String dartPackageName) {
    final org = organization
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
        .replaceAll(RegExp(r'\.+'), '.')
        .replaceAll(RegExp(r'^\.|\.$'), '');
    final middle = org.isEmpty ? 'example' : org.split('.').first;
    return 'com.$middle.$dartPackageName';
  }

  static String deriveSkillName(String appName) {
    var name = appName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (name.isEmpty) return 'my-app';
    if (name.length > 63) {
      name = name.substring(0, 63).replaceAll(RegExp(r'-+$'), '');
    }
    return name.isEmpty ? 'my-app' : name;
  }

  static bool _isValidAppId(String value) {
    final parts = value.split('.');
    if (parts.length < 2 || parts.any((part) => part.isEmpty)) {
      return false;
    }
    return parts.every((part) => _appIdSegmentPattern.hasMatch(part));
  }

  static final _dartPackageNamePattern = RegExp(r'^[a-z][a-z0-9_]*$');
  static final _appIdSegmentPattern = RegExp(r'^[A-Za-z][A-Za-z0-9_]*$');
}
