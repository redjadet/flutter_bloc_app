# Custom Lint Rules Guide for BLoC/Cubit

This guide explains how to create custom lint rules for BLoC/Cubit patterns to achieve compile-time validation similar to Riverpod's analyzer integration.

## Overview

Custom lint rules can provide compile-time validation for:

- State transition validation
- Lifecycle guard checking
- Event handler exhaustiveness
- Type-safe access enforcement

## Prerequisites

Creating custom lint rules requires:

- Dart analyzer plugin development
- Understanding of AST (Abstract Syntax Tree) analysis
- Knowledge of analyzer APIs

## Current Implementation

This codebase already has a custom lint plugin example: `custom_lints/file_length_lint`

You can use this as a reference for creating BLoC-specific lint rules.

## Creating a BLoC Lint Rule

### Step 1: Create the Lint Plugin Package

```bash
mkdir custom_lints/bloc_lint
cd custom_lints/bloc_lint
dart create --template=package .
```

### Step 2: Add Dependencies

In `custom_lints/bloc_lint/pubspec.yaml`:

```yaml
dependencies:
  analyzer: ^6.0.0
  analyzer_plugin: ^0.11.0
  meta: ^1.11.0
```

### Step 3: Create Lint Rule

Create `lib/src/bloc_lifecycle_guard_lint.dart`:

```dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that checks for missing `isClosed` guards before `emit()` in async methods.
class BlocLifecycleGuardLint extends DartLintRule {
  const BlocLifecycleGuardLint() : super(code: _code);

  static const _code = LintCode(
    name: 'bloc_lifecycle_guard',
    problemMessage: 'Missing isClosed check before emit() in async method',
    correctionMessage: 'Add "if (isClosed) return;" before emit()',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      // Check if method is async and in a Cubit/Bloc class
      if (node.isAsynchronous && _isInBlocClass(node)) {
        // Check for emit() calls without isClosed guard
        node.visitChildren(_EmitVisitor(reporter, node));
      }
    });
  }

  bool _isInBlocClass(MethodDeclaration node) {
    final parent = node.parent;
    if (parent is ClassDeclaration) {
      final className = parent.name.lexeme;
      return className.endsWith('Cubit') || className.endsWith('Bloc');
    }
    return false;
  }
}

class _EmitVisitor extends RecursiveAstVisitor<void> {
  _EmitVisitor(this.reporter, this.method);

  final ErrorReporter reporter;
  final MethodDeclaration method;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'emit' && _isInAsyncContext(node)) {
      if (!_hasIsClosedGuard(node)) {
        reporter.atNode(
          node,
          BlocLifecycleGuardLint._code,
        );
      }
    }
    super.visitMethodInvocation(node);
  }

  bool _isInAsyncContext(AstNode node) {
    // Check if node is within an async method
    AstNode? current = node;
    while (current != null) {
      if (current is MethodDeclaration && current.isAsynchronous) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }

  bool _hasIsClosedGuard(AstNode node) {
    // Check if there's an isClosed check before this node
    // This is simplified - actual implementation would need more sophisticated AST traversal
    final parent = node.parent;
    if (parent is IfStatement) {
      final condition = parent.condition;
      if (condition.toString().contains('isClosed')) {
        return true;
      }
    }
    return false;
  }
}
```

### Step 4: Register the Plugin

Create `lib/bloc_lint_plugin.dart`:

```dart
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/plugin/plugin_capabilities.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:custom_lints/bloc_lint/src/bloc_lifecycle_guard_lint.dart';

class BlocLintPlugin extends ServerPlugin {
  BlocLintPlugin(super.resourceProvider);

  @override
  List<LintRule> getLintRules() => [
    const BlocLifecycleGuardLint(),
    // Add more lint rules here
  ];
}
```

### Step 5: Configure in analysis_options.yaml

```yaml
plugins:
  bloc_lint:
    path: custom_lints/bloc_lint
    diagnostics:
      bloc_lifecycle_guard: error
```

## Example Lint Rules

### 1. Lifecycle Guard Check

**Rule:** `bloc_lifecycle_guard`

**Checks:** Missing `isClosed` checks before `emit()` in async methods

**Example Violation:**

```dart
Future<void> loadData() async {
  final data = await repository.fetch();
  emit(state.copyWith(data: data)); // ❌ Missing isClosed check
}
```

**Correct Pattern:**

```dart
Future<void> loadData() async {
  final data = await repository.fetch();
  if (isClosed) return; // ✅ Guard present
  emit(state.copyWith(data: data));
}
```

### 2. Type-Safe Access Enforcement

**Rule:** `bloc_use_type_safe_access`

**Checks:** Use of `context.read<T>()` instead of `context.cubit<T>()`

**Example Violation:**

```dart
final cubit = context.read<CounterCubit>(); // ❌ Should use context.cubit
```

**Correct Pattern:**

```dart
final cubit = context.cubit<CounterCubit>(); // ✅ Type-safe access
```

### 3. State Transition Validation

**Rule:** `bloc_emit_only_valid_states`

**Checks:** States are only emitted if transition is valid (requires state machine definition)

**Implementation:** Requires code generation or annotation-based state machine definitions

## Integration with Existing Validation Scripts

You can integrate custom lint rules with existing validation scripts:

```bash
# tool/check_bloc_lifecycle_guards.sh
#!/bin/bash
# Run custom BLoC lint rules
flutter analyze --no-fatal-infos | grep -E "bloc_lifecycle_guard|bloc_use_type_safe_access"
```

## Limitations

Custom lint rules have some limitations:

1. **AST Analysis Only** - Can't analyze runtime behavior
2. **No Type Information** - Limited access to full type information
3. **Performance** - Complex rules can slow down analysis
4. **Maintenance** - Requires ongoing maintenance as Dart evolves

## Alternative: Runtime Validation

For many use cases, runtime validation (like `StateTransitionValidator`) is more practical:

- ✅ Easier to implement
- ✅ No analyzer plugin complexity
- ✅ Works with existing tooling
- ⚠️ Catches issues at runtime, not compile-time

## Best Practices

1. **Start Simple** - Begin with simple rules before complex ones
2. **Test Thoroughly** - Test lint rules with various code patterns
3. **Document Rules** - Clearly document what each rule checks
4. **Provide Fixes** - Include quick fixes when possible
5. **Performance** - Keep rules efficient to avoid slowing analysis

## Related Documentation

- [Code Generation Guide](code_generation_guide.md) - Alternative approach using code generation
- [State Transition Validator](../lib/shared/utils/state_transition_validator.dart) - Runtime validation approach
- [Validation Scripts](validation_scripts.md) - Existing validation patterns
