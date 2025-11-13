import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';

/// Lint rule that checks if a file exceeds the maximum allowed number of lines.
class FileLengthLintRule extends AnalysisRule {
  FileLengthLintRule()
    : super(
        name: 'file_too_long',
        description: 'File exceeds the configured maximum number of lines.',
      );

  static const int _defaultMaxLines = 250;

  static const List<String> _defaultExcludedPatterns = <String>[
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

  @override
  DiagnosticCode get diagnosticCode => _FileTooLongCode();

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _FileLengthVisitor(this, context));
  }
}

class _FileTooLongCode extends DiagnosticCode {
  _FileTooLongCode()
    : super(
        name: 'file_too_long',
        problemMessage: 'File exceeds the configured maximum number of lines.',
        uniqueName: 'file_too_long',
      );

  @override
  DiagnosticSeverity get severity => DiagnosticSeverity.INFO;

  @override
  DiagnosticType get type => DiagnosticType.LINT;

  @override
  String get correctionMessage =>
      'Split the file into smaller pieces or extract helpers.';
}

class _FileLengthVisitor extends RecursiveAstVisitor<void> {
  _FileLengthVisitor(this.rule, this.context);

  final FileLengthLintRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final RuleContextUnit? currentUnit = context.currentUnit;
    if (currentUnit == null) {
      return;
    }

    // Get file path from the current unit's file
    final String? filePath = _tryFilePath(currentUnit.file);
    if (filePath == null) {
      return;
    }

    final String path = filePath.replaceAll(r'\', '/');

    // Check default exclusions
    if (_matchesAny(FileLengthLintRule._defaultExcludedPatterns, path)) {
      return;
    }

    // Get line count from the unit's line info
    final int lineCount = currentUnit.unit.lineInfo.lineCount;
    const int maxLines = FileLengthLintRule._defaultMaxLines;

    if (lineCount > maxLines) {
      rule.reportAtOffset(
        0,
        0,
        arguments: [
          'File has $lineCount lines (max allowed: $maxLines). Consider splitting it.',
        ],
      );
    }
  }

  bool _matchesAny(final Iterable<String> patterns, final String path) {
    for (final String pattern in patterns) {
      if (_Glob(pattern).matches(path)) {
        return true;
      }
    }
    return false;
  }

  String? _tryFilePath(final File file) {
    try {
      return file.path;
    } on Object catch (_) {
      return null;
    }
  }
}

/// Minimal glob matcher for our use case to avoid adding the `glob` package.
class _Glob {
  _Glob(final String pattern) : _regex = _createRegex(pattern);

  final Pattern _regex;

  bool matches(final String input) => (_regex as RegExp).hasMatch(input);

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
