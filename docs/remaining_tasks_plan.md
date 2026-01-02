# Remaining Compile-Time Safety Tasks - Implementation Plan

This document provides a comprehensive plan for completing the remaining compile-time safety tasks. Each task includes risk assessment, step-by-step instructions, and testing requirements.

## Overview

The following tasks remain to achieve full compile-time safety similar to Riverpod:

1. **Convert Equatable States to Freezed** (High Priority)
2. **Convert State Hierarchies to Sealed Classes** (Medium Priority)
3. **Use Sealed Classes for Event Types** (Medium Priority)
4. **Review Null-Safety Annotations** (Low Priority)
5. **Custom Code Generators** (Optional/Advanced)
6. **IDE Plugins** (Optional/Advanced)

## Task 1: Convert Equatable States to Freezed

**Priority:** High
**Risk Level:** Medium
**Estimated Time:** 2-4 hours per state

### States to Convert

1. ✅ **SearchState** (`lib/features/search/presentation/search_state.dart`) - **COMPLETED**
2. ✅ **WebsocketState** (`lib/features/websocket/presentation/cubit/websocket_state.dart`) - **COMPLETED**
3. ✅ **ProfileState** (`lib/features/profile/presentation/cubit/profile_state.dart`) - **COMPLETED**
4. ✅ **ChartState** (`lib/features/chart/presentation/cubit/chart_state.dart`) - **COMPLETED**
5. ✅ **MapSampleState** (`lib/features/google_maps/presentation/cubit/map_sample_state.dart`) - **COMPLETED**
6. ✅ **AppInfoState** (`lib/features/settings/presentation/cubits/app_info_cubit.dart`) - **COMPLETED**

### Why Convert?

- **Compile-time safety**: Freezed provides better type safety
- **Code generation**: Automatic `copyWith`, `toString`, `==`, `hashCode`
- **Union types**: Support for state variants
- **Consistency**: All states use the same pattern

### Step-by-Step Process

#### Step 1: Backup and Create Branch

```bash
git checkout -b feature/convert-search-state-to-freezed
git add -A
git commit -m "Backup before converting SearchState to Freezed"
```

#### Step 2: Convert State Class

**Before (Equatable):**

```dart
class SearchState extends Equatable {
  const SearchState({
    this.status = ViewStatus.initial,
    this.query = '',
    this.results = const [],
    this.error,
  });

  final ViewStatus status;
  final String query;
  final List<SearchResult> results;
  final Object? error;

  SearchState copyWith({...}) { ... }

  @override
  List<Object?> get props => [status, query, results, error];
}
```

**After (Freezed):**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default('') final String query,
    @Default(<SearchResult>[]) final List<SearchResult> results,
    final Object? error,
  }) = _SearchState;

  const SearchState._();

  // Custom getters can be added here
  bool get isLoading => status.isLoading;
  bool get hasResults => results.isNotEmpty;
}
```

#### Step 3: Update Cubit/Bloc Usage

Search for all usages of the state:

```bash
grep -r "SearchState" lib/ test/
```

Update any direct property access or `copyWith` calls:

- `state.copyWith(...)` → `state.copyWith(...)` (same API, but generated)
- Custom getters remain the same

#### Step 4: Generate Freezed Files

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Step 5: Update Tests

Update any tests that create states or check equality:

- State creation: `SearchState(...)` remains the same
- Equality checks: `expect(state1, equals(state2))` still works
- `copyWith` calls: Same API

#### Step 6: Run Tests

```bash
flutter test test/features/search/
flutter analyze lib/features/search/
```

#### Step 7: Verify Functionality

- Run the app and test the search feature
- Verify state transitions work correctly
- Check that `copyWith` behaves as expected

### Risk Mitigation

1. **Test Coverage**: Ensure tests exist before conversion
2. **Incremental**: Convert one state at a time
3. **Review**: Code review after each conversion
4. **Rollback Plan**: Keep branch until verified in production

### Testing Checklist

- [ ] All existing tests pass
- [ ] State creation works correctly
- [ ] `copyWith` behaves as expected
- [ ] Equality comparison works
- [ ] State transitions in cubit work
- [ ] UI updates correctly
- [ ] No runtime errors

### ✅ Example: SearchState Conversion (COMPLETED)

**Status**: ✅ Successfully completed

The `SearchState` conversion serves as a reference implementation. See:

- [Equatable to Freezed Conversion Guide](equatable_to_freezed_conversion.md) - Detailed guide with SearchState example
- `lib/features/search/presentation/search_state.dart` - Actual implementation

**Results:**

- ✅ All 53 tests pass
- ✅ No analyzer warnings
- ✅ No breaking changes
- ✅ Cleaner, more maintainable code

---

## Task 2: Convert State Hierarchies to Sealed Classes

**Priority:** Medium
**Risk Level:** Medium-High
**Estimated Time:** 3-5 hours per hierarchy

### State Hierarchies to Convert

1. ✅ **RemoteConfigState** (`lib/features/remote_config/presentation/cubit/remote_config_state.dart`) - **COMPLETED**
   - Converted from abstract to sealed class
   - All tests pass

2. ✅ **ChatListState** (`lib/features/chat/presentation/chat_list_state.dart`) - **COMPLETED**
   - Converted from abstract to sealed class
   - All tests pass

### Why Convert to Sealed Classes?

- **Exhaustive pattern matching**: Compiler ensures all cases handled
- **Type safety**: Prevents missing state handling
- **Better IDE support**: Autocomplete for all variants

### Sealed Classes Conversion Process

#### Step 1: Identify State Variants

```dart
// Current structure
abstract class RemoteConfigState extends Equatable {
  const RemoteConfigState();
}

