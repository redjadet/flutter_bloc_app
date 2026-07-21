import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_helpers.dart';

class MemoryStaticBuildContextRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'memory_static_build_context',
    'Do not retain BuildContext in a static field.',
    correctionMessage:
        'Pass BuildContext as a method parameter or use a short-lived '
        'reference instead of a static field.',
  );

  MemoryStaticBuildContextRule()
    : super(
        name: 'memory_static_build_context',
        description:
            'Flags static fields typed as BuildContext or BuildContext?.',
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
    registry.addFieldDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.isStatic) {
      return;
    }
    final String? typeName = declaredBaseTypeName(node.fields.type);
    if (typeName != 'BuildContext') {
      return;
    }
    for (final VariableDeclaration variable in node.fields.variables) {
      rule.reportAtNode(variable);
    }
  }
}
