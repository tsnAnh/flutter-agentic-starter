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
    Directory(
      '${root.path}/.agents/skills/flutter-agentic-starter',
    ).createSync(recursive: true);
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
    expect(
      Directory(
        '${root.path}/.agents/skills/flutter-agentic-starter',
      ).existsSync(),
      isTrue,
    );
    expect(
      Directory('${root.path}/.agents/skills/acme-app').existsSync(),
      isFalse,
    );
    expect(File('${root.path}/.claude/settings.json').existsSync(), isFalse);
    expect(File('${root.path}/.codex/hooks.json').existsSync(), isFalse);
  });

  test('project skill conflict exits before running commands', () async {
    Directory(
      '${root.path}/.agents/skills/flutter-agentic-starter',
    ).createSync(recursive: true);
    Directory(
      '${root.path}/.agents/skills/acme-app',
    ).createSync(recursive: true);
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
      ),
    );

    expect(exitCode, 64);
    expect(commands, isEmpty);
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
    expect(File('${root.path}/.claude/settings.json').existsSync(), isTrue);
    expect(File('${root.path}/.codex/hooks.json').existsSync(), isTrue);
  });

  test('skip-agent-hooks avoids hook config writes', () async {
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
        skipAgentHooks: true,
        skipFirebase: true,
        skipPosthog: true,
        skipPubGet: true,
        skipBuildRunner: true,
      ),
    );

    expect(exitCode, 0);
    expect(File('${root.path}/.claude/settings.json').existsSync(), isFalse);
    expect(File('${root.path}/.codex/hooks.json').existsSync(), isFalse);
  });

  test('invalid existing hook config exits before commands', () async {
    File('${root.path}/.claude/settings.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{bad json');
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
      ),
    );

    expect(exitCode, 64);
    expect(commands, isEmpty);
  });
}
