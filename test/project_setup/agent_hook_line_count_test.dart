import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late String scriptPath;

  setUp(() {
    root = Directory.systemTemp.createTempSync('agent_hook_line_count_test_');
    scriptPath =
        '${Directory.current.path}/tool/agent_hooks/check_source_file_line_count.dart';
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('warns for Claude file path over 300 lines', () async {
    _writeLines(root, 'lib/long_file.dart', 301);

    final result = await _runHook(scriptPath, {
      'hook_event_name': 'PostToolUse',
      'cwd': root.path,
      'tool_input': {'file_path': 'lib/long_file.dart'},
    });

    expect(result.exitCode, 0);
    final output = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(output['systemMessage'], contains('lib/long_file.dart'));
    expect(output['systemMessage'], contains('301 lines'));
  });

  test('does not warn for short, generated, or non-source files', () async {
    _writeLines(root, 'lib/short_file.dart', 300);
    _writeLines(root, 'lib/generated_file.g.dart', 400);
    _writeLines(root, 'README.md', 400);

    for (final path in [
      'lib/short_file.dart',
      'lib/generated_file.g.dart',
      'README.md',
    ]) {
      final result = await _runHook(scriptPath, {
        'cwd': root.path,
        'tool_input': {'file_path': path},
      });
      expect(result.exitCode, 0);
      expect(result.stdout, isEmpty);
    }
  });

  test('warns for Codex apply_patch touched source path', () async {
    _writeLines(root, 'tool/long_tool.dart', 302);

    final result = await _runHook(scriptPath, {
      'cwd': root.path,
      'tool_input': {
        'command': '''
*** Begin Patch
*** Update File: tool/long_tool.dart
@@
 void main() {}
*** End Patch
''',
      },
    });

    expect(result.exitCode, 0);
    expect(result.stdout, contains('tool/long_tool.dart'));
    expect(result.stdout, contains('302 lines'));
  });
}

Future<ProcessResult> _runHook(
  String scriptPath,
  Map<String, dynamic> payload,
) async {
  final process = await Process.start('dart', [scriptPath]);
  process.stdin.write(jsonEncode(payload));
  await process.stdin.close();
  final stdoutText = await process.stdout.transform(utf8.decoder).join();
  final stderrText = await process.stderr.transform(utf8.decoder).join();
  final exitCode = await process.exitCode;
  return ProcessResult(0, exitCode, stdoutText, stderrText);
}

void _writeLines(Directory root, String path, int lines) {
  final file = File('${root.path}/$path');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(List.filled(lines, 'void f() {}').join('\n'));
}
