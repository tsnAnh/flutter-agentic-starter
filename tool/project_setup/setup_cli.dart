import 'dart:io';

import 'package:args/args.dart';

import 'setup_options.dart';

ProjectSetupOptions? parseProjectSetupOptions(
  List<String> arguments, {
  required String currentPackageName,
}) {
  final parser = _buildParser();
  final results = parser.parse(arguments);

  if (results.flag('help')) {
    stdout.writeln('Usage: dart run project_setup [options]\n');
    stdout.writeln(parser.usage);
    return null;
  }

  final yes = results.flag('yes');
  final defaultAppName = ProjectSetupOptions.deriveAppName(currentPackageName);
  final appName = _readValue(
    results,
    'app-name',
    'App name',
    defaultAppName,
    yes,
  );
  final defaultPackageName = ProjectSetupOptions.deriveDartPackageName(appName);
  final dartPackageName = _readValue(
    results,
    'dart-package-name',
    'Dart package name',
    defaultPackageName,
    yes,
  );
  final organization = _readValue(
    results,
    'organization',
    'Organization',
    'Example',
    yes,
  );
  final appId = _readValue(
    results,
    'app-id',
    'Native app ID',
    ProjectSetupOptions.deriveAppId(organization, dartPackageName),
    yes,
  );

  final skipFirebase = results.flag('skip-firebase');
  final skipPosthog = results.flag('skip-posthog');
  final firebaseProjectId = skipFirebase
      ? null
      : _readOptionalValue(
          results,
          'firebase-project-id',
          'Firebase project ID (blank to skip)',
          yes,
        );
  final posthogApiKey = skipPosthog
      ? null
      : _readOptionalValue(
          results,
          'posthog-api-key',
          'PostHog API key (blank to leave empty)',
          yes,
        );
  final posthogHost = skipPosthog
      ? 'https://app.posthog.com'
      : _readValue(
          results,
          'posthog-host',
          'PostHog host',
          'https://app.posthog.com',
          yes,
        );

  return ProjectSetupOptions(
    appName: appName,
    dartPackageName: dartPackageName,
    appId: appId,
    organization: organization,
    description: _option(results, 'description'),
    posthogApiKey: posthogApiKey,
    posthogHost: posthogHost,
    firebaseProjectId: firebaseProjectId,
    yes: yes,
    dryRun: results.flag('dry-run'),
    skipFirebase: skipFirebase,
    skipPosthog: skipPosthog,
    skipPubGet: results.flag('skip-pub-get'),
    skipBuildRunner: results.flag('skip-build-runner'),
  );
}

ArgParser _buildParser() {
  return ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('app-name')
    ..addOption('dart-package-name')
    ..addOption('app-id', aliases: ['package-name', 'bundle-id'])
    ..addOption('organization')
    ..addOption('description')
    ..addOption('firebase-project-id')
    ..addOption('posthog-api-key')
    ..addOption('posthog-host')
    ..addFlag('yes', abbr: 'y', negatable: false)
    ..addFlag('dry-run', negatable: false)
    ..addFlag('skip-firebase', negatable: false)
    ..addFlag('skip-posthog', negatable: false)
    ..addFlag('skip-pub-get', negatable: false)
    ..addFlag('skip-build-runner', negatable: false);
}

String _readValue(
  ArgResults results,
  String option,
  String label,
  String defaultValue,
  bool yes,
) {
  final value = _option(results, option);
  if (value != null) return value;
  if (yes) return defaultValue;
  stdout.write('$label [$defaultValue]: ');
  final line = stdin.readLineSync()?.trim();
  return line == null || line.isEmpty ? defaultValue : line;
}

String? _readOptionalValue(
  ArgResults results,
  String option,
  String label,
  bool yes,
) {
  final value = _option(results, option);
  if (value != null || yes) return value;
  stdout.write('$label: ');
  final line = stdin.readLineSync()?.trim();
  return line == null || line.isEmpty ? null : line;
}

String? _option(ArgResults results, String option) {
  final value = results[option] as String?;
  if (value == null || value.trim().isEmpty) return null;
  return value.trim();
}
