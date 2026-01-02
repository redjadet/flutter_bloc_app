# Compile-Time Safety Quick Reference

Quick reference guide for using type-safe BLoC/Cubit features in this codebase.

## Import

```dart
import 'package:flutter_bloc_app/shared/shared.dart';
// Or import specific files:
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
```

## Context Extensions

### Get Cubit

```dart
final cubit = context.cubit<CounterCubit>();
```

### Get State

```dart
final state = context.state<CounterCubit, CounterState>();
```

### Watch Cubit (Rebuilds on state change)

```dart
final cubit = context.watchCubit<CounterCubit>();
```

### Watch State (Rebuilds on state change)

```dart
final state = context.watchState<CounterCubit, CounterState>();
```

### Select State Slice (Rebuilds only when selected value changes)

**Performance:** Uses `context.select` internally - only rebuilds when the selected value changes.

```dart
final count = context.selectState<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
);
```

## Type-Safe Widgets

### Selector (Rebuilds only when selected value changes)

```dart
TypeSafeBlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('$count'),
)
```

### Builder (Rebuilds on any state change)

```dart
TypeSafeBlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)
```

### Consumer (Listener + Builder)

```dart
TypeSafeBlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    // Side effects (navigation, dialogs, etc.)
  },
  builder: (context, state) => Text('${state.count}'),
)
```

## BlocProvider Helpers

### Basic Provider

```dart
BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
  create: () => CounterCubit(...),
  builder: (context, cubit) => MyWidget(),
)
```

### Provider with Async Init

```dart
BlocProviderHelpers.withCubitAsyncInit<CounterCubit, CounterState>(
  create: () => CounterCubit(...),
  init: (cubit) => cubit.loadInitial(),
  builder: (context, cubit) => MyWidget(),
)
```

## Migration Cheat Sheet

| Old Pattern | New Type-Safe Pattern |
| :--- | :--- |
| `context.read<CounterCubit>()` | `context.cubit<CounterCubit>()` |
| `BlocSelector<C, S, T>(...)` | `TypeSafeBlocSelector<C, S, T>(...)` |
| `BlocBuilder<C, S>(...)` | `TypeSafeBlocBuilder<C, S>(...)` |
| `BlocConsumer<C, S>(...)` | `TypeSafeBlocConsumer<C, S>(...)` |

## Benefits

✅ **Compile-time type checking** - Catch errors before runtime
✅ **Better IDE support** - Full autocomplete and type inference
✅ **Clear error messages** - Helpful errors when cubits are missing
✅ **Refactoring safety** - Type changes propagate automatically

## Related Documentation

- [Complete Usage Guide](compile_time_safety_usage.md) - Detailed examples and best practices
- [State Management Choice](state_management_choice.md) - Why BLoC/Cubit and compile-time safety rationale
