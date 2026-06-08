import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'config.dart';

final FileLengthConfigResolver _configResolver = FileLengthConfigResolver();

class FileTooLongRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'file_too_long',
    'File has {0} lines (max allowed: {1}). Consider splitting it.',
    correctionMessage: 'Split the file into smaller pieces or extract helpers.',
  );

  FileTooLongRule()
    : super(
        name: 'file_too_long',
        description:
            'Flags Dart files that exceed the configured maximum line count.',
      );

  @override
  bool get canUseParsedResult => true;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(
      this,
      _FileTooLongVisitor(
        rule: this,
        resolver: _configResolver,
        context: context,
      ),
    );
  }
}

class _FileTooLongVisitor extends SimpleAstVisitor<void> {
  _FileTooLongVisitor({
    required this.rule,
    required this.resolver,
    required this.context,
  });

  final FileTooLongRule rule;
  final FileLengthConfigResolver resolver;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final RuleContextUnit? unitContext = context.currentUnit;
    if (unitContext == null) {
      return;
    }

    final File unitFile = unitContext.file;
    final String path = unitFile.path;

    final ResolvedFileLengthConfig resolved = resolver.resolveForUnitFile(
      unitFile,
    );
    final FileLengthConfig config = resolved.config;

    final String relativePath = makePathRelativeTo(
      absPath: normalizedPath(path),
      baseDir: resolved.optionsDirPath,
    );

    if (config.isExcluded(relativePath)) {
      return;
    }

    final int lineCount = node.lineInfo.lineCount;
    final int maxLines = config.maxLines;
    if (lineCount > maxLines) {
      rule.reportAtOffset(0, 0, arguments: <Object>[lineCount, maxLines]);
    }
  }
}
