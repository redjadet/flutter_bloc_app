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

This codebase already has native analyzer plugin examples:

- `custom_lints/file_length_lint` (`analysis_server_plugin`, `file_too_long`)
- `custom_lints/mix_lint` (vendored Mix design-system lints)
- `custom_lints/memory_lint` (lifecycle rules; see [`performance/memory_lints.md`](performance/memory_lints.md))

Use `mix_lint` / `file_length_lint` / `memory_lint` as references when adding BLoC-specific rules.

## Creating a BLoC Lint Rule

### Step 1: Create the Lint Plugin Package

```bash
mkdir custom_lints/bloc_lint
cd custom_lints/bloc_lint
dart create --template=package .
```

### Step 2: Add Dependencies

In `custom_lints/bloc_lint/pubspec.yaml` (match repo pins — see root `pubspec.yaml` `dependency_overrides`):

```yaml
name: bloc_lint
publish_to: none

environment:
  sdk: ^3.12.0

dependencies:
  analysis_server_plugin: ^0.3.0
  analyzer: ^10.0.0

dev_dependencies:
  analyzer_testing: ^0.4.0
  test: ^1.25.0
```

Add a path dev_dependency in the root `pubspec.yaml` and register the plugin under `plugins:` in `analysis_options.yaml` (same pattern as `mix_lint` / `file_length_lint`).

### Step 3: Create Lint Rule

Use `AnalysisRule` from `package:analyzer/analysis_rule/analysis_rule.dart`. Minimal shape (see `custom_lints/file_length_lint/lib/src/file_too_long_rule.dart`):

```dart
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';

class BlocLifecycleGuardRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'bloc_lifecycle_guard',
    'Missing isClosed check before emit() in async method',
    correctionMessage: 'Add "if (isClosed) return;" before emit()',
  );

  BlocLifecycleGuardRule()
    : super(
        name: 'bloc_lifecycle_guard',
        description: 'Requires isClosed guard before emit in async Cubit/Bloc methods.',
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
    // Register AST visitors; report with context.reportAtNode(code, node, ...).
  }
}
```

### Step 4: Register the Plugin

Create `apps/mobile/lib/main.dart` (analysis server loads `apps/mobile/lib/main.dart` and expects `plugin`):

```dart
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/bloc_lifecycle_guard_rule.dart';

final plugin = BlocLintPlugin();

class BlocLintPlugin extends Plugin {
  @override
  String get name => 'bloc_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(BlocLifecycleGuardRule());
  }
}
```

### Step 5: Configure in analysis_options.yaml

```yaml
plugins:
  bloc_lint:
    diagnostics:
      bloc_lifecycle_guard: error

dev_dependencies:
  bloc_lint:
    path: custom_lints/bloc_lint
```

Run with `dart analyze lib` or `./tool/run_<plugin>_lint.sh` (grep machine output for your diagnostic id). Do **not** use `custom_lint` / `custom_lint_builder`; this repo uses native analyzer plugins only.

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
# tool/run_bloc_lint.sh (pattern mirrors run_mix_lint.sh / run_file_length_lint.sh)
dart analyze --format machine . | grep -E '\|bloc_lifecycle_guard\|' | grep '/lib/'
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
- [State Transition Validator](../apps/mobile/lib/app/utils/bloc/state_transition_validator.dart) - Runtime validation approach
- [Validation Scripts](validation_scripts.md) - Existing validation patterns