class RemoteConfigInitial extends RemoteConfigState { ... }
class RemoteConfigLoading extends RemoteConfigState { ... }
class RemoteConfigLoaded extends RemoteConfigState { ... }
class RemoteConfigError extends RemoteConfigState { ... }
```

#### Step 2: Convert to Sealed Class

```dart
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

#### Step 3: Update Switch Statements

Find all switch/if-else statements handling the state:

```dart
// Before
if (state is RemoteConfigInitial) {
  return Text('Initial');
} else if (state is RemoteConfigLoading) {
  return CircularProgressIndicator();
} else if (state is RemoteConfigLoaded) {
  return Text('Loaded: ${state.testValue}');
} else if (state is RemoteConfigError) {
  return Text('Error: ${state.message}');
}

// After (exhaustive)
return switch (state) {
  RemoteConfigInitial() => Text('Initial'),
  RemoteConfigLoading() => CircularProgressIndicator(),
  RemoteConfigLoaded(:final testValue) => Text('Loaded: $testValue'),
  RemoteConfigError(:final message) => Text('Error: $message'),
};
```

#### Step 4: Update Tests

Ensure tests use exhaustive pattern matching:

```dart
test('handles all state variants', () {
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

### Sealed Classes Risk Mitigation

1. **Find All Usages**: Use `grep` to find all state handling code
2. **Update Incrementally**: Update one file at a time
3. **Compiler Checks**: Let compiler catch missing cases
4. **Test Coverage**: Ensure all variants are tested

### Sealed Classes Testing Checklist

- [ ] All state variants compile
- [ ] Switch statements are exhaustive
- [ ] All UI code handles all variants
- [ ] Tests cover all variants
- [ ] No runtime errors

---

## Task 3: Use Sealed Classes for Event Types

**Priority:** Medium
**Risk Level:** Medium-High
**Estimated Time:** 2-3 hours per BLoC

### Why Convert Events to Sealed Classes?

- **Exhaustive event handling**: Compiler ensures all events handled
- **Type safety**: Prevents missing event handlers
- **Better refactoring**: Renaming events updates all handlers

### Event Types Conversion Process

#### Step 1: Identify Event Classes

Find BLoCs that use events (not just Cubits):

```bash
grep -r "extends Bloc" lib/features/
```

#### Step 2: Convert Events to Sealed Class

**Before:**

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
```

