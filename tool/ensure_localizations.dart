#!/usr/bin/env dart
import 'dart:io';

/// Ensures localization files exist before build.
///
/// This script checks if app_localizations*.dart files exist in lib/l10n/,
/// and regenerates them if they're missing. This prevents build failures
/// when Flutter's build process cleans generated files.
///
/// Usage:
///   dart run tool/ensure_localizations.dart
void main(final List<String> args) async {
  final Directory l10nDir = Directory('lib/l10n');
  if (!l10nDir.existsSync()) {
    stderr.writeln('Error: lib/l10n directory does not exist');
    exit(1);
  }

  // Check if main localization file exists
  final File mainFile = File('lib/l10n/app_localizations.dart');
  final bool needsRegeneration = !mainFile.existsSync();

  if (needsRegeneration) {
    stdout.writeln('Localization files missing, regenerating...');
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

    stdout.writeln('Localization files regenerated successfully');
  } else {
    stdout.writeln('Localization files exist, skipping regeneration');
  }
}
