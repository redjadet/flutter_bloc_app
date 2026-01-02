# Equatable to Freezed Conversion Guide

This guide provides detailed instructions for converting Equatable-based state classes to Freezed.

## Overview

Converting states from `Equatable` to `Freezed` provides:

- Automatic code generation (`copyWith`, `toString`, `==`, `hashCode`)
- Better type safety
- Union type support
- Consistent patterns across codebase

## Prerequisites

1. Ensure `freezed_annotation` and `build_runner` are in `pubspec.yaml`
2. Have test coverage for the state class
3. Create a feature branch

## Step-by-Step Conversion

### Example: SearchState Conversion

#### Step 1: Current State (Equatable)

```dart
// lib/features/search/presentation/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

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

  bool get isLoading => status.isLoading;
  bool get hasResults => results.isNotEmpty;

  SearchState copyWith({
    final ViewStatus? status,
    final String? query,
    final List<SearchResult>? results,
    final Object? error,
    final bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results != null
        ? List<SearchResult>.unmodifiable(results)
        : this.results,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, query, results, error];
}
```

#### Step 2: Convert to Freezed

```dart
// lib/features/search/presentation/search_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

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

  // Custom getters (preserved from original)
  bool get isLoading => status.isLoading;
  bool get hasResults => results.isNotEmpty;
}
```

#### Step 3: Key Changes

1. **Imports**: Replace `equatable` with `freezed_annotation`
2. **Part Directive**: Add `part 'search_state.freezed.dart';`
3. **Annotation**: Add `@freezed` before class
4. **Mixin**: Add `with _$SearchState`
5. **Factory Constructor**: Use `const factory` instead of regular constructor
6. **Default Values**: Use `@Default()` annotation
7. **Private Constructor**: Add `const SearchState._();` for custom methods
8. **Remove**: Remove `copyWith`, `props`, `Equatable` extension

#### Step 4: Handle Special Cases

##### Custom Methods

Preserve custom methods in the private constructor:

```dart
const SearchState._();

bool get isLoading => status.isLoading;
bool get hasResults => results.isNotEmpty;

// Custom factory methods
factory SearchState.initial() => const SearchState();
```

##### Complex copyWith Logic

If `copyWith` has special logic (like `clearError`), you may need to:

###### Option 1: Use Freezed's built-in copyWith

```dart
// Freezed generates copyWith automatically
state.copyWith(error: null) // Clear error
```

###### Option 2: Add custom extension method

```dart
extension SearchStateExtension on SearchState {
  SearchState clearError() => copyWith(error: null);
}
```

##### Immutable Lists

Freezed handles immutability automatically, but if you need special handling:

```dart
@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default(<SearchResult>[])
    @JsonKey(fromJson: _resultsFromJson)
    final List<SearchResult> results,
  }) = _SearchState;

  const SearchState._();

  static List<SearchResult> _resultsFromJson(List<dynamic> json) {
    return List<SearchResult>.unmodifiable(
      json.map((e) => SearchResult.fromJson(e)).toList(),
    );
  }
}
```

#### Step 5: Generate Freezed Files

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Step 6: Update Cubit/Bloc Usage

Search for all usages:

```bash
grep -r "SearchState" lib/ test/
```

**No changes needed** - Freezed's `copyWith` has the same API:

```dart
// Before and After - same API
state.copyWith(query: 'new query')
state.copyWith(error: null) // Clear error
```

#### Step 7: Update Tests

Freezed states work the same way in tests:

```dart
// Before and After - same API
test('initial state', () {
  const state = SearchState();
  expect(state.query, '');
  expect(state.status, ViewStatus.initial);
});

test('copyWith', () {
  const state = SearchState();
  final updated = state.copyWith(query: 'test');
  expect(updated.query, 'test');
});
```

#### Step 8: Verify

1. **Run Tests**:

   ```bash
   flutter test test/features/search/
   ```

2. **Run Analyzer**:

   ```bash
   flutter analyze lib/features/search/
   ```

3. **Test in App**: Run the app and test the search feature

## Common Patterns

### Pattern 1: Simple State

```dart
@freezed
abstract class SimpleState with _$SimpleState {
  const factory SimpleState({
    required final int value,
    final String? message,
  }) = _SimpleState;
}
```

### Pattern 2: State with Defaults

```dart
@freezed
abstract class StateWithDefaults with _$StateWithDefaults {
  const factory StateWithDefaults({
    @Default(0) final int count,
    @Default('') final String name,
    @Default(<String>[]) final List<String> items,
  }) = _StateWithDefaults;
}
```

### Pattern 3: State with Custom Getters

```dart
@freezed
abstract class StateWithGetters with _$StateWithGetters {
  const factory StateWithGetters({
    required final int count,
    required final int max,
  }) = _StateWithGetters;

  const StateWithGetters._();

  bool get isFull => count >= max;
  bool get isEmpty => count == 0;
}
```

### Pattern 4: State with Factory Methods

```dart
@freezed
abstract class StateWithFactories with _$StateWithFactories {
  const factory StateWithFactories({
    required final int value,
    @Default(ViewStatus.initial) final ViewStatus status,
  }) = _StateWithFactories;

  const StateWithFactories._();

  factory StateWithFactories.initial() => const StateWithFactories(value: 0);

  factory StateWithFactories.success(int value) => StateWithFactories(
    value: value,
    status: ViewStatus.success,
  );
}
```

## Troubleshooting

### Issue: "The class '_$SearchState' isn't defined"

**Solution**: Run build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "copyWith doesn't clear nullable fields"

**Solution**: Freezed's `copyWith` doesn't have a `clearError` parameter. Use:

```dart
state.copyWith(error: null) // Instead of clearError: true
```

### Issue: "Lists aren't immutable"

**Solution**: Freezed handles immutability automatically. If you need custom handling, use `@JsonKey` with custom converters.

### Issue: "Custom methods don't work"

**Solution**: Ensure you have:

1. `const StateName._();` private constructor
2. Methods defined after the private constructor

## Migration Checklist

- [ ] Create feature branch
- [ ] Add freezed imports
- [ ] Convert class to freezed format
- [ ] Add part directive
- [ ] Preserve custom getters/methods
- [ ] Run build_runner
- [ ] Update tests (if needed)
- [ ] Run all tests
- [ ] Run analyzer
- [ ] Test in app
- [ ] Code review
- [ ] Merge to main

## Related Documentation

- [Remaining Tasks Plan](remaining_tasks_plan.md) - Overall implementation plan
- [Freezed Documentation](https://pub.dev/packages/freezed) - Official Freezed docs
- [State Management Choice](state_management_choice.md) - Why Freezed was chosen
