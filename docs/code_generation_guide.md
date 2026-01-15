# Code Generation Guide for BLoC/Cubit

This guide explains how to set up and use custom code generation for BLoC/Cubit patterns to achieve compile-time safety similar to Riverpod.

## Overview

Custom code generation can provide:

- Exhaustive switch statement generation for sealed classes
- State transition validator generation
- Type-safe cubit factory generation
- Event handler validation

## Current Implementation

This codebase includes a **script-based code generator** that is ready to use immediately, plus a **build_runner package structure** for full IDE integration.

### Quick Start: Script-Based Generator

**Location**: `tool/generate_sealed_switch.dart`

A practical script that generates exhaustive switch helpers for sealed state classes.

Usage:

```bash
dart run tool/generate_sealed_switch.dart lib/features/remote_config/presentation/cubit/remote_config_state.dart
```

This generates a `.switch_helper.dart` file with exhaustive pattern matching helpers.

#### Example: Generating Switch Helper for RemoteConfigState

##### Step 1: Run the generator

```bash
dart run tool/generate_sealed_switch.dart lib/features/remote_config/presentation/cubit/remote_config_state.dart
```

##### Step 2: Generated file

Creates `remote_config_state.switch_helper.dart`:

```dart
part of 'remote_config_cubit.dart';

// Generated exhaustive switch helper for RemoteConfigState
extension RemoteConfigStateSwitchHelper on RemoteConfigState {
  /// Exhaustive pattern matching helper
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function({
      required bool isAwesomeFeatureEnabled,
      required String testValue,
      String? dataSource,
      DateTime? lastSyncedAt,
    }) loaded,
    required T Function(String message) error,
  }) => switch (this) {
    RemoteConfigInitial() => initial(),
    RemoteConfigLoading() => loading(),
    RemoteConfigLoaded(
      :final isAwesomeFeatureEnabled,
      :final testValue,
      :final dataSource,
      :final lastSyncedAt,
    ) => loaded(
      isAwesomeFeatureEnabled: isAwesomeFeatureEnabled,
      testValue: testValue,
      dataSource: dataSource,
      lastSyncedAt: lastSyncedAt,
    ),
    RemoteConfigError(:final message) => error(message),
  };
}
```

**Note**: The generator automatically:

- Extracts concrete types from field declarations (not `dynamic`)
- Uses named parameters for functions with boolean parameters or when the constructor uses named parameters
- Uses positional parameters for single-parameter functions
- Satisfies lint rules (`avoid_positional_boolean_parameters`)

##### Step 3: Add part directive

Add to `remote_config_cubit.dart`:

```dart
part 'remote_config_state.dart';
part 'remote_config_state.switch_helper.dart';
```

##### Step 4: Use the generated helper

```dart
Widget buildStateWidget(RemoteConfigState state) {
  return state.when(
    initial: () => Text('Initial'),
    loading: () => CircularProgressIndicator(),
    loaded: (isEnabled, testValue, dataSource, lastSynced) => Text('Loaded: $testValue'),
    error: (message) => ErrorWidget(message),
  );
}
```

### Annotations

Location: `lib/shared/annotations/bloc_annotations.dart`

Annotations are available for future use with build_runner:

- `@GenerateSwitchHelper` - Generate exhaustive switch helpers
- `@GenerateStateValidator` - Generate state transition validators
- `@GenerateCubitFactory` - Generate type-safe cubit factories

## Full Build Runner Integration

For a more integrated approach with IDE support, you can use the full `build_runner` generator package.

### Prerequisites

Add the following dependencies to `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  source_gen: ^1.5.0
  freezed: ^3.2.3
  json_serializable: ^6.7.1
```

### Setup

1. Generator package (already created in `tool/bloc_codegen/`)

2. Add to main pubspec.yaml:

```yaml
dev_dependencies:
  bloc_codegen:
    path: tool/bloc_codegen
```

1. Create build.yaml in root:

```yaml
targets:
  $default:
    builders:
      bloc_codegen|sealed_state_switch_generator:
        enabled: true
        generate_for:
          - lib/**/*.dart
      bloc_codegen|state_validator_generator:
        enabled: true
        generate_for:
          - lib/**/*.dart
```

1. Use annotations:

```dart
import 'package:flutter_bloc_app/shared/annotations/bloc_annotations.dart';

@GenerateSwitchHelper()
sealed class RemoteConfigState extends Equatable {
  const RemoteConfigState();
}
```

1. Run generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Creating a Custom Generator

#### Step 1: Create Generator Class

Create `tool/bloc_codegen/lib/src/sealed_state_switch_generator.dart`:

```dart
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../../../../lib/shared/annotations/bloc_annotations.dart';

class SealedStateSwitchGenerator
    extends GeneratorForAnnotation<GenerateSwitchHelper> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Generate exhaustive switch helper
    // See tool/bloc_codegen/lib/src/sealed_state_switch_generator.dart
    // for full implementation
  }
}
```

