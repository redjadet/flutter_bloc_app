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

const List<String> _excludedPatterns = <String>[
  // Mock repositories (test utilities)
  'mock_',
  '_mock',
  // Performance profiler (debug utilities)
  'performance_profiler',
  // Platform-specific widgets that are hard to test
  'map_sample_map_view.dart',
  // Part files (tested via parent file)
  '_sections.dart',
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
  _Updator.updateReadme(
    coverage.totalPercentage,
    totalLinesHit: coverage.totalLinesHit,
    totalLinesFound: coverage.totalLinesFound,
  );
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
        "Files that don't require tests are also excluded:",
      )
      ..writeln(
        '- Mock repositories (test utilities themselves)',
      )
      ..writeln(
        '- Simple data classes (Freezed classes, simple Equatable classes)',
      )
      ..writeln(
        '- Configuration files (files with only constants)',
      )
      ..writeln(
        '- Debug utilities (performance profiler files)',
      )
      ..writeln(
        '- Platform-specific widgets (map widgets requiring native testing)',
      )
      ..writeln(
        '- Part files (tested via parent file)',
      )
      ..writeln(
        '- Files with `// coverage:ignore-file` comment',
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
    // Check exclusion patterns (mock repositories, debug utilities, etc.)
    for (final String pattern in _excludedPatterns) {
      if (path.contains(pattern)) {
        return false;
      }
    }
    if (_hasCoverageIgnoreFile(path)) {
      return false;
    }
    if (_isTrivialDartFile(path)) {
      return false;
    }
    if (_isSimpleDataClass(path)) {
      return false;
    }
    if (_isConfigurationFile(path)) {
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

  /// Checks if a file is a simple data class that doesn't require tests.
  ///
  /// Simple data classes are:
  /// - Freezed classes (only data, no logic)
  /// - Simple Equatable classes with only properties and props getter
  /// - Files with very few lines (< 10) that are just data containers
  static bool _isSimpleDataClass(final String path) {
    if (!path.endsWith('.dart')) {
      return false;
    }
    final File file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    final List<String> lines = file.readAsLinesSync();
    final String content = lines.join('\n');

    // Check for freezed classes (data classes)
    if (content.contains('@freezed') && content.contains('part ')) {
      // Freezed classes are just data containers, tested indirectly
      return true;
    }

    // Check for Equatable classes (simple data containers)
    if (content.contains('extends Equatable')) {
      // Count lines that indicate actual logic (methods, complex getters, etc.)
      int logicLines = 0;
      bool inConstructor = false;
      for (final String line in lines) {
        final String trimmed = line.trim();
        if (trimmed.isEmpty ||
            trimmed.startsWith('//') ||
            trimmed.startsWith('import ') ||
            trimmed.startsWith('export ') ||
            trimmed.startsWith('part ') ||
            trimmed.startsWith('library ') ||
            trimmed.startsWith('///')) {
          continue;
        }
        // Track constructor state
        if (trimmed.contains('const ') && trimmed.contains('(')) {
          inConstructor = true;
          continue;
        }
        if (inConstructor && trimmed == ');') {
          inConstructor = false;
          continue;
        }
        if (inConstructor) {
          continue; // Constructor parameters don't count as logic
        }
        // Check for actual methods (not just properties, props getter, or constructors)
        if (trimmed.contains('(') &&
            !trimmed.contains('const ') &&
            !trimmed.contains('final ') &&
            !trimmed.contains('@override') &&
            !trimmed.contains('List<Object?> get props') &&
            !trimmed.contains('required ')) {
          logicLines++;
        } else if (trimmed.contains('{') &&
            !trimmed.contains('const ') &&
            !trimmed.contains('final ') &&
            !trimmed.contains('@override') &&
            !trimmed.contains('List<Object?> get props')) {
          // Complex getters or methods with bodies
          logicLines++;
        }
      }
      // If it has no logic (just properties and props getter), it's a simple data class
      if (logicLines == 0) {
        return true;
      }
    }

    return false;
  }

  /// Checks if a file is a configuration file (only constants, no logic).
  ///
  /// Configuration files contain only static constants and don't require tests.
  static bool _isConfigurationFile(final String path) {
    if (!path.endsWith('.dart')) {
      return false;
    }
    final File file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    final List<String> lines = file.readAsLinesSync();
    final String content = lines.join('\n');

    // Check if file contains only static const declarations
    // and no methods, functions, or complex logic
    if (content.contains('static const') &&
        !content.contains('void ') &&
        !content.contains('Future<') &&
        !content.contains('=>')) {
      // Count non-trivial lines
      int nonTrivialLines = 0;
      for (final String line in lines) {
        final String trimmed = line.trim();
        if (trimmed.isEmpty ||
            trimmed.startsWith('//') ||
            trimmed.startsWith('import ') ||
            trimmed.startsWith('export ') ||
            trimmed.startsWith('part ') ||
            trimmed.startsWith('library ') ||
            trimmed.startsWith('///') ||
            trimmed == '{' ||
            trimmed == '}') {
          continue;
        }
        // Count lines that aren't just const declarations
        if (!trimmed.contains('static const') &&
            !trimmed.contains('class ') &&
            !trimmed.contains('const ')) {
          nonTrivialLines++;
        }
      }
      // If mostly constants, it's a config file
      if (nonTrivialLines <= 2) {
        return true;
      }
    }

    return false;
  }
}

class _Updator {
  static void updateReadme(
    final double percentage, {
    required final int totalLinesHit,
    required final int totalLinesFound,
  }) {
    final File readme = File('README.md');
    if (!readme.existsSync()) {
      return;
    }
    final List<String> lines = readme.readAsLinesSync();
    final String percentageStr = percentage.toStringAsFixed(2);
    final String percentageUrlEncoded = percentageStr.replaceAll('.', '%2E');
    final String lineCountStr = '($totalLinesHit/$totalLinesFound lines)';
    bool updated = false;

    // Pattern 1: Badge URL - [![Coverage](.../Coverage-85.34%25-...)](...)
    final RegExp badgePattern = RegExp(
      r'(\[!\[Coverage\]\([^)]+/Coverage-)([0-9]+\.?[0-9]*)%25([^)]+\))',
    );

    // Pattern 2: Text mentions - **85.34% Test Coverage** or **Current Coverage**: 85.34%
    final RegExp textPattern1 = RegExp(
      r'(\*\*)([0-9]+\.?[0-9]*)%(\s+Test Coverage\*\*)',
    );
    final RegExp textPattern2 = RegExp(
      r'(\*\*Current Coverage\*\*:\s+)([0-9]+\.?[0-9]*)%\s+\(([0-9]+/[0-9]+\s+lines)\)',
    );
    final RegExp textPattern3 = RegExp(
      r'(\*\*)([0-9]+\.?[0-9]*)%\s+\(([0-9]+/[0-9]+\s+lines)\)',
    );

    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      String? replacement;

      // Update badge URL
      if (badgePattern.hasMatch(line)) {
        replacement = line.replaceFirstMapped(
          badgePattern,
          (final match) =>
              '${match.group(1)}$percentageUrlEncoded%25${match.group(3)}',
        );
      }
      // Update "**85.34% Test Coverage**"
      else if (textPattern1.hasMatch(line)) {
        replacement = line.replaceFirstMapped(
          textPattern1,
          (final match) => '${match.group(1)}$percentageStr%${match.group(3)}',
        );
      }
      // Update "**Current Coverage**: 85.34% (6186/7249 lines)"
      else if (textPattern2.hasMatch(line)) {
        replacement = line.replaceFirstMapped(
          textPattern2,
          (final match) => '${match.group(1)}$percentageStr% $lineCountStr',
        );
      }
      // Update "**85.34% (6186/7249 lines)" - update both percentage and line counts
      else if (textPattern3.hasMatch(line)) {
        replacement = line.replaceFirstMapped(
          textPattern3,
          (final match) => '${match.group(1)}$percentageStr% $lineCountStr',
        );
      }

      if (replacement != null) {
        lines[i] = replacement;
        updated = true;
      }
    }

    if (updated) {
      readme.writeAsStringSync(_withSingleTrailingNewline(lines.join('\n')));
      stdout.writeln(
        'Updated README.md with coverage: $percentageStr% $lineCountStr',
      );
    } else {
      stderr.writeln(
        'Warning: Could not find coverage percentage patterns in README.md',
      );
    }
  }
}

String _withSingleTrailingNewline(final String value) {
  final String stripped = value.replaceFirst(RegExp(r'\n+$'), '');
  return '$stripped\n';
}
