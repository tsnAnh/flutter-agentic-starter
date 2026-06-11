import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/project_setup/project_files.dart';
import '../../tool/project_setup/setup_options.dart';

void main() {
  late Directory root;
  late ProjectFiles files;

  setUp(() {
    root = Directory.systemTemp.createTempSync('project_setup_files_test_');
    files = ProjectFiles(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('pubspec edit preserves comments and updates exact fields', () {
    File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: old_app
description: Old description # keep inline comment

# dependency comment
dependencies:
  flutter:
    sdk: flutter
''');

    files.updatePubspec(
      const ProjectSetupOptions(
        appName: 'Acme App',
        dartPackageName: 'acme_app',
        appId: 'com.acme.app',
        organization: 'Acme',
        description: 'New description',
      ),
    );

    final updated = File('${root.path}/pubspec.yaml').readAsStringSync();
    expect(updated, contains('name: acme_app'));
    expect(updated, contains('description: New description'));
    expect(updated, contains('# keep inline comment'));
    expect(updated, contains('# dependency comment'));
  });

  test('.env writer skips existing file and gitignore tracks env rule', () {
    File('${root.path}/.env').writeAsStringSync('POSTHOG_API_KEY=secret\n');
    File('${root.path}/.gitignore').writeAsStringSync('build/\n');

    final wroteEnv = files.writeEnvIfMissing(
      const ProjectSetupOptions(
        appName: 'Acme App',
        dartPackageName: 'acme_app',
        appId: 'com.acme.app',
        organization: 'Acme',
        posthogApiKey: 'new-secret',
      ),
    );
    final updatedGitignore = files.ensureGitignoreEnv();

    expect(wroteEnv, isFalse);
    expect(updatedGitignore, isTrue);
    expect(
      File('${root.path}/.env').readAsStringSync(),
      'POSTHOG_API_KEY=secret\n',
    );
    expect(
      File('${root.path}/.gitignore').readAsStringSync(),
      contains('.env'),
    );
  });

  test('package rename config includes platform values', () {
    final path = files.writePackageRenameConfig(
      const ProjectSetupOptions(
        appName: 'Acme App',
        dartPackageName: 'acme_app',
        appId: 'com.acme.app',
        organization: 'Acme',
      ),
    );

    final config = File(path).readAsStringSync();
    expect(config, contains('package_rename_config:'));
    expect(config, contains('app_name: "Acme App"'));
    expect(config, contains('package_name: "com.acme.app"'));
    expect(config, contains('exe_name: "acme_app"'));
  });

  test('firebase initializer uses generated options when present', () {
    Directory('${root.path}/lib/core/firebase').createSync(recursive: true);
    File(
      '${root.path}/lib/firebase_options.dart',
    ).writeAsStringSync('class DefaultFirebaseOptions {}\n');
    File(
      '${root.path}/lib/core/firebase/firebase_initializer.dart',
    ).writeAsStringSync('''
import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
''');

    final changed = files.updateFirebaseInitializerIfGenerated('acme_app');
    final initializer = File(
      '${root.path}/lib/core/firebase/firebase_initializer.dart',
    ).readAsStringSync();

    expect(changed, isTrue);
    expect(
      initializer,
      contains("import 'package:acme_app/firebase_options.dart';"),
    );
    expect(
      initializer,
      contains('options: DefaultFirebaseOptions.currentPlatform'),
    );
  });
}
