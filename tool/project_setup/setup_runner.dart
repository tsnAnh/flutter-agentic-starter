import 'dart:io';

import 'project_files.dart';
import 'project_skill_files.dart';
import 'setup_options.dart';

typedef CommandRunner =
    Future<int> Function(String executable, List<String> args);
typedef CommandExists = bool Function(String executable);
typedef ConfirmPrompt = bool Function(String message);

class ProjectSetupRunner {
  ProjectSetupRunner({
    required this.files,
    ProjectSkillFiles? skillFiles,
    CommandRunner? runCommand,
    CommandExists? commandExists,
    ConfirmPrompt? confirm,
    Stdout? out,
  }) : _skillFiles = skillFiles ?? ProjectSkillFiles(files.root),
       _runCommand = runCommand ?? _defaultRunCommand,
       _commandExists = commandExists ?? _defaultCommandExists,
       _confirm = confirm ?? _defaultConfirm,
       _out = out ?? stdout;

  final ProjectFiles files;
  final ProjectSkillFiles _skillFiles;
  final CommandRunner _runCommand;
  final CommandExists _commandExists;
  final ConfirmPrompt _confirm;
  final Stdout _out;

  Future<int> run(ProjectSetupOptions options) async {
    final errors = options.validate();
    if (errors.isNotEmpty) {
      for (final error in errors) {
        _out.writeln('Error: $error');
      }
      return 64;
    }

    final skillName = ProjectSetupOptions.deriveSkillName(options.appName);
    final skillErrors = _skillFiles.validateRename(skillName);
    if (skillErrors.isNotEmpty) {
      for (final error in skillErrors) {
        _out.writeln('Error: $error');
      }
      return 64;
    }

    final oldPackage = files.readPubspecName();
    if (options.dryRun) {
      _printDryRunPlan(options, oldPackage, skillName);
      return 0;
    }

    final configPath = files.writePackageRenameConfig(options);
    final renameExit = await _runCommand('dart', [
      'run',
      'package_rename',
      '--path=$configPath',
    ]);
    if (renameExit != 0) return renameExit;

    files.updatePubspec(options);
    files.rewriteDartPackageImports(oldPackage, options.dartPackageName);
    _skillFiles.applyAppSkill(options, skillName);

    if (!options.skipPosthog) {
      files.writeEnvIfMissing(options);
      files.ensureGitignoreEnv();
    }

    final firebaseExit = await _configureFirebase(options);
    if (firebaseExit != 0) return firebaseExit;

    if (!options.skipPubGet) {
      final pubGetExit = await _runCommand('flutter', ['pub', 'get']);
      if (pubGetExit != 0) return pubGetExit;
    }

    if (!options.skipBuildRunner) {
      return _runCommand('dart', [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);
    }
    return 0;
  }

  Future<int> _configureFirebase(ProjectSetupOptions options) async {
    final projectId = options.firebaseProjectId;
    if (options.skipFirebase || projectId == null || projectId.isEmpty) {
      return 0;
    }

    var hasFlutterFire = _commandExists('flutterfire');
    if (!hasFlutterFire) {
      if (options.yes || _confirm('Install FlutterFire CLI?')) {
        final installExit = await _runCommand('dart', [
          'pub',
          'global',
          'activate',
          'flutterfire_cli',
        ]);
        if (installExit != 0) return installExit;
        hasFlutterFire = true;
      }
    }

    if (!hasFlutterFire) return 0;
    if (options.yes || _confirm('Run flutterfire configure for $projectId?')) {
      final configureExit = await _runCommand('flutterfire', [
        'configure',
        '--project=$projectId',
      ]);
      if (configureExit != 0) return configureExit;
      files.updateFirebaseInitializerIfGenerated(options.dartPackageName);
    }
    return 0;
  }

  void _printDryRunPlan(
    ProjectSetupOptions options,
    String oldPackage,
    String skillName,
  ) {
    _out.writeln('Dry run. No files written. No commands run.');
    _out.writeln(
      '- Native rename: dart run package_rename --path=.dart_tool/project_setup/package_rename_config.yaml',
    );
    _out.writeln(
      '- pubspec.yaml name: $oldPackage -> ${options.dartPackageName}',
    );
    _out.writeln(
      '- Dart package imports: package:$oldPackage/ -> package:${options.dartPackageName}/',
    );
    _out.writeln(
      '- Project skill: ${ProjectSkillFiles.templateSkillName} -> $skillName',
    );
    _out.writeln('- Agent instructions: invoke `$skillName` first');
    if (!options.skipPosthog) {
      _out.writeln('- .env: create only if missing; .gitignore: ensure .env');
    }
    if (!options.skipFirebase &&
        (options.firebaseProjectId?.isNotEmpty ?? false)) {
      _out.writeln(
        '- Firebase: flutterfire configure --project=${options.firebaseProjectId}',
      );
    }
    if (!options.skipPubGet) _out.writeln('- Command: flutter pub get');
    if (!options.skipBuildRunner) {
      _out.writeln(
        '- Command: dart run build_runner build --delete-conflicting-outputs',
      );
    }
  }

  static Future<int> _defaultRunCommand(
    String executable,
    List<String> args,
  ) async {
    final process = await Process.start(
      executable,
      args,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  static bool _defaultCommandExists(String executable) {
    final command = Platform.isWindows ? 'where' : 'which';
    final result = Process.runSync(command, [executable]);
    return result.exitCode == 0;
  }

  static bool _defaultConfirm(String message) {
    stdout.write('$message [y/N] ');
    final response = stdin.readLineSync()?.trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }
}
