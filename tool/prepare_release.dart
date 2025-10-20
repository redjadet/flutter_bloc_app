import 'dart:io';

/// Scrubs sensitive secrets before packaging release builds.
///
/// Usage:
///   dart run tool/prepare_release.dart
///
/// The script replaces `assets/config/secrets.json` with the sanitized contents
/// of `assets/config/secrets.sample.json`, or a minimal placeholder if the
/// sample is unavailable. Run this right before `flutter build` for release
/// flavors to guarantee that no live credentials are bundled.
void main(final List<String> args) {
  final File secretsFile = File('assets/config/secrets.json');
  final File sampleFile = File('assets/config/secrets.sample.json');

  if (!secretsFile.existsSync()) {
    stdout.writeln(
      'prepare_release: secrets.json not found; nothing to scrub.',
    );
    return;
  }

  String sanitized;
  if (sampleFile.existsSync()) {
    sanitized = sampleFile.readAsStringSync();
  } else {
    sanitized =
        '{\n'
        '  "HUGGINGFACE_API_KEY": "",\n'
        '  "HUGGINGFACE_MODEL": "",\n'
        '  "HUGGINGFACE_USE_CHAT_COMPLETIONS": false\n'
        '}\n';
  }

  secretsFile.writeAsStringSync(sanitized);
  stdout.writeln(
    'prepare_release: Scrubbed assets/config/secrets.json with placeholder values.',
  );
}
