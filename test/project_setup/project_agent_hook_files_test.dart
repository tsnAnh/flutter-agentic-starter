import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/project_setup/project_agent_hook_files.dart';

void main() {
  late Directory root;
  late ProjectAgentHookFiles files;

  setUp(() {
    root = Directory.systemTemp.createTempSync('project_agent_hooks_test_');
    files = ProjectAgentHookFiles(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('installs Claude Code and Codex hook configs', () {
    files.install();

    final claude = _readJson(root, '.claude/settings.json');
    final codex = _readJson(root, '.codex/hooks.json');

    final claudePostToolUse = _postToolUseHooks(claude);
    final codexPostToolUse = _postToolUseHooks(codex);

    expect(claudePostToolUse, hasLength(1));
    expect(codexPostToolUse, hasLength(1));
    expect(
      _hookCommand(claudePostToolUse.first),
      contains('check_source_file_line_count.dart'),
    );
    expect(
      File('${root.path}/.gitignore').readAsStringSync(),
      contains('!.claude/settings.json'),
    );
    expect(
      File('${root.path}/.gitignore').readAsStringSync(),
      contains('!.codex/**'),
    );
  });

  test('keeps existing hook config and avoids duplicate generated hooks', () {
    _writeFile(root, '.claude/settings.json', '''
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "echo kept"}
        ]
      }
    ]
  }
}
''');

    files.install();
    files.install();

    final hooks = _postToolUseHooks(_readJson(root, '.claude/settings.json'));
    expect(hooks, hasLength(2));
    expect(jsonEncode(hooks), contains('echo kept'));
    expect(
      hooks.where(
        (Map<String, dynamic> hook) =>
            hook['matcher'] == 'Write|Edit|MultiEdit',
      ),
      hasLength(1),
    );
  });

  test('invalid existing JSON fails validation', () {
    _writeFile(root, '.codex/hooks.json', '{bad json');

    expect(files.validateExistingJson, throwsFormatException);
  });
}

Map<String, dynamic> _readJson(Directory root, String path) {
  final decoded = jsonDecode(File('${root.path}/$path').readAsStringSync());
  return decoded as Map<String, dynamic>;
}

List<Map<String, dynamic>> _postToolUseHooks(Map<String, dynamic> config) {
  final hooks = config['hooks'] as Map<String, dynamic>;
  final postToolUse = hooks['PostToolUse'] as List<dynamic>;
  return postToolUse.cast<Map<String, dynamic>>();
}

String _hookCommand(Map<String, dynamic> hookGroup) {
  final hooks = hookGroup['hooks'] as List<dynamic>;
  final hook = hooks.first as Map<String, dynamic>;
  return hook['command'] as String;
}

void _writeFile(Directory root, String path, String content) {
  final file = File('${root.path}/$path');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
