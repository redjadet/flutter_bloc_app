import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_helpers.dart';

class MemoryStreamControllerMissingCloseRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'memory_stream_controller_missing_close',
    'StreamController "{0}" must be closed in dispose() or close().',
    correctionMessage:
        'Call {0}.close() (or {0}?.close()) inside dispose() or close().',
  );

  MemoryStreamControllerMissingCloseRule()
    : super(
        name: 'memory_stream_controller_missing_close',
        description:
            'Flags StreamController fields that are not closed in dispose() '
            'or close().',
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
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final List<MethodDeclaration> teardown = <MethodDeclaration>[];
    for (final ClassMember member in node.members) {
      if (member is MethodDeclaration &&
          !member.isStatic &&
          (member.name.lexeme == 'dispose' || member.name.lexeme == 'close')) {
        teardown.add(member);
      }
    }

    for (final ClassMember member in node.members) {
      if (member is! FieldDeclaration || member.isStatic) {
        continue;
      }
      final String? typeName = declaredBaseTypeName(member.fields.type);
      if (typeName != 'StreamController') {
        continue;
      }
      for (final VariableDeclaration variable in member.fields.variables) {
        final String fieldName = variable.name.lexeme;
        final bool closed = teardown.any(
          (MethodDeclaration method) => methodClosesField(method, fieldName),
        );
        if (!closed) {
          rule.reportAtNode(variable, arguments: <Object>[fieldName]);
        }
      }
    }
  }
}
