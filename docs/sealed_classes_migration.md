# Sealed Classes Migration Guide

This guide provides detailed instructions for converting abstract state/event hierarchies to sealed classes for exhaustive pattern matching.

## Overview

Sealed classes (Dart 3.0+) provide:

- **Exhaustive pattern matching**: Compiler ensures all cases handled
- **Type safety**: Prevents missing state/event handling
- **Better refactoring**: Renaming updates all usages

## Prerequisites

1. Dart 3.0+ (already in use)
2. Test coverage for all state/event variants
3. Feature branch for changes

## Converting Abstract Classes to Sealed Classes

### Example: RemoteConfigState

#### Step 1: Current State (Abstract Class)

```dart
// lib/features/remote_config/presentation/cubit/remote_config_state.dart
part of 'remote_config_cubit.dart';

abstract class RemoteConfigState extends Equatable {
  const RemoteConfigState();

  @override
  List<Object?> get props => <Object?>[];
}

class RemoteConfigInitial extends RemoteConfigState {
  const RemoteConfigInitial();
}

class RemoteConfigLoading extends RemoteConfigState {
  const RemoteConfigLoading();
}

class RemoteConfigLoaded extends RemoteConfigState {
  const RemoteConfigLoaded({
    required this.isAwesomeFeatureEnabled,
    required this.testValue,
    this.dataSource,
    this.lastSyncedAt,
  });

  final bool isAwesomeFeatureEnabled;
  final String testValue;
  final String? dataSource;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => <Object?>[
    isAwesomeFeatureEnabled,
    testValue,
    dataSource,
    lastSyncedAt,
  ];
}

class RemoteConfigError extends RemoteConfigState {
  const RemoteConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
```

#### Step 2: Convert Events to Sealed Class

```dart
// lib/features/remote_config/presentation/cubit/remote_config_state.dart
part of 'remote_config_cubit.dart';

sealed class RemoteConfigState extends Equatable {
  const RemoteConfigState();

  @override
  List<Object?> get props => <Object?>[];
}

class RemoteConfigInitial extends RemoteConfigState {
  const RemoteConfigInitial();
}

class RemoteConfigLoading extends RemoteConfigState {
  const RemoteConfigLoading();
}

class RemoteConfigLoaded extends RemoteConfigState {
  const RemoteConfigLoaded({
    required this.isAwesomeFeatureEnabled,
    required this.testValue,
    this.dataSource,
    this.lastSyncedAt,
  });

  final bool isAwesomeFeatureEnabled;
  final String testValue;
  final String? dataSource;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => <Object?>[
    isAwesomeFeatureEnabled,
    testValue,
    dataSource,
    lastSyncedAt,
  ];
}

class RemoteConfigError extends RemoteConfigState {
  const RemoteConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
```

**Key Change**: `abstract class` → `sealed class`

#### Step 3: Update State Handling Code

Find all places where the state is handled:

```bash
grep -r "RemoteConfigState" lib/ test/
```

**Before (if-else chain):**

```dart
Widget buildStateWidget(RemoteConfigState state) {
  if (state is RemoteConfigInitial) {
    return Text('Initial');
  } else if (state is RemoteConfigLoading) {
    return CircularProgressIndicator();
  } else if (state is RemoteConfigLoaded) {
    return Text('Loaded: ${state.testValue}');
  } else if (state is RemoteConfigError) {
    return Text('Error: ${state.message}');
  }
  throw StateError('Unhandled state');
}
```

**After (exhaustive switch):**

```dart
Widget buildStateWidget(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigInitial() => Text('Initial'),
    RemoteConfigLoading() => CircularProgressIndicator(),
    RemoteConfigLoaded(:final testValue) => Text('Loaded: $testValue'),
    RemoteConfigError(:final message) => Text('Error: $message'),
  };
}
```

#### Step 4: Update BlocBuilder/BlocSelector

**Before:**

```dart
BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
  builder: (context, state) {
    if (state is RemoteConfigInitial) {
      return Text('Initial');
    } else if (state is RemoteConfigLoading) {
      return CircularProgressIndicator();
    } else if (state is RemoteConfigLoaded) {
      return Text('Loaded: ${state.testValue}');
    } else {
      return Text('Error: ${(state as RemoteConfigError).message}');
    }
  },
)
```

**After:**

```dart
BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
  builder: (context, state) => switch (state) {
    RemoteConfigInitial() => Text('Initial'),
    RemoteConfigLoading() => CircularProgressIndicator(),
    RemoteConfigLoaded(:final testValue) => Text('Loaded: $testValue'),
    RemoteConfigError(:final message) => Text('Error: $message'),
  },
)
```

#### Step 5: Update Tests

**Before:**

```dart
test('handles all states', () {
  final states = [
    RemoteConfigInitial(),
    RemoteConfigLoading(),
    RemoteConfigLoaded(...),
    RemoteConfigError('test'),
  ];

  for (final state in states) {
    if (state is RemoteConfigInitial) {
      expect(state, isA<RemoteConfigInitial>());
    } else if (state is RemoteConfigLoading) {
      expect(state, isA<RemoteConfigLoading>());
    }
    // ... etc
  }
});
```

**After (exhaustive):**

```dart
test('handles all states', () {
  final states = [
    RemoteConfigInitial(),
    RemoteConfigLoading(),
    RemoteConfigLoaded(...),
    RemoteConfigError('test'),
  ];

  for (final state in states) {
    final result = switch (state) {
      RemoteConfigInitial() => 'initial',
      RemoteConfigLoading() => 'loading',
      RemoteConfigLoaded() => 'loaded',
      RemoteConfigError() => 'error',
    };
    expect(result, isNotNull);
  }
});
```

