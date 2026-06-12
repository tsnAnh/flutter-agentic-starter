import 'dart:convert';
import 'dart:io';

const _lineLimit = 300;

Future<void> main() async {
  final input = await stdin.transform(utf8.decoder).join();
  final payload = _decodeJson(input);
  if (payload == null) return;

  final cwd = payload['cwd'] as String? ?? Directory.current.path;
  final paths = _changedPaths(payload);
  final warnings = <_LineWarning>[];

  for (final path in paths) {
    final file = _resolveFile(cwd, path);
    if (!_isSourcePath(file.path) || !file.existsSync()) continue;
    final content = file.readAsStringSync();
    if (_isGeneratedContent(content)) continue;
    final lines = _lineCount(content);
    if (lines > _lineLimit) {
      warnings.add(_LineWarning(_relativePath(cwd, file.path), lines));
    }
  }

  if (warnings.isEmpty) return;

  final message = _warningMessage(warnings);
  stdout.write(
    jsonEncode({
      'systemMessage': message,
      'hookSpecificOutput': {
        'hookEventName': payload['hook_event_name'] ?? 'PostToolUse',
        'additionalContext': message,
      },
    }),
  );
}

Map<String, dynamic>? _decodeJson(String input) {
  if (input.trim().isEmpty) return null;
  final decoded = jsonDecode(input);
  return decoded is Map<String, dynamic> ? decoded : null;
}

Set<String> _changedPaths(Map<String, dynamic> payload) {
  final paths = <String>{};
  final toolInput = payload['tool_input'];
  if (toolInput is Map<String, dynamic>) {
    for (final key in ['file_path', 'path', 'filePath']) {
      final value = toolInput[key];
      if (value is String && value.trim().isNotEmpty) {
        paths.add(value.trim());
      }
    }
    final command = toolInput['command'];
    if (command is String) {
      paths.addAll(_pathsFromPatch(command));
    }
  }
  return paths;
}

Iterable<String> _pathsFromPatch(String patch) sync* {
  final fileHeader = RegExp(r'^\*\*\* (?:Add|Update) File: (.+)$');
  for (final line in patch.split('\n')) {
    final match = fileHeader.firstMatch(line.trimRight());
    if (match != null) yield match.group(1)!.trim();
  }
}

File _resolveFile(String cwd, String path) {
  final file = File(path);
  if (file.isAbsolute) return file;
  return File('$cwd${Platform.pathSeparator}$path');
}

bool _isSourcePath(String path) {
  final normalized = path.replaceAll(r'\', '/');
  final segments = normalized.split('/');
  if (segments.any(_isSkippedSegment)) return false;
  final name = segments.isEmpty ? normalized : segments.last;
  if (_isGeneratedName(name)) return false;
  return _sourceExtensions.any(normalized.endsWith);
}

bool _isSkippedSegment(String segment) {
  return {
    '.dart_tool',
    '.git',
    '.idea',
    '.pub',
    '.pub-cache',
    'build',
    'Pods',
    'node_modules',
  }.contains(segment);
}

bool _isGeneratedName(String name) {
  return name.endsWith('.g.dart') ||
      name.endsWith('.freezed.dart') ||
      name.endsWith('.config.dart') ||
      name.endsWith('.gen.dart');
}

bool _isGeneratedContent(String content) {
  final firstChunk = content.split('\n').take(20).join('\n');
  return firstChunk.contains('GENERATED CODE - DO NOT MODIFY BY HAND');
}

int _lineCount(String content) {
  if (content.isEmpty) return 0;
  final newlines = '\n'.allMatches(content).length;
  return content.endsWith('\n') ? newlines : newlines + 1;
}

String _relativePath(String cwd, String path) {
  final normalizedCwd = Directory(cwd).absolute.path;
  final normalizedPath = File(path).absolute.path;
  final prefix = '$normalizedCwd${Platform.pathSeparator}';
  return normalizedPath.startsWith(prefix)
      ? normalizedPath.substring(prefix.length)
      : normalizedPath;
}

String _warningMessage(List<_LineWarning> warnings) {
  final files = warnings
      .map((warning) => '${warning.path} (${warning.lines} lines)')
      .join(', ');
  return 'Source file length guidance: $files exceed $_lineLimit lines. '
      'Consider splitting focused concerns when it improves readability.';
}

const _sourceExtensions = [
  '.dart',
  '.swift',
  '.kt',
  '.kts',
  '.java',
  '.m',
  '.mm',
  '.h',
  '.hpp',
  '.c',
  '.cc',
  '.cpp',
  '.cs',
  '.go',
  '.rs',
  '.py',
  '.rb',
  '.php',
  '.js',
  '.jsx',
  '.ts',
  '.tsx',
];

class _LineWarning {
  const _LineWarning(this.path, this.lines);

  final String path;
  final int lines;
}
