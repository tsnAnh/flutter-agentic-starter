import 'dart:io';

import '../project_files.dart';
import '../setup_cli.dart';
import '../setup_runner.dart';

Future<void> main(List<String> arguments) async {
  final files = ProjectFiles(Directory.current);
  final currentPackageName = files.readPubspecName();
  final options = parseProjectSetupOptions(
    arguments,
    currentPackageName: currentPackageName,
  );

  if (options == null) {
    return;
  }

  final runner = ProjectSetupRunner(files: files);
  final exitCode = await runner.run(options);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