## Converting Event Classes to Sealed Classes

### Example: CounterEvent

#### Step 1: Current Events (Abstract Class)

```dart
abstract class CounterEvent extends Equatable {
  const CounterEvent();
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent();
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent();
}

class ResetEvent extends CounterEvent {
  const ResetEvent();
}
```

#### Step 2: Convert to Sealed Class

```dart
sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent();
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent();
}

class ResetEvent extends CounterEvent {
  const ResetEvent();
}
```

#### Step 3: Update Event Handlers

The compiler will ensure all events are handled:

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState.initial()) {
    on<IncrementEvent>(_onIncrement);
    on<DecrementEvent>(_onDecrement);
    on<ResetEvent>(_onReset);
    // Compiler error if any event is missing!
  }

  void _onIncrement(IncrementEvent event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onDecrement(DecrementEvent event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count - 1));
  }

  void _onReset(ResetEvent event, Emitter<CounterState> emit) {
    emit(CounterState.initial());
  }
}
```

## Pattern Matching Examples

### Pattern 1: Simple State Matching

```dart
String getStateDescription(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigInitial() => 'Not loaded',
    RemoteConfigLoading() => 'Loading...',
    RemoteConfigLoaded() => 'Loaded',
    RemoteConfigError() => 'Error',
  };
}
```

### Pattern 2: Extracting Values

```dart
Widget buildStateWidget(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigInitial() => Text('Initial'),
    RemoteConfigLoading() => CircularProgressIndicator(),
    RemoteConfigLoaded(
      :final isAwesomeFeatureEnabled,
      :final testValue,
    ) => Column(
      children: [
        Text('Feature: $isAwesomeFeatureEnabled'),
        Text('Value: $testValue'),
      ],
    ),
    RemoteConfigError(:final message) => ErrorWidget(message),
  };
}
```

### Pattern 3: Conditional Logic

```dart
bool canPerformAction(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigLoaded() => true,
    RemoteConfigInitial() => false,
    RemoteConfigLoading() => false,
    RemoteConfigError() => false,
  };
}
```

## Benefits of Sealed Classes

### 1. Compile-Time Exhaustiveness

The compiler ensures all cases are handled:

```dart
// ❌ Compiler error: Missing case
String getState(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigInitial() => 'initial',
    RemoteConfigLoading() => 'loading',
    // Missing RemoteConfigLoaded and RemoteConfigError!
  };
}

// ✅ All cases handled
String getState(RemoteConfigState state) {
  return switch (state) {
    RemoteConfigInitial() => 'initial',
    RemoteConfigLoading() => 'loading',
    RemoteConfigLoaded() => 'loaded',
    RemoteConfigError() => 'error',
  };
}
```

### 2. Better Refactoring

Adding a new state variant causes compile errors everywhere it's not handled:

```dart
// Add new state
class RemoteConfigRefreshing extends RemoteConfigState {
  const RemoteConfigRefreshing();
}

// Compiler errors in all switch statements until handled
```

### 3. Type Safety

No need for type casts or `is` checks:

```dart
// Before (unsafe)
if (state is RemoteConfigLoaded) {
  final loaded = state as RemoteConfigLoaded; // Unsafe cast
  print(loaded.testValue);
}

// After (type-safe)
switch (state) {
  case RemoteConfigLoaded(:final testValue):
    print(testValue); // Type-safe, no cast needed
  // ...
}
```

## Migration Checklist

- [ ] Create feature branch
- [ ] Change `abstract class` to `sealed class`
- [ ] Find all state/event handling code
- [ ] Convert if-else chains to switch expressions
- [ ] Update tests to use exhaustive matching
- [ ] Run all tests
- [ ] Run analyzer (should catch missing cases)
- [ ] Test in app
- [ ] Code review
- [ ] Merge to main

## Common Pitfalls

### Pitfall 1: Forgetting to Update All Switch Statements

**Solution**: Use `grep` to find all usages:

```bash
grep -r "switch.*State" lib/ test/
```

### Pitfall 2: Using `default` Case

**Problem**: `default` defeats exhaustiveness checking

```dart
// ❌ Bad - default hides missing cases
switch (state) {
  case RemoteConfigInitial():
    return Text('Initial');
  default:
    return Text('Other');
}
```

**Solution**: Handle all cases explicitly:

```dart
// ✅ Good - exhaustive
switch (state) {
  case RemoteConfigInitial():
    return Text('Initial');
  case RemoteConfigLoading():
    return CircularProgressIndicator();
  case RemoteConfigLoaded():
    return Text('Loaded');
  case RemoteConfigError():
    return Text('Error');
}
```

### Pitfall 3: Mixing Sealed and Non-Sealed Classes

**Problem**: If a variant is not sealed, exhaustiveness breaks

```dart
sealed class BaseState {}
class Variant1 extends BaseState {}
class Variant2 extends BaseState {}
class Variant3 extends BaseState {} // Not in same file - breaks sealing
```

**Solution**: All variants must be in the same library (file or part files)

## Related Documentation

- [Remaining Tasks Plan](remaining_tasks_plan.md) - Overall implementation plan
- [Dart Sealed Classes](https://dart.dev/language/class-modifiers#sealed) - Official Dart docs
- [State Management Choice](state_management_choice.md) - Why sealed classes were chosen
