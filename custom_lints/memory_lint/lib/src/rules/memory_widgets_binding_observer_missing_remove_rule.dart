import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_helpers.dart';

class MemoryWidgetsBindingObserverMissingRemoveRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'memory_widgets_binding_observer_missing_remove',
    'addObserver(this) requires a matching removeObserver(this).',
    correctionMessage:
        'Call removeObserver(this) in dispose() (or another teardown path).',
  );

  MemoryWidgetsBindingObserverMissingRemoveRule()
    : super(
        name: 'memory_widgets_binding_observer_missing_remove',
        description:
            'Flags classes that call addObserver(this) without '
            'removeObserver(this).',
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
    if (!classHasAddObserverThis(node)) {
      return;
    }
    if (classHasRemoveObserverThis(node)) {
      return;
    }

    // Report at the first addObserver(this) invocation.
    MethodInvocation? firstAdd;
    node.accept(
      _FirstAddObserverFinder((MethodInvocation node) {
        firstAdd ??= node;
      }),
    );
    if (firstAdd != null) {
      rule.reportAtNode(firstAdd);
    }
  }
}

class _FirstAddObserverFinder extends RecursiveAstVisitor<void> {
  _FirstAddObserverFinder(this.onFound);

  final void Function(MethodInvocation node) onFound;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'addObserver') {
      final NodeList<Expression> args = node.argumentList.arguments;
      if (args.length == 1 && args.first is ThisExpression) {
        onFound(node);
        return;
      }
    }
    super.visitMethodInvocation(node);
  }
}
