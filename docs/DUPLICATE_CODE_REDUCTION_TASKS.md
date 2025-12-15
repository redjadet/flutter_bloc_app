# Duplicate Code Reduction Tasks

This document outlines potential tasks to further reduce code duplication in the codebase. These tasks are organized by priority and category.

## Completed Tasks ✅

The following duplication reduction tasks have already been completed:

1. **Test Setup Standardization** - Created `test/test_helpers.dart` with:
   - `setupHiveForTesting()` - Standardized Hive initialization
   - `setupTestDependencies()` - Common test dependency setup
   - `createHiveService()` - HiveService creation for tests
   - `cleanupHiveBoxes()` - Standardized cleanup
   - `setupHiveRepositoryTest()` - Helper for Hive repository tests

2. **Cubit Subscription Management** - Created `CubitSubscriptionMixin`:
   - Centralized stream subscription management
   - Automatic cleanup on cubit close
   - Used in: `WebsocketCubit`, `DeepLinkCubit`, `CounterCubitBase`

3. **BlocProvider Initialization** - Enhanced `BlocProviderHelpers`:
   - `withAsyncInit()` - Widget wrapper for async initialization
   - `providerWithAsyncInit()` - Provider for MultiBlocProvider
   - Used in: `app_scope.dart`, `deep_link_listener.dart`

4. **Debounce Timer Fakes** - Search feature tests now reuse the shared `FakeTimerService` from `test/test_helpers.dart` instead of bespoke fakes in each file. This reduced duplicate timer fake implementations in:
   - `test/features/search/presentation/widgets/search_text_field_test.dart`
   - `test/features/search/presentation/pages/search_page_test.dart`

5. **Test Mock Repository Pattern** - Added a reusable `InMemoryRepository<T>` helper in `test/test_helpers.dart` and refactored `MockCounterRepository` to extend it, consolidating common load/save/watch logic for in-memory test repositories.

6. **Widget Error & Loading State Pattern** - Added `ViewStatusSwitcher` (`lib/shared/widgets/view_status_switcher.dart`) to standardize loading/error/success handling with a single `BlocSelector`; applied to `lib/features/search/presentation/pages/search_page.dart`.

7. **Repository Initial Load Pattern** - Added `RepositoryInitialLoadHelper` (`lib/shared/utils/repository_initial_load_helper.dart`) and wired it into `RestCounterRepository` to centralize initial watch-stream loading and resolution tracking.

8. **ViewStatusSwitcher Adoption** - Extended `ViewStatusSwitcher` usage to `GraphqlDemoPage` and `ChatMessageList` to remove duplicated loading/empty/error branching and aligned the counter hint with the shared switcher.

---

## High Priority Tasks ✅

### 1. Repository Watch Pattern Standardization ✅

**Status**: Completed

**Solution Implemented**: Created `RepositoryWatchHelper<T>` in `lib/shared/utils/repository_watch_helper.dart`

**Features**:

- Generic type parameter for any data type
- StreamController lifecycle management
- Initial value emission with caching
- Error handling with optional custom handlers
- Subscription cleanup
- Prevents concurrent loads

**Usage**:

```dart
final _watchHelper = RepositoryWatchHelper<MyData>(
  loadInitial: () => _loadFromStorage(),
  emptyValue: MyData.empty(),
);

Stream<MyData> watch() {
  _watchHelper.createWatchController(
    onListen: () => _watchHelper.handleOnListen(),
    onCancel: () => _watchHelper.handleOnCancel(),
  );
  return _watchHelper.stream;
}
```

**Files Created**:

- `lib/shared/utils/repository_watch_helper.dart`

**Estimated Impact**: ~200-300 lines of duplicate code can be eliminated when repositories are refactored to use this helper

---

### 2. StreamController Lifecycle Management ✅

**Status**: Completed

**Solution Implemented**: Created `StreamControllerLifecycle<T>` mixin in `lib/shared/utils/stream_controller_lifecycle.dart`

**Features**:

- Safe value emission (checks `isClosed`)
- Safe error emission
- Automatic cleanup tracking
- Controller creation with callbacks
- Proper disposal methods

**Usage**:

```dart
class MyService with StreamControllerLifecycle<String> {
  MyService() {
    _controller = StreamController<String>.broadcast();
  }

  void updateValue(String value) {
    safeEmit(value);
  }

  @override
  Future<void> dispose() async {
    await disposeController();
  }
}
```

**Files Created**:

- `lib/shared/utils/stream_controller_lifecycle.dart`

**Estimated Impact**: ~100-150 lines of duplicate code can be eliminated when services are refactored to use this mixin

---

### 3. Error Handling Pattern Consolidation ✅

**Status**: Completed

**Solution Implemented**: Created `CubitErrorHandler<S>` mixin in `lib/shared/utils/cubit_error_handler.dart`

