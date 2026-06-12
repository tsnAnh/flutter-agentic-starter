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
      RegExp(
        r'  Project-specific Flutter/Dart implementation guidance for .+\n',
      ),
      '  Project-specific Flutter/Dart implementation guidance for '
      '${options.appName}.\n',
    );
    if (!content.contains(_skillInvocationLine)) {
      content = content.replaceFirst(
        '  Use when working on Flutter code,',
        '  $_skillInvocationLine\n'
            '  Use when working on Flutter code,',
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
      content = _ensureInvocationRule(content, skillName);
      file.writeAsStringSync(content);
    }
  }

  String _replaceSkillNames(String content, String skillName) {
    return content
        .replaceAll(
          RegExp(r'- `[^`]+`(?= — Flutter/BLoC/Clean Architecture rules)'),
          '- `$skillName`',
        )
        .replaceAll(
          RegExp(r'- `[^`]+`(?=: Flutter, BLoC/Cubit)'),
          '- `$skillName`',
        )
        .replaceAll(
          RegExp(
            r'Included skills: `[^`]+`, `caveman`, and `frontend-design`\.',
          ),
          'Included skills: `$skillName`, `caveman`, and `frontend-design`.',
        );
  }

  String _ensureInvocationRule(String content, String skillName) {
    final rule =
        'Always invoke `$skillName` first before working in this '
        'project.';
    final existingRule = RegExp(
      r'Always invoke `[^`]+` first before working in this project\.',
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

  File _file(String relativePath) => File('${root.path}/$relativePath');

  Directory _directory(String relativePath) =>
      Directory('${root.path}/$relativePath');

  static const _skillInvocationLine =
      'Invoke this app-named skill first before working in this project.';
}
