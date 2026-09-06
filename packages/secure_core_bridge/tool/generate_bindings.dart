import 'dart:io';

Future<void> main(List<String> arguments) async {
  final Directory packageRoot = File(Platform.script.toFilePath())
      .parent
      .parent;
  final File output = File(
    '${packageRoot.path}/lib/src/ffi/generated_bindings.dart',
  );
  final bool checkOnly = arguments.contains('--check');
  final List<int>? original = checkOnly && output.existsSync()
      ? output.readAsBytesSync()
      : null;
  final ProcessResult result = await Process.run('dart', <String>[
    'run',
    'ffigen',
    '--config',
    'ffigen.yaml',
  ], workingDirectory: packageRoot.path);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
  if (checkOnly && !_sameBytes(original, output.readAsBytesSync())) {
    stderr.writeln(
      'generated_bindings.dart was stale; regenerate and commit the result.',
    );
    exit(1);
  }
}

bool _sameBytes(List<int>? left, List<int> right) {
  if (left == null || left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
