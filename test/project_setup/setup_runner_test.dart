import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/project_setup/project_files.dart';
import '../../tool/project_setup/setup_options.dart';
import '../../tool/project_setup/setup_runner.dart';

void main() {
  late Directory root;
  late List<String> commands;

  setUp(() {
    root = Directory.systemTemp.createTempSync('project_setup_runner_test_');
    File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: old_app
description: Old app
''');
    commands = [];
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('dry-run performs no writes and runs no commands', () async {
    final runner = ProjectSetupRunner(
      files: ProjectFiles(root),
      runCommand: (executable, args) async {
        commands.add('$executable ${args.join(' ')}');
        return 0;
      },
      commandExists: (_) => false,
    );

    final exitCode = await runner.run(
      const ProjectSetupOptions(
        appName: 'Acme App',
        dartPackageName: 'acme_app',
        appId: 'com.acme.app',
        organization: 'Acme',
        dryRun: true,
      ),
    );

    expect(exitCode, 0);
    expect(commands, isEmpty);
    expect(File('${root.path}/.dart_tool').existsSync(), isFalse);
    expect(
      File('${root.path}/pubspec.yaml').readAsStringSync(),
      contains('name: old_app'),
    );
  });

  test('non-dry-run executes expected bootstrap commands', () async {
    final runner = ProjectSetupRunner(
      files: ProjectFiles(root),
      runCommand: (executable, args) async {
        commands.add('$executable ${args.join(' ')}');
        return 0;
      },
      commandExists: (_) => true,
    );

    final exitCode = await runner.run(
      const ProjectSetupOptions(
        appName: 'Acme App',
        dartPackageName: 'acme_app',
        appId: 'com.acme.app',
        organization: 'Acme',
        firebaseProjectId: 'acme-prod',
        posthogApiKey: 'ph_key',
        yes: true,
      ),
    );

    expect(exitCode, 0);
    expect(commands.first, startsWith('dart run package_rename --path='));
    expect(commands, contains('flutterfire configure --project=acme-prod'));
    expect(commands, contains('flutter pub get'));
    expect(
      commands,
      contains('dart run build_runner build --delete-conflicting-outputs'),
    );
    expect(File('${root.path}/.env').existsSync(), isTrue);
  });
}
