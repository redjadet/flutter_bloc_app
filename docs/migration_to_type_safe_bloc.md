# Migration Guide: Standard BLoC to Type-Safe BLoC

This guide provides step-by-step instructions for migrating existing BLoC/Cubit code to use the new type-safe patterns implemented in this codebase.

## Overview

The type-safe BLoC features provide compile-time safety similar to Riverpod while maintaining BLoC's architectural benefits. This guide helps you migrate existing code incrementally.

## Migration Strategy

**Recommended Approach:** Migrate incrementally, feature by feature, rather than all at once.

1. Start with new features - use type-safe patterns from the beginning
2. Migrate high-traffic features next - get maximum benefit
3. Migrate remaining features over time

## Step-by-Step Migration

### Step 1: Update Imports

**Before:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
```

**After:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
// Or import specific files:
// import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
// import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
```

### Step 2: Migrate Context Access

#### Cubit Access

**Before:**

```dart
final cubit = context.read<CounterCubit>();
```

**After:**

```dart
final cubit = context.cubit<CounterCubit>();
```

**Benefits:**

- Compile-time type checking
- Clear error messages if cubit is missing
- Better IDE autocomplete

#### State Access

**Before:**

```dart
final state = context.read<CounterCubit>().state;
```

**After:**

```dart
final state = context.state<CounterCubit, CounterState>();
```

**Benefits:**

- Type-safe state access
- Compile-time validation of cubit/state relationship

### Step 3: Migrate BLoC Widgets

#### BlocSelector

**Before:**

```dart
BlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('Count: $count'),
)
```

**After:**

```dart
TypeSafeBlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('Count: $count'),
)
```

**Benefits:**

- Compile-time type checking for all generic parameters
- Better IDE support

#### BlocBuilder

**Before:**

```dart
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)
```

**After:**

```dart
TypeSafeBlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)
```

#### BlocConsumer

**Before:**

```dart
BlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Error')),
      );
    }
  },
  builder: (context, state) => Text('${state.count}'),
)
```

**After:**

```dart
TypeSafeBlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Error')),
      );
    }
  },
  builder: (context, state) => Text('${state.count}'),
)
```

### Step 4: Migrate BlocProvider Creation

#### Basic Provider

**Before:**

```dart
BlocProvider<CounterCubit>(
  create: (_) => CounterCubit(
    repository: getIt<CounterRepository>(),
    timerService: getIt<TimerService>(),
  ),
  child: CounterPage(),
)
```

**After:**

```dart
BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
  create: () => CounterCubit(
    repository: getIt<CounterRepository>(),
    timerService: getIt<TimerService>(),
  ),
  builder: (context, cubit) => CounterPage(),
)
```

#### Provider with Async Init

**Before:**

```dart
BlocProvider<CounterCubit>(
  create: (_) {
    final cubit = CounterCubit(
      repository: getIt<CounterRepository>(),
      timerService: getIt<TimerService>(),
    );
    cubit.loadInitial();
    return cubit;
  },
  child: CounterPage(),
)
```

**After:**

```dart
BlocProviderHelpers.withCubitAsyncInit<CounterCubit, CounterState>(
  create: () => CounterCubit(
    repository: getIt<CounterRepository>(),
    timerService: getIt<TimerService>(),
  ),
  init: (cubit) => cubit.loadInitial(),
  builder: (context, cubit) => CounterPage(),
)
```

### Step 5: Add State Transition Validation (Optional)

For cubits where you want to validate state transitions:

**Before:**

```dart
class CounterCubit extends Cubit<CounterState> {
  void loadData() {
    emit(state.copyWith(status: ViewStatus.loading));
    // No validation
  }
}
```

**After:**

```dart
import 'package:flutter_bloc_app/shared/utils/state_transition_validator.dart';

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

### Step 6: Migrate Sealed State Classes (If Applicable)

If you have state hierarchies using sealed classes:

**Before:**

```dart
sealed class DeepLinkState extends Equatable { ... }

// In UI - manual switch
Widget buildStateWidget(DeepLinkState state) {
  if (state is DeepLinkIdle) {
    return Text('Idle');
  } else if (state is DeepLinkLoading) {
    return CircularProgressIndicator();
  } else if (state is DeepLinkNavigate) {
    return NavigateTo(state.target);
  } else if (state is DeepLinkError) {
    return ErrorWidget(state.message);
  }
  throw StateError('Unhandled state');
}
```

**After:**

```dart
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

