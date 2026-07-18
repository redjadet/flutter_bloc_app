import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_helpers.dart';

const Set<String> _controllerTypes = <String>{
  'TextEditingController',
  'AnimationController',
  'ScrollController',
  'PageController',
  'TabController',
  'FocusNode',
};

class MemoryStateControllerMissingDisposeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'memory_state_controller_missing_dispose',
    'State-owned controller "{0}" must be disposed in dispose().',
    correctionMessage:
        'Call {0}.dispose() (or {0}?.dispose()) inside dispose() before '
        'super.dispose().',
  );

  MemoryStateControllerMissingDisposeRule()
    : super(
        name: 'memory_state_controller_missing_dispose',
        description:
            'Flags State fields typed as Flutter controllers/FocusNode that '
            'are not disposed in dispose().',
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
    if (!classExtendsState(node)) {
      return;
    }

    MethodDeclaration? disposeMethod;
    for (final ClassMember member in node.members) {
      if (member is MethodDeclaration &&
          !member.isStatic &&
          member.name.lexeme == 'dispose') {
        disposeMethod = member;
        break;
      }
    }

    for (final ClassMember member in node.members) {
      if (member is! FieldDeclaration || member.isStatic) {
        continue;
      }
      final String? typeName = declaredBaseTypeName(member.fields.type);
      if (typeName == null || !_controllerTypes.contains(typeName)) {
        continue;
      }
      for (final VariableDeclaration variable in member.fields.variables) {
        final String fieldName = variable.name.lexeme;
        final bool disposed =
            disposeMethod != null &&
            methodDisposesField(disposeMethod, fieldName);
        if (!disposed) {
          rule.reportAtNode(variable, arguments: <Object>[fieldName]);
        }
      }
    }
  }
}
