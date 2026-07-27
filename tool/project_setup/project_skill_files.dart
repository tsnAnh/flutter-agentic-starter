import 'dart:io';

import 'setup_options.dart';

class ProjectSkillFiles {
  const ProjectSkillFiles(this.root);

  static const templateSkillName = 'flutter-agentic-starter';
  static const _skillRoots = [
    '.claude/skills',
    '.agents/skills',
    '.opencode/skills',
  ];
  static const _instructionFiles = [
    'README.md',
    'AGENTS.md',
    'CLAUDE.md',
    'docs/README.md',
    '.cursor/rules/flutter.mdc',
  ];

  final Directory root;

  List<String> validateRename(String skillName) {
    if (skillName == templateSkillName) return const [];
    final errors = <String>[];
    for (final skillRoot in _skillRoots) {
      final oldDirectory = _directory('$skillRoot/$templateSkillName');
      final newDirectory = _directory('$skillRoot/$skillName');
      if (oldDirectory.existsSync() && newDirectory.existsSync()) {
        errors.add('Project skill target already exists: ${newDirectory.path}');
      }
    }
    return errors;
  }

  void applyAppSkill(ProjectSetupOptions options, String skillName) {
    for (final skillRoot in _skillRoots) {
      final skillDirectory = _renameSkillDirectory(skillRoot, skillName);
      if (skillDirectory != null) {
        _updateSkillFile(skillDirectory, options, skillName);
      }
    }
    _updateInstructionFiles(skillName);
  }

  Directory? _renameSkillDirectory(String skillRoot, String skillName) {
    final oldDirectory = _directory('$skillRoot/$templateSkillName');
    final newDirectory = _directory('$skillRoot/$skillName');
    if (skillName != templateSkillName && oldDirectory.existsSync()) {
      return oldDirectory.renameSync(newDirectory.path);
    }
    if (newDirectory.existsSync()) return newDirectory;
    if (oldDirectory.existsSync()) return oldDirectory;
    return null;
  }

  void _updateSkillFile(
    Directory skillDirectory,
    ProjectSetupOptions options,
    String skillName,
  ) {
    final skillFile = File('${skillDirectory.path}/SKILL.md');
    if (!skillFile.existsSync()) return;

    var content = skillFile.readAsStringSync();
    content = content.replaceFirst(
      RegExp(r'^name: .+$', multiLine: true),
      'name: $skillName',
    );
    content = content.replaceFirst(
      RegExp(r'  Project-specific .+ implementation guidance for .+\n'),
      '  Project-specific Signals and Flutter implementation guidance for '
      '${options.appName}.\n',
    );
    content = content.replaceAll(
      '  Invoke this app-named skill first before working in this project.\n',
      '',
    );
    if (!content.contains(_skillScopeLine)) {
      content = content.replaceFirst(
        '\n---\n\n#',
        '\n  $_skillScopeLine\n---\n\n#',
      );
    }
    content = content.replaceFirst(
      RegExp(r'^# .+$', multiLine: true),
      '# ${options.appName}',
    );
    skillFile.writeAsStringSync(content);
  }

  void _updateInstructionFiles(String skillName) {
    for (final path in _instructionFiles) {
      final file = _file(path);
      if (!file.existsSync()) continue;
      var content = file.readAsStringSync();
      content = _replaceSkillNames(content, skillName);
      content = _ensureScopedActivationRule(content, skillName);
      if (path == '.cursor/rules/flutter.mdc') {
        content = _scopeCursorRule(content);
      }
      file.writeAsStringSync(content);
    }
  }

  String _replaceSkillNames(String content, String skillName) {
    return content
        .replaceAll(
          RegExp(r'- `[^`]+`(?= — Flutter/Signals/Clean Architecture rules)'),
          '- `$skillName`',
        )
        .replaceAll(
          RegExp(r'- `[^`]+`(?=: Flutter, Signals/ViewModel)'),
          '- `$skillName`',
        )
        .replaceAll(
          RegExp(
            r'Included skills: `[^`]+`, `caveman`, and `frontend-design`\.',
          ),
          'Included skills: `$skillName`, `caveman`, and `frontend-design`.',
        );
  }

  String _ensureScopedActivationRule(String content, String skillName) {
    final rule =
        'Use `$skillName` only when implementing Flutter application code or '
        'Flutter tests.';
    final existingRule = RegExp(
      r'(?:Always invoke `[^`]+` first before working in this project\.|'
      r'Use `[^`]+` only when implementing Flutter application code[\s\S]*?'
      r'(?=\n\n(?:Available skills:|##|#)|$))',
    );
    if (existingRule.hasMatch(content)) {
      return content.replaceAll(existingRule, rule);
    }
    if (content.contains('Available skills:\n')) {
      return content.replaceFirst(
        'Available skills:\n',
        'Available skills:\n\n$rule\n',
      );
    }
    if (content.contains('# Flutter Agent Rules\n')) {
      return content.replaceFirst(
        '# Flutter Agent Rules\n',
        '# Flutter Agent Rules\n\n$rule\n',
      );
    }
    return '$content\n$rule\n';
  }

  String _scopeCursorRule(String content) {
    content = content.replaceFirst(
      RegExp(r'^globs:.*$', multiLine: true),
      'globs: ["lib/**/*.dart", "test/**/*.dart", "android/**/*", '
      '"ios/**/*", "macos/**/*", "linux/**/*", "windows/**/*", '
      '"web/**/*"]',
    );
    return content.replaceFirst(
      RegExp(r'^alwaysApply:.*$', multiLine: true),
      'alwaysApply: false',
    );
  }

  File _file(String relativePath) => File('${root.path}/$relativePath');

  Directory _directory(String relativePath) =>
      Directory('${root.path}/$relativePath');

  static const _skillScopeLine =
      'Use only when implementing Flutter application code, Flutter tests, or '
      'app-platform integration.';
}
