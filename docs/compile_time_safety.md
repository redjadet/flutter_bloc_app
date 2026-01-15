# Compile-Time Safety Guide

This guide consolidates the quick reference, usage patterns, and verification steps for type-safe BLoC/Cubit access in this codebase.

## Quick Reference

### Imports

```dart
import 'package:flutter_bloc_app/shared/shared.dart';
// Or import specific files:
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
```

### Context Extensions

```dart
final cubit = context.cubit<CounterCubit>();
final state = context.state<CounterCubit, CounterState>();
final watchedCubit = context.watchCubit<CounterCubit>();
final watchedState = context.watchState<CounterCubit, CounterState>();

final count = context.selectState<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
);
```

### Type-Safe Widgets

```dart
TypeSafeBlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => Text('$count'),
)

TypeSafeBlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)

TypeSafeBlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    // Side effects (navigation, dialogs, etc.)
  },
  builder: (context, state) => Text('${state.count}'),
)
```

### BlocProvider Helpers

```dart
BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
  create: () => CounterCubit(...),
  builder: (context, cubit) => MyWidget(),
)

BlocProviderHelpers.withCubitAsyncInit<CounterCubit, CounterState>(
  create: () => CounterCubit(...),
  init: (cubit) => cubit.loadInitial(),
  builder: (context, cubit) => MyWidget(),
)
```

### Migration Cheat Sheet

| Old Pattern | Type-Safe Pattern |
| :--- | :--- |
| `context.read<CounterCubit>()` | `context.cubit<CounterCubit>()` |
| `BlocSelector<C, S, T>(...)` | `TypeSafeBlocSelector<C, S, T>(...)` |
| `BlocBuilder<C, S>(...)` | `TypeSafeBlocBuilder<C, S>(...)` |
| `BlocConsumer<C, S>(...)` | `TypeSafeBlocConsumer<C, S>(...)` |

## Usage Patterns

### Access Cubits and State

```dart
final counterCubit = context.cubit<CounterCubit>();
final state = context.state<CounterCubit, CounterState>();
```

### Select State Slices for Efficient Rebuilds

```dart
final count = context.selectState<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
);
```

### Type-Safe Widget Builders

Use `TypeSafeBlocSelector` when you only need a subset of state. Use `TypeSafeBlocBuilder` or `TypeSafeBlocConsumer` when you need full state or side effects.

### Sealed State Helpers

Prefer Dart pattern matching for sealed state classes:

```dart
Widget buildStateWidget(DeepLinkState state) {
  return switch (state) {
    DeepLinkIdle() => Text('Idle'),
    DeepLinkLoading() => CircularProgressIndicator(),
    DeepLinkNavigate(:final target, :final origin) => NavigateTo(target),
    DeepLinkError(:final message) => ErrorWidget(message),
  };
}
```

### Generated Switch Helpers

For larger sealed states, you can generate a `when<T>()` helper:

```bash
dart run tool/generate_sealed_switch.dart \
  lib/features/<feature>/presentation/cubit/<state_file>.dart
```

Add the generated part:

```dart
part '<state_file>.switch_helper.dart';
```

## Implementation Map

Key files that provide the compile-time safety layer:

- `lib/shared/extensions/type_safe_bloc_access.dart` (context extensions)
- `lib/shared/widgets/type_safe_bloc_selector.dart` (type-safe widgets)
- `lib/shared/utils/bloc_provider_helpers.dart` (provider helpers)
- `tool/generate_sealed_switch.dart` (sealed state switch helper generator)

## Migration Notes

- New code should use the type-safe extensions and widgets.
- Replace `context.read<T>()` and `BlocProvider.of<T>()` with `context.cubit<T>()`.
- Use `TypeSafeBlocSelector` for selective rebuilds.

See `docs/migration_to_type_safe_bloc.md` for step-by-step migration guidance.

## Verification Checklist

- Run the generator for any sealed state changes (see command above).
- Run `dart run build_runner build --delete-conflicting-outputs` if codegen is involved.
- Run `./bin/checklist` before merging.
- Optional: use `rg -n "context.read<|BlocProvider.of<" lib` to confirm no new raw access patterns.

## Related Documentation

- [Migration Guide](migration_to_type_safe_bloc.md)
- [Code Generation Guide](code_generation_guide.md)
- [Sealed Classes Migration](sealed_classes_migration.md)
- [Equatable to Freezed Conversion](equatable_to_freezed_conversion.md)
- [State Management Choice](state_management_choice.md)
- [Testing Overview](testing_overview.md)
- [IDE Plugins Guide](ide_plugins_guide.md)