**Features**:

- Standardized error handling methods
- Automatic error state emission
- Context-aware logging
- Error type conversion with factory functions
- Automatic `isClosed` checks

**Usage**:

```dart
class MyCubit extends Cubit<MyState> with CubitErrorHandler {
  void loadData() async {
    try {
      final data = await _repository.fetch();
      emit(state.copyWith(data: data, status: ViewStatus.success));
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace,
        (error) => state.copyWith(
          errorMessage: error.toString(),
          status: ViewStatus.error,
        ),
        'MyCubit.loadData',
      );
    }
  }
}
```

**Files Created**:

- `lib/shared/utils/cubit_error_handler.dart`

**Estimated Impact**: ~150-200 lines of duplicate code can be eliminated when cubits are refactored to use this mixin

---

## Medium Priority Tasks

Previously identified medium-priority duplication tasks (widget error/loading handling and repository initial load flow) are now covered by shared helpers (`ViewStatusSwitcher`, `RepositoryInitialLoadHelper`). Add new medium-priority items below as they surface.

## Low Priority Tasks

### 8. Navigation Pattern Standardization

**Problem**: Similar navigation patterns with context checks:

- Checking `context.mounted` before navigation
- Error handling in navigation
- Deep link navigation patterns

**Files to Analyze**:

- `lib/features/deeplink/presentation/deep_link_listener.dart`
- Various route handlers

**Potential Solution**:
Create navigation helper utilities that:

- Automatically check `context.mounted`
- Handle navigation errors
- Provide consistent navigation patterns

**Estimated Impact**: ~50-80 lines of duplicate code eliminated

---

### 9. State Restoration Pattern

**Problem**: Similar state restoration patterns in cubits:

- Restoring from snapshots
- Handling restoration results
- Persisting restored state

**Files to Analyze**:

- `lib/features/counter/presentation/counter_cubit_base.dart`
- Other cubits with restoration logic

**Potential Solution**:
Create a `StateRestorationMixin` that provides:

- Standardized restoration logic
- Result handling
- State persistence

**Estimated Impact**: ~60-100 lines of duplicate code eliminated

---

### 10. Completer Pattern Standardization

**Problem**: Similar `Completer` usage patterns:

- Checking `isCompleted` before completing
- Error handling in completers
- Cleanup in dispose

**Files to Analyze**:

- `lib/features/counter/data/rest_counter_repository.dart`
- `lib/features/websocket/data/echo_websocket_repository.dart`
- `lib/features/remote_config/data/repositories/remote_config_repository.dart`

**Potential Solution**:
Create a `CompleterHelper` utility that provides:

- Safe completion methods
- Error handling
- Cleanup helpers

**Estimated Impact**: ~40-60 lines of duplicate code eliminated

---

## Analysis Recommendations

### Before Starting Any Task

1. **Search for Patterns**: Use `grep` and `codebase_search` to find all instances of the pattern
2. **Measure Impact**: Count lines of duplicate code that would be eliminated
3. **Identify Edge Cases**: Look for variations that might need special handling
4. **Create Tests**: Ensure existing tests cover the patterns before refactoring
5. **Incremental Refactoring**: Refactor one file at a time, running tests after each change

### Testing Strategy

For each refactoring:

1. Run existing tests to establish baseline
2. Refactor one file/pattern at a time
3. Run tests after each change
4. Verify no functionality is broken
5. Update documentation if needed

### Code Review Checklist

- [ ] All existing tests pass
- [ ] No new linter errors
- [ ] Documentation updated
- [ ] Examples provided in helper classes
- [ ] Edge cases handled
- [ ] Performance impact assessed

---

## Estimated Total Impact

**Completed Tasks**:

- **High Priority**: ✅ All 3 tasks completed - Utilities created and ready for use
  - `RepositoryWatchHelper<T>` - Generic repository watch helper
  - `StreamControllerLifecycle<T>` - StreamController lifecycle mixin
  - `CubitErrorHandler<S>` - Cubit error handling mixin

**Remaining Tasks**:

- **Medium Priority**: Add new items as they are identified (current backlog cleared)
- **Low Priority**: ~150-240 lines can be eliminated
- **Total Potential**: ~150-240 additional lines of duplicate code can be eliminated (based on low-priority backlog)

**Note**: The high priority utilities are now available for use. Repositories, services, and cubits can be incrementally refactored to use these utilities, which will eliminate the estimated duplicate code as they are adopted.

---

## Notes

- These tasks should be prioritized based on:
  - Frequency of pattern usage
  - Maintenance burden
  - Risk of introducing bugs
  - Developer time available

- Some patterns may be intentionally duplicated if:
  - They are domain-specific
  - Abstraction would reduce clarity
  - Performance would be negatively impacted

- Always measure before and after to ensure the refactoring provides value.
