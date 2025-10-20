import 'dart:async';

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _FileLengthLintPlugin();

class _FileLengthLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(final CustomLintConfigs configs) => <LintRule>[
    _FileLengthLint(options: configs.rules[_FileLengthLint._lintName]),
  ];
}

class _FileLengthLint extends DartLintRule {
  // ignore: prefer_const_constructors_in_immutables
  _FileLengthLint({required this.options}) : super(code: _lintCode);

  static const String _lintName = 'file_too_long';

  static const LintCode _lintCode = LintCode(
    name: _lintName,
    problemMessage: 'File exceeds the configured maximum number of lines.',
    correctionMessage: 'Split the file into smaller pieces or extract helpers.',
  );

  final LintOptions? options;

  @override
  Future<void> run(
    final CustomLintResolver resolver,
    final ErrorReporter reporter,
    final CustomLintContext context,
  ) async {
    final String? rawPath = _tryFilePath(resolver);
    if (rawPath == null) {
      return;
    }

    final String path = rawPath.replaceAll('\\', '/');

    if (_matchesAny(_excludedPatterns, path)) {
      return;
    }

    final Iterable<String>? extraExcludes = _readExcludePatterns();
    if (extraExcludes != null && _matchesAny(extraExcludes, path)) {
      return;
    }

    final int maxLines = _readMaxLines();
    final LineInfo lineInfo = resolver.lineInfo;
    final int lineCount = lineInfo.lineCount;

    if (lineCount <= maxLines) {
      return;
    }

    reporter.atOffset(
      errorCode: LintCode(
        name: _lintCode.name,
        problemMessage:
            'File has $lineCount lines (max allowed: $maxLines). Consider splitting it.',
        correctionMessage: _lintCode.correctionMessage,
      ),
      offset: 0,
      length: 0,
    );
  }

  int _readMaxLines() {
    final Object? raw = options?.json['max_lines'];
    final int? parsed = raw is int ? raw : int.tryParse('${raw ?? ''}');
    return parsed ?? 250;
  }

  Iterable<String>? _readExcludePatterns() {
    final Object? raw = options?.json['exclude'];
    if (raw is String) return <String>[raw];
    if (raw is Iterable) {
      return raw.whereType<String>();
    }
    return null;
  }

  bool _matchesAny(final Iterable<String> patterns, final String path) {
    for (final String pattern in patterns) {
      if (_Glob(pattern).matches(path)) {
        return true;
      }
    }
    return false;
  }

  String? _tryFilePath(final CustomLintResolver resolver) {
    try {
      return resolver.source.uri.toFilePath();
    } on Object catch (_) {
      return null;
    }
  }

  static final List<String> _excludedPatterns = <String>[
    '**/*.g.dart',
    '**/*.freezed.dart',
    '**/*.gen.dart',
    '**/*.gr.dart',
    '**/*.mocks.dart',
    '**/*.part.dart',
    'lib/l10n/**',
    '**/test/**',
    '**/tool/**',
  ];
}

/// Minimal glob matcher for our use case to avoid adding the `glob` package.
class _Glob {
  _Glob(final String pattern) : _regex = _createRegex(pattern);

  final RegExp _regex;

  bool matches(final String input) => _regex.hasMatch(input);

  static RegExp _createRegex(final String pattern) {
    final StringBuffer buffer = StringBuffer('^');
    for (int i = 0; i < pattern.length; i += 1) {
      final String char = pattern[i];
      switch (char) {
        case '*':
          if (i + 1 < pattern.length && pattern[i + 1] == '*') {
            buffer.write('.*');
            i += 1;
          } else {
            buffer.write('[^/]*');
          }
        case '.':
          buffer.write(r'\.');
        case '?':
          buffer.write('.');
        case r'\':
          buffer.write(r'\\');
        default:
          buffer.write(RegExp.escape(char));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }
}
