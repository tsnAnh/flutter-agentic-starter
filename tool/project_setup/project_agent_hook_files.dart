import 'dart:convert';
import 'dart:io';

class ProjectAgentHookFiles {
  const ProjectAgentHookFiles(this.root);

  final Directory root;

  void install() {
    _mergeJsonFile('.claude/settings.json', _claudeHookConfig);
    _mergeJsonFile('.codex/hooks.json', _codexHookConfig);
    _ensureGitignoreHookEntries();
  }

  void validateExistingJson() {
    for (final path in ['.claude/settings.json', '.codex/hooks.json']) {
      final file = _file(path);
      if (!file.existsSync()) continue;
      _readJson(file);
    }
  }

  void _mergeJsonFile(String path, Map<String, dynamic> generatedConfig) {
    final file = _file(path);
    final existing = file.existsSync() ? _readJson(file) : <String, dynamic>{};
    final merged = _mergeHooks(existing, generatedConfig);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(merged)}\n',
    );
  }

  Map<String, dynamic> _readJson(File file) {
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException catch (error) {
      throw FormatException('${file.path}: ${error.message}');
    }
    throw FormatException('${file.path}: expected top-level JSON object.');
  }

  Map<String, dynamic> _mergeHooks(
    Map<String, dynamic> existing,
    Map<String, dynamic> generated,
  ) {
    final merged = Map<String, dynamic>.from(existing);
    final existingHooks = _asObject(merged['hooks']);
    final generatedHooks = _asObject(generated['hooks']);

    for (final entry in generatedHooks.entries) {
      final currentGroups = _asList(existingHooks[entry.key]);
      final generatedGroups = _asList(entry.value);
      for (final group in generatedGroups) {
        if (!_containsJson(currentGroups, group)) {
          currentGroups.add(group);
        }
      }
      existingHooks[entry.key] = currentGroups;
    }

    merged['hooks'] = existingHooks;
    return merged;
  }

  Map<String, dynamic> _asObject(Object? value) {
    return value is Map<String, dynamic>
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  List<dynamic> _asList(Object? value) {
    return value is List ? List<dynamic>.from(value) : <dynamic>[];
  }

  bool _containsJson(List<dynamic> values, Object? value) {
    final encoded = jsonEncode(value);
    return values.any((existing) => jsonEncode(existing) == encoded);
  }

  void _ensureGitignoreHookEntries() {
    final gitignore = _file('.gitignore');
    final entries = ['!.claude/settings.json', '!.codex/', '!.codex/**'];
    if (!gitignore.existsSync()) {
      gitignore.writeAsStringSync('${entries.join('\n')}\n');
      return;
    }

    var content = gitignore.readAsStringSync();
    for (final entry in entries) {
      if (RegExp('(^|\\n)${RegExp.escape(entry)}(\\n|\$)').hasMatch(content)) {
        continue;
      }
      final separator = content.endsWith('\n') ? '' : '\n';
      content = '$content$separator$entry\n';
    }
    gitignore.writeAsStringSync(content);
  }

  File _file(String relativePath) => File('${root.path}/$relativePath');
}

const _hookCommand =
    'dart "\$(git rev-parse --show-toplevel)/tool/agent_hooks/check_source_file_line_count.dart"';

final _claudeHookConfig = {
  'hooks': {
    'PostToolUse': [
      {
        'matcher': 'Write|Edit|MultiEdit',
        'hooks': [
          {
            'type': 'command',
            'command':
                'dart "\$CLAUDE_PROJECT_DIR/tool/agent_hooks/check_source_file_line_count.dart"',
            'timeout': 30,
          },
        ],
      },
    ],
  },
};

final _codexHookConfig = {
  'hooks': {
    'PostToolUse': [
      {
        'matcher': 'apply_patch|Edit|Write',
        'hooks': [
          {
            'type': 'command',
            'command': _hookCommand,
            'timeout': 30,
            'statusMessage': 'Checking source file length',
          },
        ],
      },
    ],
  },
};
