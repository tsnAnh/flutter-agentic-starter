import 'package:flutter_test/flutter_test.dart';

import '../../tool/project_setup/setup_cli.dart';
import '../../tool/project_setup/setup_options.dart';

void main() {
  group('ProjectSetupOptions defaults', () {
    test('derives readable app name from package name', () {
      expect(
        ProjectSetupOptions.deriveAppName('flutter_bloc_base_source_code'),
        'Flutter Bloc Base Source Code',
      );
    });

    test('derives valid Dart package name', () {
      expect(
        ProjectSetupOptions.deriveDartPackageName('Acme App! 2026'),
        'acme_app_2026',
      );
      expect(
        ProjectSetupOptions.deriveDartPackageName('123 App'),
        'app_123_app',
      );
    });

    test('derives reverse-domain app ID from organization', () {
      expect(
        ProjectSetupOptions.deriveAppId('Acme, Inc.', 'acme_app'),
        'com.acme.acme_app',
      );
    });
  });

  group('ProjectSetupOptions validation', () {
    test('accepts valid noninteractive input and aliases', () {
      final options = parseProjectSetupOptions([
        '--app-name',
        'Acme App',
        '--dart-package-name',
        'acme_app',
        '--bundle-id',
        'com.acme.app',
        '--organization',
        'Acme',
        '--skip-firebase',
        '--skip-posthog',
        '--yes',
      ], currentPackageName: 'starter')!;

      expect(options.appId, 'com.acme.app');
      expect(options.validate(), isEmpty);
    });

    test('rejects invalid names', () {
      const options = ProjectSetupOptions(
        appName: '',
        dartPackageName: 'Acme-App',
        appId: 'not valid',
        organization: '',
      );

      expect(options.validate(), hasLength(4));
    });
  });
}
