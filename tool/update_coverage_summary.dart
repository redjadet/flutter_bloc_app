import 'dart:io';

const List<String> _generatedSuffixes = <String>[
  '.g.dart',
  '.freezed.dart',
  '.gr.dart',
  '.mocks.dart',
  '.pb.dart',
  '.pbenum.dart',
  '.pbjson.dart',
  '.pbgrpc.dart',
  '.pbserver.dart',
];

const List<String> _generatedPrefixes = <String>['lib/l10n/app_localizations_'];

const List<String> _excludedDirectories = <String>[
  'lib/l10n/',
  'lib/generated/',
];

const List<String> _generatedExact = <String>[
  'lib/generated_plugin_registrant.dart',
];

void main(final List<String> args) {
  final File lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln('coverage/lcov.info not found');
    exitCode = 2;
    return;
  }

  final _Coverage coverage = _Coverage.fromLines(lcov.readAsLinesSync());
  final File output = File('coverage/coverage_summary.md');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(coverage.toMarkdown());
  _Updator.updateReadme(coverage.totalPercentage);
  stdout.writeln(
    'Wrote coverage/coverage_summary.md with ${coverage.totalPercentage.toStringAsFixed(2)}% coverage',
  );
}

class _CoverageRecord {
  _CoverageRecord({
    required this.path,
    required this.linesHit,
    required this.linesFound,
  });

  final String path;
  final int linesHit;
  final int linesFound;

  double get percentage =>
      linesFound == 0 ? 100.0 : (linesHit / linesFound) * 100;
}

class _Coverage {
  factory _Coverage.fromLines(final List<String> lines) {
    String? currentFile;
    int linesFound = 0;
    int linesHit = 0;

    final Map<String, _CoverageRecord> perFile = <String, _CoverageRecord>{};

    void finishRecord() {
      if (currentFile == null) {
        return;
      }
      if (!_shouldInclude(currentFile!)) {
        currentFile = null;
        return;
      }
      final _CoverageRecord record = _CoverageRecord(
        path: currentFile!,
        linesHit: linesHit,
        linesFound: linesFound,
      );
      perFile[currentFile!] = record;
      currentFile = null;
      linesFound = 0;
      linesHit = 0;
    }

    for (final String raw in lines) {
      final String line = raw.trim();
      if (line.startsWith('SF:')) {
        finishRecord();
        final String filePath = line.substring(3);
        currentFile = _normalizePath(filePath);
      } else if (line.startsWith('LF:')) {
        linesFound = int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        linesHit = int.parse(line.substring(3));
      } else if (line == 'end_of_record') {
        finishRecord();
      }
    }
    finishRecord();

    final List<_CoverageRecord> filtered =
        perFile.values
            .where((final record) => record.path.startsWith('lib/'))
            .where((final record) => record.linesFound > 0)
            .toList()
          ..sort((final a, final b) => a.percentage.compareTo(b.percentage));

    final int totalFound = filtered.fold<int>(
      0,
      (final sum, final record) => sum + record.linesFound,
    );
    final int totalHit = filtered.fold<int>(
      0,
      (final sum, final record) => sum + record.linesHit,
    );

    return _Coverage._(filtered, totalHit, totalFound);
  }
  _Coverage._(this.records, this.totalLinesHit, this.totalLinesFound);

  final List<_CoverageRecord> records;
  final int totalLinesHit;
  final int totalLinesFound;

  double get totalPercentage =>
      totalLinesFound == 0 ? 0.0 : (totalLinesHit / totalLinesFound) * 100;

  String toMarkdown() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('# Test Coverage Summary')
      ..writeln()
      ..writeln(
        '*Total line coverage*: **${totalPercentage.toStringAsFixed(2)}%** '
        '($totalLinesHit/$totalLinesFound lines)',
      )
      ..writeln()
      ..writeln(
        'Generated and localization files (e.g. `.g.dart`, `.freezed.dart`, `lib/l10n/*`) '
        'are excluded from these totals.',
      )
      ..writeln()
      ..writeln(
        'Full per-file breakdown for `lib/`, sorted by ascending coverage percentage.',
      )
      ..writeln()
      ..writeln('| File | Coverage | Covered/Total |')
      ..writeln('| --- | ---: | ---: |');

    for (final _CoverageRecord record in records) {
      buffer
        ..write('| `')
        ..write(record.path)
        ..write('` | ')
        ..write(record.percentage.toStringAsFixed(2))
        ..write('% | ')
        ..write(record.linesHit)
        ..write('/')
        ..write(record.linesFound)
        ..writeln(' |');
    }

    return _withSingleTrailingNewline(buffer.toString());
  }

  static String _normalizePath(final String path) {
    final String normalized = path.replaceAll(r'\', '/');
    if (normalized.startsWith('${Directory.current.path}/')) {
      return normalized.substring(Directory.current.path.length + 1);
    }
    return normalized;
  }

  static bool _shouldInclude(final String path) {
    if (!path.startsWith('lib/')) {
      return false;
    }
    if (_generatedExact.contains(path)) {
      return false;
    }
    for (final String suffix in _generatedSuffixes) {
      if (path.endsWith(suffix)) {
        return false;
      }
    }
    for (final String directory in _excludedDirectories) {
      if (path.startsWith(directory)) {
        return false;
      }
    }
    for (final String prefix in _generatedPrefixes) {
      if (path.startsWith(prefix)) {
        return false;
      }
    }
    if (_hasCoverageIgnoreFile(path)) {
      return false;
    }
    if (_isTrivialDartFile(path)) {
      return false;
    }
    return true;
  }

  static bool _hasCoverageIgnoreFile(final String path) {
    if (!path.endsWith('.dart')) {
      return false;
    }
    final File file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    return file.readAsLinesSync().any(
      (final String line) => line.trim().startsWith('// coverage:ignore-file'),
    );
  }

  static bool _isTrivialDartFile(final String path) {
    if (!path.endsWith('.dart')) {
      return false;
    }
    final File file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    final List<String> lines = file.readAsLinesSync();
    bool inBlockComment = false;
    for (final String raw in lines) {
      final String line = raw.trim();
      if (line.isEmpty) {
        continue;
      }
      if (inBlockComment) {
        if (line.contains('*/')) {
          inBlockComment = false;
        }
        continue;
      }
      if (line.startsWith('/*')) {
        if (!line.contains('*/')) {
          inBlockComment = true;
        }
        continue;
      }
      if (line.startsWith('//') || line.startsWith('*')) {
        continue;
      }
      if (line.startsWith('import ') ||
          line.startsWith('export ') ||
          line.startsWith('library ') ||
          line.startsWith('part ')) {
        continue;
      }
      return false;
    }
    return true;
  }
}

class _Updator {
  static void updateReadme(final double percentage) {
    final File readme = File('README.md');
    if (!readme.existsSync()) {
      return;
    }
    final List<String> lines = readme.readAsLinesSync();
    final RegExp marker = RegExp(
      r'Latest line coverage: \*\*([0-9]+\.?[0-9]*)%\*\*',
    );
    bool updated = false;
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      final Match? match = marker.firstMatch(line);
      if (match != null) {
        final String replacement = line.replaceFirst(
          marker,
          'Latest line coverage: **${percentage.toStringAsFixed(2)}%**',
        );
        lines[i] = replacement;
        updated = true;
        break;
      }
    }
    if (updated) {
      readme.writeAsStringSync(_withSingleTrailingNewline(lines.join('\n')));
    }
  }
}

String _withSingleTrailingNewline(final String value) {
  final String stripped = value.replaceFirst(RegExp(r'\n+$'), '');
  return '$stripped\n';
}
