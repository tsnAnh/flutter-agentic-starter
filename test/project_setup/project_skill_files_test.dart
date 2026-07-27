import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/project_setup/project_skill_files.dart';
import '../../tool/project_setup/setup_options.dart';

void main() {
  late Directory root;
  late ProjectSkillFiles files;

  setUp(() {
    root = Directory.systemTemp.createTempSync('project_skill_files_test_');
    files = ProjectSkillFiles(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('renames project skills and updates skill metadata', () {
    for (final skillRoot in _skillRoots) {
      _writeFile(
        root,
        '$skillRoot/flutter-agentic-starter/SKILL.md',
        _skillContent,
      );
    }
    _writeInstructionFiles(root);

    files.applyAppSkill(_options, 'acme-crm');

    for (final skillRoot in _skillRoots) {
      expect(
        Directory(
          '${root.path}/$skillRoot/flutter-agentic-starter',
        ).existsSync(),
        isFalse,
      );
      final skillFile = File('${root.path}/$skillRoot/acme-crm/SKILL.md');
      expect(skillFile.existsSync(), isTrue);
      final content = skillFile.readAsStringSync();
      expect(content, contains('name: acme-crm'));
      expect(content, contains('guidance for Acme CRM.'));
      expect(
        content,
        contains('Use only when implementing Flutter application code'),
      );
      expect(content, isNot(contains('Invoke this app-named skill first')));
      expect(content, contains('# Acme CRM'));
    }

    expect(
      File('${root.path}/README.md').readAsStringSync(),
      contains('- `acme-crm` — Flutter/Signals/Clean Architecture rules'),
    );
    expect(
      File('${root.path}/AGENTS.md').readAsStringSync(),
      contains('- `acme-crm`: Flutter, Signals/ViewModel'),
    );
    expect(
      File('${root.path}/CLAUDE.md').readAsStringSync(),
      contains(
        'Use `acme-crm` only when implementing Flutter application code',
      ),
    );
    expect(
      File('${root.path}/docs/README.md').readAsStringSync(),
      contains(
        'Included skills: `acme-crm`, `caveman`, and `frontend-design`.',
      ),
    );
    expect(
      File('${root.path}/.cursor/rules/flutter.mdc').readAsStringSync(),
      contains(
        'Use `acme-crm` only when implementing Flutter application code',
      ),
    );
    final cursorRules = File(
      '${root.path}/.cursor/rules/flutter.mdc',
    ).readAsStringSync();
    expect(cursorRules, contains('alwaysApply: false'));
    expect(cursorRules, contains('"lib/**/*.dart"'));
  });

  test('reports strict rename conflict', () {
    _writeFile(
      root,
      '.agents/skills/flutter-agentic-starter/SKILL.md',
      _skillContent,
    );
    _writeFile(root, '.agents/skills/acme-crm/SKILL.md', _skillContent);

    final errors = files.validateRename('acme-crm');

    expect(errors, hasLength(1));
    expect(errors.single, contains('.agents/skills/acme-crm'));
  });

  test('updates existing app skill when rerun', () {
    _writeFile(root, '.agents/skills/acme-crm/SKILL.md', _skillContent);

    files.applyAppSkill(_options, 'acme-crm');

    final content = File(
      '${root.path}/.agents/skills/acme-crm/SKILL.md',
    ).readAsStringSync();
    expect(content, contains('name: acme-crm'));
    expect(content, contains('# Acme CRM'));
  });
}

void _writeInstructionFiles(Directory root) {
  _writeFile(root, 'README.md', '''
Available skills:

- `flutter-agentic-starter` — Flutter/Signals/Clean Architecture rules
''');
  _writeFile(root, 'AGENTS.md', '''
Available skills:

- `flutter-agentic-starter`: Flutter, Signals/ViewModel guidance.
''');
  _writeFile(root, 'CLAUDE.md', '''
Available skills:

- `flutter-agentic-starter`: Flutter, Signals/ViewModel guidance.
''');
  _writeFile(
    root,
    'docs/README.md',
    'Included skills: `flutter-agentic-starter`, `caveman`, and '
        '`frontend-design`.\n',
  );
  _writeFile(root, '.cursor/rules/flutter.mdc', '''
---
globs:
alwaysApply: true
---
# Flutter Agent Rules

## Flutter Rules
''');
}

void _writeFile(Directory root, String path, String content) {
  final file = File('${root.path}/$path');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

const _options = ProjectSetupOptions(
  appName: 'Acme CRM',
  dartPackageName: 'acme_crm',
  appId: 'com.acme.crm',
  organization: 'Acme',
);

const _skillRoots = ['.claude/skills', '.agents/skills', '.opencode/skills'];

const _skillContent = '''
---
name: flutter-agentic-starter
description: >
  Project-specific Flutter/Dart implementation guidance for flutter-agentic-starter.
  Use only when implementing Flutter application code, Flutter tests, or app-platform
  integration. Do not use for docs, setup tooling, or repository maintenance.
---

# Flutter Agentic Starter

Follow repo docs first.
''';
