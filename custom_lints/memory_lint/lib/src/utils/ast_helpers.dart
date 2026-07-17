import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Declared base type name from a field's [NamedType], if present.
String? declaredBaseTypeName(TypeAnnotation? type) {
  if (type is NamedType) {
    return type.name.lexeme;
  }
  return null;
}

/// True when [node] is a class that extends `State` (any type args).
bool classExtendsState(ClassDeclaration node) {
  final ExtendsClause? extendsClause = node.extendsClause;
  if (extendsClause == null) {
    return false;
  }
  final NamedType superclass = extendsClause.superclass;
  return superclass.name.lexeme == 'State';
}

/// True when [body] contains `<fieldName>.dispose()` or `<fieldName>?.dispose()`.
bool methodDisposesField(MethodDeclaration method, String fieldName) {
  return _methodInvokesOnField(method, fieldName, 'dispose');
}

/// True when [body] contains `<fieldName>.close()` or `<fieldName>?.close()`.
bool methodClosesField(MethodDeclaration method, String fieldName) {
  return _methodInvokesOnField(method, fieldName, 'close');
}

bool _methodInvokesOnField(
  MethodDeclaration method,
  String fieldName,
  String methodName,
) {
  final FunctionBody? body = method.body;
  if (body == null) {
    return false;
  }
  var found = false;
  body.accept(
    _FieldMethodInvocationFinder(
      fieldName: fieldName,
      methodName: methodName,
      onFound: () => found = true,
    ),
  );
  return found;
}

/// True when the class contains `addObserver(this)` somewhere.
bool classHasAddObserverThis(ClassDeclaration node) {
  return _classHasObserverCall(node, 'addObserver');
}

/// True when the class contains `removeObserver(this)` somewhere.
bool classHasRemoveObserverThis(ClassDeclaration node) {
  return _classHasObserverCall(node, 'removeObserver');
}

bool _classHasObserverCall(ClassDeclaration node, String methodName) {
  var found = false;
  node.accept(
    _ObserverThisFinder(methodName: methodName, onFound: () => found = true),
  );
  return found;
}

class _FieldMethodInvocationFinder extends RecursiveAstVisitor<void> {
  _FieldMethodInvocationFinder({
    required this.fieldName,
    required this.methodName,
    required this.onFound,
  });

  final String fieldName;
  final String methodName;
  final void Function() onFound;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == methodName) {
      final Expression? target = node.target;
      if (target is SimpleIdentifier && target.name == fieldName) {
        onFound();
        return;
      }
    }
    super.visitMethodInvocation(node);
  }
}

class _ObserverThisFinder extends RecursiveAstVisitor<void> {
  _ObserverThisFinder({required this.methodName, required this.onFound});

  final String methodName;
  final void Function() onFound;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == methodName) {
      final NodeList<Expression> args = node.argumentList.arguments;
      if (args.length == 1 && args.first is ThisExpression) {
        onFound();
        return;
      }
    }
    super.visitMethodInvocation(node);
  }
}