#### Step 2: Register Builder

Create `tool/bloc_codegen/lib/builder.dart`:

```dart
import 'package:build/build.dart';
import 'package:source_gen/builder.dart';

import 'src/sealed_state_switch_generator.dart';
import 'src/state_validator_generator.dart';

Builder sealedStateSwitchBuilder(BuilderOptions options) =>
    SharedPartBuilder(
      [SealedStateSwitchGenerator()],
      'switch_helper',
    );

Builder stateValidatorBuilder(BuilderOptions options) =>
    SharedPartBuilder(
      [StateValidatorGenerator()],
      'validator',
    );
```

## Generating State Transition Validators

### Annotation

```dart
import 'package:flutter_bloc_app/shared/annotations/bloc_annotations.dart';

@GenerateStateValidator(
  transitions: [
    StateTransition(from: 'initial', to: 'loading'),
    StateTransition(from: 'loading', to: 'success'),
    StateTransition(from: 'loading', to: 'error'),
  ],
)
class CounterState { ... }
```

### Generated Code

```dart
class CounterStateTransitionValidator extends StateTransitionValidator<CounterState> {
  @override
  bool isValidTransition(CounterState from, CounterState to) {
    return switch ((from, to)) {
      (CounterStateInitial(), CounterStateLoading()) => true,
      (CounterStateLoading(), CounterStateSuccess()) => true,
      (CounterStateLoading(), CounterStateError()) => true,
      _ => false,
    };
  }
}
```

## Running Code Generation

### Script-Based (Current Implementation)

```bash
# Generate switch helper for a sealed state
dart run tool/generate_sealed_switch.dart lib/features/remote_config/presentation/cubit/remote_config_state.dart
```

### Build Runner (Future Implementation)

#### One-time Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Watch Mode (for development)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Integration with Existing Code

### 1. Generated Files

Generated files follow the pattern:

- `*.switch_helper.dart` - Exhaustive switch helpers
- `*.validator.dart` - State transition validators (future)
- `*.factory.dart` - Type-safe cubit factories (future)

### 2. Add Generated Files to .gitignore (Optional)

If you don't want to commit generated files:

```gitignore
# Generated files
*.g.dart
*.freezed.dart
*.bloc_gen.dart
*.switch_helper.dart
```

**Note**: The current implementation generates `.switch_helper.dart` files that are committed to version control for consistency.

### 3. Import Generated Code

```dart
// For script-generated files
part 'remote_config_state.dart';
part 'remote_config_state.switch_helper.dart';

// For build_runner generated files
import 'counter_state.dart';
import 'counter_state.bloc_gen.dart'; // Generated file
```

### 4. Use Generated Helpers

```dart
// Use generated when() method
final widget = state.when(
  initial: () => Text('Initial'),
  loading: () => CircularProgressIndicator(),
  loaded: (isEnabled, testValue, dataSource, lastSynced) => Text('Loaded: $testValue'),
  error: (message) => ErrorWidget(message),
);
```

## Best Practices

1. **Script-Based for Simplicity**: Use the script-based generator for quick wins and immediate results
2. **Build Runner for Integration**: Use build_runner for full IDE integration and automatic generation
3. **Use Annotations**: Make code generation opt-in via annotations
4. **Document Generated Code**: Add comments explaining what was generated
5. **Version Control**: Commit generated files or document why they're ignored
6. **Testing**: Test generators with various input patterns
7. **Type Refinement**: Generated code may use `dynamic` types - manually refine if needed for better type safety

## Limitations

The current script-based generator:

- Requires manual execution
- Type extraction may show `dynamic` for complex types (can be manually fixed)
- Simple parameter extraction (may need adjustment for complex constructors)
- Doesn't handle all edge cases automatically

**Note**: The generated code is functional even with `dynamic` types - the exhaustive switch works correctly. Types can be manually refined if needed.

For production use, consider:

- Full build_runner integration (see `tool/bloc_codegen/` for starter code)
- More sophisticated AST parsing using analyzer package
- IDE plugin integration

## Alternative: Runtime Helpers

For simpler use cases, consider using runtime helpers instead of code generation:

- `StateTransitionValidator` - Runtime state transition validation
- `SealedStateHelpers` - Runtime pattern matching helpers
- Type-safe extensions - Compile-time type checking without generation

See [Compile-Time Safety Guide](compile_time_safety.md) for runtime helper examples.

## Related Documentation

- [Compile-Time Safety Guide](compile_time_safety.md) - Using type-safe features and generated code
- [State Management Choice](state_management_choice.md) - Why BLoC/Cubit and compile-time safety
- [Sealed Classes Migration](sealed_classes_migration.md) - Sealed class patterns
- [Testing Overview](testing_overview.md) - Testing with generated code
- [Compile-Time Safety Guide](compile_time_safety.md) - Complete feature overview