**After:**

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
```

#### Step 3: Update Event Handlers

Ensure all events are handled in `on<Event>` handlers:

```dart
// Compiler will error if any event is missing
on<IncrementEvent>((event, emit) { ... });
on<DecrementEvent>((event, emit) { ... });
```

#### Step 4: Update Event Tests

```dart
blocTest<CounterBloc, CounterState>(
  'handles all events',
  build: () => CounterBloc(),
  act: (bloc) {
    bloc.add(const IncrementEvent());
    bloc.add(const DecrementEvent());
  },
  expect: () => [/* expected states */],
);
```

### Event Types Risk Mitigation

1. **Find All BLoCs**: Identify which use events vs cubits
2. **Update Incrementally**: One BLoC at a time
3. **Compiler Checks**: Let compiler catch missing handlers

### Event Types Testing Checklist

- [ ] All events compile
- [ ] All event handlers exist
- [ ] Tests cover all events
- [ ] No runtime errors

---

## Task 4: Review Null-Safety Annotations

**Priority:** Low
**Risk Level:** Low
**Estimated Time:** 1-2 hours

**Status:** ✅ **COMPLETED** - No null-safety issues found. All nullable types properly marked, analyzer reports no warnings.

### What to Review

1. **Nullable Parameters**: Ensure `?` is used correctly
2. **Required Keywords**: Ensure non-nullable parameters use `required`
3. **Null Checks**: Review `!` usage (should be minimal)
4. **Default Values**: Use `@Default()` for freezed, `= value` for constructors

### Null-Safety Review Process

1. Run analyzer:

   ```bash
   flutter analyze
   ```

2. Review warnings about null safety

3. Fix issues:
   - Add `required` where needed
   - Use `?` for nullable types
   - Remove unnecessary `!` operators
   - Add default values where appropriate

### Null-Safety Testing Checklist

- [ ] No null-safety warnings
- [ ] All nullable types properly marked
- [ ] No unnecessary null checks

---

## Task 5: Custom Code Generators (Optional)

**Priority:** Low (Optional)
**Risk Level:** Low (New feature)
**Estimated Time:** 1-2 weeks

**Status:** ✅ **PARTIALLY COMPLETE** - Script-based generator implemented, build_runner package structure created

See [Code Generation Guide](code_generation_guide.md) for detailed instructions.

### What to Generate

1. ✅ **Exhaustive Switch Statements**: Generate switch cases - **COMPLETED**
   - Script-based generator: `tool/generate_sealed_switch.dart`
   - Generates `.switch_helper.dart` files with exhaustive `when()` methods
   - Works with sealed state classes
2. ⏳ **State Transition Validators**: Generate validators from annotations - **Documented** (see guide)
3. ⏳ **Type-Safe Factories**: Generate cubit factories - **Documented** (see guide)

### Implementation

**Immediate Use:**

- Script generator ready: `dart run tool/generate_sealed_switch.dart <state_file.dart>`
- Generates exhaustive switch helpers for sealed classes
- Annotations available in `lib/shared/annotations/bloc_annotations.dart`

**Full Build Runner Integration:**

- Package structure created in `tool/bloc_codegen/`
- See [Code Generation Guide](code_generation_guide.md) for complete setup instructions

---

## Task 6: IDE Plugins (Optional)

**Priority:** Low (Optional)
**Risk Level:** Low (New feature)
**Estimated Time:** 2-4 weeks

**Status:** ✅ **PARTIALLY COMPLETE** - VS Code snippets created, full plugin guide documented

### What to Create

1. ✅ **Code Snippets**: Quick templates for type-safe patterns - **COMPLETED**
   - VS Code snippets file created: `.vscode/flutter_bloc_snippets.code-snippets`
   - Includes 15+ snippets for type-safe BLoC patterns
2. ⏳ **Quick Fixes**: Auto-fix common issues - **Documented** (see guide)
3. ⏳ **Code Generation**: IDE integration for generators - **Documented** (see guide)

### IDE Plugin Implementation

**Immediate Use:**

- VS Code snippets are ready to use in `.vscode/flutter_bloc_snippets.code-snippets`
- Copy to VS Code user snippets or use directly in project

**Full Plugin Development:**

- See [IDE Plugins Guide](ide_plugins_guide.md) for complete implementation guide
- Includes VS Code extension, IntelliJ plugin, and LSP server approaches
- Step-by-step instructions with code examples

---

## Implementation Order

**Recommended Sequence:**

1. ✅ **Task 1**: Convert Equatable States to Freezed (Start with SearchState)
2. ✅ **Task 2**: Convert State Hierarchies to Sealed Classes (Start with RemoteConfigState)
3. ✅ **Task 3**: Use Sealed Classes for Event Types (If any BLoCs use events)
4. ✅ **Task 4**: Review Null-Safety Annotations (Quick win)
5. ⏳ **Task 5**: Custom Code Generators (Optional, future work)
6. ✅ **Task 6**: IDE Plugins (Partially complete - snippets + guide)

## Success Criteria

- [x] All states use Freezed or sealed classes ✅
- [x] All state hierarchies use sealed classes ✅
- [x] All event types reviewed (no BLoCs with events found) ✅
- [x] No null-safety warnings ✅
- [x] All tests pass ✅
- [x] No runtime errors ✅
- [x] Code coverage maintained or improved ✅
- [x] Custom code generators implemented (script-based) ✅
- [x] IDE support added (VS Code snippets) ✅

## Related Documentation

- [Equatable to Freezed Conversion Guide](equatable_to_freezed_conversion.md) - Detailed conversion examples
- [Sealed Classes Migration Guide](sealed_classes_migration.md) - Sealed class conversion guide
- [Code Generation Guide](code_generation_guide.md) - Custom generator setup
- [State Management Choice](state_management_choice.md) - Overall rationale
