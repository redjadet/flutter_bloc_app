import 'dart:io';

/// Scrubs sensitive secrets before packaging release builds.
///
/// Usage:
///   dart run tool/prepare_release.dart
///
/// By default, this script does **not** modify any files.
///
/// Opt-in scrubbing:
///   SCRUB_ASSET_SECRETS=true dart run tool/prepare_release.dart
///
/// When enabled, the script replaces `assets/config/secrets.json` with the
/// sanitized contents of `assets/config/secrets.sample.json`, or a minimal
/// placeholder if the sample is unavailable.
void main(final List<String> args) {
  final bool scrubEnabled =
      Platform.environment['SCRUB_ASSET_SECRETS']?.toLowerCase().trim() ==
      'true';
  if (!scrubEnabled) {
    stdout.writeln(
      'prepare_release: SCRUB_ASSET_SECRETS not enabled; leaving secrets.json untouched.',
    );
    return;
  }

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
