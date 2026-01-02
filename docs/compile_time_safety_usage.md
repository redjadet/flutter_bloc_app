# Compile-Time Safety Usage Guide

This document provides examples of how to use the compile-time safety features implemented for BLoC/Cubit in this codebase.

**Recent Updates**: `SearchState` has been converted to Freezed as a reference implementation. See [Equatable to Freezed Conversion Guide](equatable_to_freezed_conversion.md) for details.

## Type-Safe Cubit Access Extensions

### Basic Usage

```dart
import 'package:flutter_bloc_app/shared/shared.dart';

// Type-safe cubit access
final counterCubit = context.cubit<CounterCubit>();
counterCubit.increment();

// Type-safe state access
final state = context.state<CounterCubit, CounterState>();
final count = state.count;

// Watch cubit for rebuilds
final cubit = context.watchCubit<CounterCubit>();

// Watch state for rebuilds
final currentState = context.watchState<CounterCubit, CounterState>();

// Select specific state slice
final count = context.selectState<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
);
```

### Benefits

- **Compile-time type checking**: Type errors are caught at compile time
- **Clear error messages**: If a cubit is missing, you get a helpful error message with preserved stack traces
- **Better IDE support**: Full autocomplete and type inference
- **Precise error handling**: Only intercepts `ProviderNotFoundException`; other errors pass through unchanged

## Type-Safe Bloc Widgets

### TypeSafeBlocSelector

Use this when you only need to rebuild when a specific part of the state changes:

```dart
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

TypeSafeBlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('Count: $count'),
)
```

### TypeSafeBlocBuilder

Use this for building widgets based on the full state:

```dart
TypeSafeBlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) {
    return Column(
      children: [
        Text('Count: ${state.count}'),
        if (state.status == ViewStatus.loading)
          CircularProgressIndicator(),
      ],
    );
  },
)
```

### TypeSafeBlocConsumer

Use this when you need both side effects (listener) and UI updates (builder):

```dart
TypeSafeBlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Unknown error')),
      );
    }
  },
  builder: (context, state) => Text('Count: ${state.count}'),
)
```

## Type-Safe BlocProvider Helpers

### Basic Provider

```dart
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';

BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
  create: () => CounterCubit(
    repository: getIt<CounterRepository>(),
    timerService: getIt<TimerService>(),
  ),
  builder: (context, cubit) => CounterPage(cubit: cubit),
)
```

### Provider with Async Initialization

```dart
BlocProviderHelpers.withCubitAsyncInit<CounterCubit, CounterState>(
  create: () => CounterCubit(
    repository: getIt<CounterRepository>(),
    timerService: getIt<TimerService>(),
  ),
  init: (cubit) => cubit.loadInitial(),
  builder: (context, cubit) => CounterPage(cubit: cubit),
)
```

## Migration from Standard BLoC Widgets

### Before (Standard BLoC)

```dart
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)

BlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('$count'),
)

final cubit = context.read<CounterCubit>();
```

### After (Type-Safe)

```dart
TypeSafeBlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)

TypeSafeBlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('$count'),
)

final cubit = context.cubit<CounterCubit>();
```

## Compile-Time Safety Benefits

1. **Type Errors at Compile Time**: Wrong types are caught before runtime
2. **Better IDE Support**: Full autocomplete and type inference
3. **Clearer Error Messages**: Missing cubits throw helpful errors with preserved stack traces
4. **Refactoring Safety**: Type changes propagate automatically
5. **Documentation**: Types serve as inline documentation
6. **Precise Error Handling**: Only provider errors are intercepted; other errors pass through

## Best Practices

1. **Always use type-safe extensions** for cubit access
2. **Use TypeSafeBlocSelector** when you only need part of the state
3. **Use TypeSafeBlocBuilder** for full state access
4. **Use TypeSafeBlocConsumer** when you need side effects
5. **Prefer type-safe BlocProvider helpers** for provider creation

## State Transition Validation

Use state transition validators to catch invalid state changes:

```dart
import 'package:flutter_bloc_app/shared/utils/state_transition_validator.dart';

// Create a validator
class CounterStateValidator extends StateTransitionValidator<CounterState> {
  @override
  bool isValidTransition(CounterState from, CounterState to) {
    return switch ((from.status, to.status)) {
      (ViewStatus.initial, ViewStatus.loading) => true,
      (ViewStatus.loading, ViewStatus.success) => true,
      (ViewStatus.loading, ViewStatus.error) => true,
      _ => false,
    };
  }
}

// Use in cubit
class CounterCubit extends Cubit<CounterState>
    with StateTransitionValidation<CounterState> {
  CounterCubit() : super(CounterState.initial()) {
    _validator = CounterStateValidator();
  }

  void loadData() {
    validateAndEmit(state.copyWith(status: ViewStatus.loading));
  }
}
```

## Sealed State Helpers

For sealed state classes, use pattern matching:

```dart
import 'package:flutter_bloc_app/shared/utils/sealed_state_helpers.dart';

// Use Dart 3.0+ pattern matching (recommended)
Widget buildStateWidget(DeepLinkState state) {
  return switch (state) {
    DeepLinkIdle() => Text('Idle'),
    DeepLinkLoading() => CircularProgressIndicator(),
    DeepLinkNavigate(:final target, :final origin) => NavigateTo(target),
    DeepLinkError(:final message) => ErrorWidget(message),
  };
}
```

## Performance Notes

### `selectState` Optimization

The `selectState` method uses Flutter's `context.select` internally, which means:

- Widgets only rebuild when the selected value actually changes
- Other state changes don't trigger rebuilds
- This provides optimal performance for selective state access

**Example:**

```dart
// Only rebuilds when state.count changes, not when state.status changes
final count = context.selectState<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
);
```

## Related Documentation

- [Quick Reference Guide](compile_time_safety_quick_reference.md) - Quick lookup for type-safe patterns
- [Migration Guide](migration_to_type_safe_bloc.md) - Step-by-step migration instructions
- [Improvements Analysis](compile_time_safety_improvements_analysis.md) - Recent improvements and optimizations
- [Code Generation Guide](code_generation_guide.md) - Setting up custom code generators
- [Custom Lint Rules Guide](custom_lint_rules_guide.md) - Creating analyzer plugins
- [State Management Choice](state_management_choice.md) - Why BLoC/Cubit and compile-time safety
- [Architecture Details](architecture_details.md) - Overall architecture
- [Testing Overview](testing_overview.md) - Testing with type-safe BLoC