## Migration Checklist

Use this checklist when migrating a feature:

- [ ] Update imports to include type-safe extensions/widgets
- [ ] Replace `context.read<Cubit>()` with `context.cubit<Cubit>()`
- [ ] Replace `context.read<Cubit>().state` with `context.state<Cubit, State>()`
- [ ] Replace `BlocSelector` with `TypeSafeBlocSelector`
- [ ] Replace `BlocBuilder` with `TypeSafeBlocBuilder`
- [ ] Replace `BlocConsumer` with `TypeSafeBlocConsumer`
- [ ] Replace `BlocProvider` with `BlocProviderHelpers.withCubit` (where appropriate)
- [ ] Add state transition validation (optional, for critical features)
- [ ] Update tests to use type-safe patterns
- [ ] Run `flutter analyze` to verify no type errors
- [ ] Run tests to ensure functionality is preserved

## Testing After Migration

### Update Test Code

**Before:**

```dart
testWidgets('displays counter', (tester) async {
  await tester.pumpWidget(
    BlocProvider<CounterCubit>(
      create: (_) => CounterCubit(...),
      child: CounterPage(),
    ),
  );

  final cubit = tester.element(find.byType(CounterPage))
      .read<CounterCubit>();
  expect(cubit.state.count, 0);
});
```

**After:**

```dart
testWidgets('displays counter', (tester) async {
  await tester.pumpWidget(
    BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
      create: () => CounterCubit(...),
      builder: (context, cubit) => CounterPage(),
    ),
  );

  final context = tester.element(find.byType(CounterPage));
  final cubit = context.cubit<CounterCubit>();
  expect(cubit.state.count, 0);
});
```

## Common Migration Patterns

### Pattern 1: Simple State Access

**Before:**

```dart
final count = context.read<CounterCubit>().state.count;
```

**After:**

```dart
final state = context.state<CounterCubit, CounterState>();
final count = state.count;
```

### Pattern 2: Watching State Changes

**Before:**

```dart
BlocBuilder<CounterCubit, CounterState>(
  buildWhen: (previous, current) => previous.count != current.count,
  builder: (context, state) => Text('${state.count}'),
)
```

**After:**

```dart
TypeSafeBlocBuilder<CounterCubit, CounterState>(
  buildWhen: (previous, current) => previous.count != current.count,
  builder: (context, state) => Text('${state.count}'),
)
```

### Pattern 3: MultiBlocProvider

**Before:**

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<CounterCubit>(
      create: (_) => CounterCubit(...),
    ),
    BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(...),
    ),
  ],
  child: MyPage(),
)
```

**After:**

```dart
MultiBlocProvider(
  providers: [
    BlocProviderHelpers.providerWithAsyncInit<CounterCubit>(
      create: () => CounterCubit(...),
      init: (cubit) => cubit.loadInitial(),
    ),
    BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(...),
    ),
  ],
  child: MyPage(),
)
```

## Benefits After Migration

1. **Compile-Time Type Safety** - Catch errors before runtime
2. **Better IDE Support** - Full autocomplete and type inference
3. **Clearer Error Messages** - Helpful errors when cubits are missing
4. **Refactoring Safety** - Type changes propagate automatically
5. **Documentation** - Types serve as inline documentation

## Troubleshooting

### Issue: "Cubit of type X not found"

**Solution:** Ensure the cubit is provided via `BlocProvider` or `MultiBlocProvider` in the widget tree above where you're accessing it.

### Issue: Type errors after migration

**Solution:**

1. Check that generic types match exactly (e.g., `CounterCubit` extends `Cubit<CounterState>`)
2. Ensure imports are correct
3. Run `flutter analyze` to see detailed error messages

### Issue: Tests failing after migration

**Solution:**

1. Update test code to use type-safe patterns
2. Ensure test setup provides cubits via `BlocProvider`
3. Use `tester.element()` to get context for type-safe access

## Related Documentation

- [Compile-Time Safety Guide](compile_time_safety.md) - Complete guide with usage examples and quick reference
- [State Management Choice](state_management_choice.md) - Why these patterns were chosen
