#!/usr/bin/env dart

import 'dart:io';

/// Ensures localization files exist before build.
///
/// This script always regenerates app_localizations*.dart files in lib/l10n/
/// to prevent build failures when Flutter's build process cleans generated files.
///
/// **Why always regenerate?**
/// Flutter's build process (xcode_backend.sh) may clean generated files before
/// building, so we need to ensure localization files are always present before
/// the build starts. Since `flutter gen-l10n` is idempotent and fast, it's safe
/// to always regenerate.
///
/// Usage:
///   dart run tool/ensure_localizations.dart
void main(final List<String> args) async {
  final Directory l10nDir = Directory('lib/l10n');
  if (!l10nDir.existsSync()) {
    stderr.writeln('Error: lib/l10n directory does not exist');
    exit(1);
  }

  // Always regenerate localization files to ensure they exist before Flutter's
  // build process runs. This prevents issues when Flutter cleans generated files.
  stdout.writeln('Regenerating localization files...');
  final ProcessResult result = await Process.run(
    'flutter',
    ['gen-l10n'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    stderr
      ..writeln('Error regenerating localization files:')
      ..writeln(result.stderr);
    exit(1);
  }

  // Verify the main file was created
  final File mainFile = File('lib/l10n/app_localizations.dart');
  if (!mainFile.existsSync()) {
    stderr.writeln('Error: app_localizations.dart was not generated');
    exit(1);
  }

  stdout.writeln('Localization files regenerated successfully');
}
