# Todo List Feature Guide

This document provides a comprehensive guide for implementing a Todo List feature that demonstrates clean architecture, compile-time safety, and responsive/adaptive UI patterns used throughout this codebase.

## Goals and Scope

**Primary goal:** Provide a lightweight, offline-first Todo List feature that demonstrates:

- Clean architecture (Domain → Data → Presentation)
- Compile-time safety with type-safe BLoC/Cubit patterns
- Responsive and platform-adaptive UI
- Proper error handling and lifecycle management

**Out of scope (initial demo):** Multi-user sync, push notifications, and server-backed collaboration.

## Requirements Analysis

### Functional Requirements (MVP)

- Create a todo with title and optional description.
- Edit an existing todo.
- Toggle completion status.
- Delete a todo with undo support.
- View list grouped or filtered by status (All, Active, Completed).
- Search todos by title or description.
- View statistics (total, active, completed counts).
- **Sort todos** by date (newest/oldest first), title (A-Z/Z-A), or manual order.
- **Drag-to-reorder** items when manual sorting is active.
- Persist todos locally across app launches.
- **Swipe gestures on mobile devices**:
  - Swipe right: Complete active items or uncomplete completed items
  - Swipe left: Delete items with confirmation dialog

### Non-Functional Requirements

- **Architecture**: No Flutter imports in domain layer; strict Domain → Data → Presentation flow
- **State Management**: Use Cubit for business logic; widgets handle layout only
- **Lifecycle**: No side effects in `build()`; use `initState()` or route-level initialization
- **Compile-Time Safety**: Use type-safe extensions (`context.cubit<T>()`, `context.selectState<...>()`) instead of `context.read()`
- **Error Handling**: Use `CubitExceptionHandler` for all async operations; guard emits with `if (isClosed) return;`
- **UI**: Adaptive UI with `CommonPageLayout`, `PlatformAdaptive.*` widgets, `colorScheme` colors
- **Localization**: All user-facing strings via `context.l10n.*` (no hard-coded strings)
- **Performance**: Use `TypeSafeBlocSelector` for granular list rebuilds
- **Persistence**: Use `HiveRepositoryBase`; never call `Hive.openBox` directly

### Stretch Goals (Optional)

- Due dates and priority.
- Batch actions (select multiple).
- Deferred route loading if dependencies grow heavy.

## Data Model

### Domain Entity

`TodoItem` (pure Dart, immutable):

- `id` (String, stable UUID)
- `title` (String)
- `description` (String?)
- `isCompleted` (bool)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

Use `@freezed` for immutability and `copyWith`. Keep adapters in data layer.

**Example:**

```dart
// lib/features/todo_list/domain/todo_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';

@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required final String id,
    required final String title,
    final String? description,
    @Default(false) final bool isCompleted,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _TodoItem;

  const TodoItem._();

  /// Factory for creating a new todo item
  factory TodoItem.create({
    required final String title,
    final String? description,
  }) =>
      TodoItem(
        id: const Uuid().v4(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
```

## Architecture Blueprint

### Domain Layer (`lib/features/todo_list/domain/`)

- `todo_item.dart` (Freezed model, Dart-only)
- `todo_repository.dart` (abstract contract)

**Repository Contract:**

```dart
// lib/features/todo_list/domain/todo_repository.dart
abstract class TodoRepository {
  /// Watch all todos as a stream
  Stream<List<TodoItem>> watchAll();

  /// Fetch all todos once
  Future<List<TodoItem>> fetchAll();

  /// Create or update a todo item
  Future<void> save(TodoItem item);

  /// Delete a todo by ID
  Future<void> delete(String id);

  /// Delete all completed todos
  Future<void> clearCompleted();
}
```

**Key Points:**

- Pure Dart interface (no Flutter imports)
- Returns domain entities (`TodoItem`), not DTOs
- Uses `Stream` for reactive updates
- All methods are async for consistency

### Data Layer (`lib/features/todo_list/data/`)

Implement a Hive-backed repository using `HiveRepositoryBase`:

- `hive_todo_repository.dart`
- `todo_item_dto.dart` (Hive adapter/DTO)

**Implementation Rules:**

- Never call `Hive.openBox`; use `HiveService` via `HiveRepositoryBase`
- Map DTOs to domain entities inside the repository
- Consider `decodeJsonMap()` only if parsing large JSON (>8KB, not expected for MVP)
- Register Hive adapter during app startup

**Example Structure:**

```dart
// lib/features/todo_list/data/todo_item_dto.dart
@HiveType(typeId: TodoItemDto.typeId)
class TodoItemDto {
  static const int typeId = 42; // Unique type ID

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final bool isCompleted;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final DateTime updatedAt;

  // ... to/from domain mapping methods
}

// lib/features/todo_list/data/hive_todo_repository.dart
class HiveTodoRepository extends HiveRepositoryBase implements TodoRepository {
  HiveTodoRepository({
    required final HiveService hiveService,
    required final HiveKeyManager keyManager,
  }) : super(hiveService: hiveService, keyManager: keyManager);

  @override
  Stream<List<TodoItem>> watchAll() {
    // Implementation using HiveService
  }

  // ... other methods
}
```

### Presentation Layer (`lib/features/todo_list/presentation/`)

- `cubit/todo_list_cubit.dart` (main cubit, ~180 lines)
- `cubit/todo_list_cubit_helpers.dart` (static helper methods)
- `cubit/todo_list_cubit_logging.dart` (logging helpers)
- `cubit/todo_list_cubit_methods.dart` (mixin with private methods)
- `cubit/todo_list_state.dart` (Freezed)
- `pages/todo_list_page.dart`
- `widgets/todo_list_item.dart` (with swipe gesture support)
- `widgets/todo_filter_bar.dart` (filter chips)
- `widgets/todo_empty_state.dart` (empty state)
- `widgets/todo_stats_widget.dart` (statistics display)
- `widgets/todo_search_field.dart` (search input)
- `widgets/todo_sort_bar.dart` (sort selection)
- `helpers/todo_list_dialogs.dart` (adaptive dialogs)

**State Definition (Freezed):**

```dart
// lib/features/todo_list/presentation/cubit/todo_list_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

part 'todo_list_state.freezed.dart';

@freezed
abstract class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(ViewStatus.initial) final ViewStatus status,
    @Default(<TodoItem>[]) final List<TodoItem> items,
    @Default(TodoFilter.all) final TodoFilter filter,
    @Default('') final String searchQuery,
    @Default(TodoSortOrder.dateDesc) final TodoSortOrder sortOrder,
    @Default(<String, int>{}) final Map<String, int> manualOrder,
    final String? errorMessage,
  }) = _TodoListState;

  const TodoListState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasItems => items.isNotEmpty;

  List<TodoItem> get filteredItems {
    // Early return if no items
    if (items.isEmpty) {
      return const <TodoItem>[];
    }

    // Apply filter
    List<TodoItem> result = switch (filter) {
      TodoFilter.all => items,
      TodoFilter.active =>
        items.where((final item) => !item.isCompleted).toList(growable: false),
      TodoFilter.completed =>
        items.where((final item) => item.isCompleted).toList(growable: false),
    };

    // Early return if filter resulted in empty list
    if (result.isEmpty) {
      return const <TodoItem>[];
    }

    // Apply search query if present
    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();
      result = result
          .where(
            (final item) =>
                item.title.toLowerCase().contains(query) ||
                (item.description?.toLowerCase().contains(query) ?? false),
          )
          .toList(growable: false);

      // Early return if search resulted in empty list
      if (result.isEmpty) {
        return const <TodoItem>[];
      }
    }

    // Apply sorting
    return _applySorting(result);
  }

  List<TodoItem> _applySorting(final List<TodoItem> items) {
    final List<TodoItem> sorted = List<TodoItem>.from(items);

    switch (sortOrder) {
      case TodoSortOrder.dateDesc:
        sorted.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case TodoSortOrder.dateAsc:
        sorted.sort((final a, final b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case TodoSortOrder.titleAsc:
        sorted.sort(
          (final a, final b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case TodoSortOrder.titleDesc:
        sorted.sort(
          (final a, final b) =>
              b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case TodoSortOrder.manual:
        sorted.sort((final a, final b) {
          final int orderA = manualOrder[a.id] ?? 0;
          final int orderB = manualOrder[b.id] ?? 0;
          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }
          // Fallback to date desc if order not set
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }

    return List<TodoItem>.unmodifiable(sorted);
  }

  bool get hasCompleted => items.any((final item) => item.isCompleted);
}

enum TodoFilter { all, active, completed }

enum TodoSortOrder {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  manual,
}
```

**Cubit Implementation Pattern:**

The cubit is split into multiple files to keep the main file under 250 lines:

```dart
// lib/features/todo_list/presentation/cubit/todo_list_cubit.dart
part 'todo_list_cubit_helpers.dart';
part 'todo_list_cubit_logging.dart';
part 'todo_list_cubit_methods.dart';

class TodoListCubit extends Cubit<TodoListState>
    with CubitSubscriptionMixin<TodoListState>, _TodoListCubitMethods {
  TodoListCubit({
    required this.repository,
    required final TimerService timerService,
    this.searchDebounceDuration = const Duration(milliseconds: 300),
  })  : _timerService = timerService,
        super(const TodoListState());

  @override
  final TodoRepository repository;
  final TimerService _timerService;
  final Duration searchDebounceDuration;
  @override
  StreamSubscription<List<TodoItem>>? subscription;
  @override
  bool isLoading = false;
  TimerDisposable? _searchDebounceHandle;

  Future<void> loadInitial() async {
    if (isClosed || isLoading) return;
    isLoading = true;
    // ... implementation with optimistic updates and stream watching
  }

  Future<void> addTodo({
    required final String title,
    final String? description,
  }) async {
    if (isClosed) return;
    // ... implementation with optimistic updates
  }

  Future<void> toggleTodo(final TodoItem item) async {
    if (isClosed) return;
    // ... implementation with optimistic updates
  }

  Future<void> deleteTodo(final TodoItem item) async {
    if (isClosed) return;
    _lastDeletedItem = item; // Store for undo
    // ... implementation with optimistic updates and state rollback
  }

  Future<void> undoDelete() async {
    if (isClosed || _lastDeletedItem == null) return;
    final TodoItem item = _lastDeletedItem!;
    _lastDeletedItem = null;
    await saveItem(item, logContext: 'TodoListCubit.undoDelete');
  }

  void setSearchQuery(final String query) {
    if (isClosed) return;
    _cancelSearchDebounce();
    final String trimmedQuery = query.trim();

    // If query is empty, update immediately
    if (trimmedQuery.isEmpty) {
      emit(state.copyWith(searchQuery: ''));
      return;
    }

    // Debounce the search query update (300ms default)
    _searchDebounceHandle = _timerService.runOnce(
      searchDebounceDuration,
      () {
        if (isClosed) return;
        emit(state.copyWith(searchQuery: trimmedQuery));
      },
    );
  }

  void _cancelSearchDebounce() {
    _searchDebounceHandle?.dispose();
    _searchDebounceHandle = null;
  }

  void setSortOrder(final TodoSortOrder sortOrder) {
    if (isClosed || sortOrder == state.sortOrder) return;
    emit(state.copyWith(sortOrder: sortOrder));
  }

  void reorderItems({
    required final int oldIndex,
    required final int newIndex,
  }) {
    if (isClosed) return;
    if (state.sortOrder != TodoSortOrder.manual) {
      // Switch to manual sort mode
      final Map<String, int> newManualOrder = <String, int>{};
      for (int i = 0; i < state.filteredItems.length; i++) {
        newManualOrder[state.filteredItems[i].id] = i;
      }
      emit(
        state.copyWith(
          sortOrder: TodoSortOrder.manual,
          manualOrder: newManualOrder,
        ),
      );
    }

    final List<TodoItem> items = List<TodoItem>.from(state.filteredItems);
    int adjustedNewIndex = newIndex;
    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }
    final TodoItem item = items.removeAt(oldIndex);
    items.insert(adjustedNewIndex, item);

    // Update manual order
    final Map<String, int> updatedOrder = Map<String, int>.from(
      state.manualOrder,
    );
    for (int i = 0; i < items.length; i++) {
      updatedOrder[items[i].id] = i;
    }

    emit(state.copyWith(manualOrder: updatedOrder));
  }

  // ... other methods
}
```

**Key Implementation Details:**

- **Optimistic Updates**: All mutations (add, update, delete, toggle) immediately update the UI, then persist to repository
- **State Rollback**: If persistence fails, the previous state is restored to maintain UI consistency
- **Stream Watching**: After initial load, subscribes to repository stream for real-time updates
- **File Splitting**: Main cubit (~180 lines) with helper files for:
  - `todo_list_cubit_helpers.dart`: Static list manipulation utilities
  - `todo_list_cubit_logging.dart`: Logging helper functions
  - `todo_list_cubit_methods.dart`: Mixin with private methods (saveItem, startWatching, etc.)
- **Offline-First**: Handles persistence failures gracefully with state rollback

**Key Patterns:**

- Use `CubitExceptionHandler` for all async operations
- Guard all `emit()` calls with `if (isClosed) return;`
- Use `TypeSafeBlocSelector` for granular rebuilds
- Use `CubitSubscriptionMixin` for automatic subscription cleanup
- Implement optimistic updates with state rollback for offline-first behavior
- Split large cubit files into helper files to maintain <250 line limit

## UI/UX Guidance

### Page Structure

```dart
// lib/features/todo_list/presentation/pages/todo_list_page.dart
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonPageLayout(
      appBar: CommonAppBar(
        title: Text(context.l10n.todoListTitle),
      ),
      child: BlocProviderHelpers.withCubitAsyncInit<TodoListCubit, TodoListState>(
        create: () => TodoListCubit(
          repository: getIt<TodoRepository>(),
        ),
        init: (cubit) => cubit.loadInitial(),
        builder: (context, cubit) => const _TodoListContent(),
      ),
    );
  }
}
```

### Type-Safe State Access

```dart
// Use type-safe extensions for cubit access
final cubit = context.cubit<TodoListCubit>();
final state = context.state<TodoListCubit, TodoListState>();

// Use TypeSafeBlocSelector for granular rebuilds
TypeSafeBlocSelector<TodoListCubit, TodoListState, List<TodoItem>>(
  selector: (state) => state.filteredItems,
  builder: (context, items) => TodoListView(items: items),
)

// Use TypeSafeBlocBuilder for full state access
TypeSafeBlocBuilder<TodoListCubit, TodoListState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const CommonLoadingWidget();
    }
    if (state.hasError) {
      return CommonErrorView(message: state.errorMessage ?? 'Unknown error');
    }
    return const TodoListContent();
  },
)
```

### UI Components

- **Buttons**: Use `PlatformAdaptive.filledButton` / `PlatformAdaptive.textButton`
- **Spacing**: Use `context.pagePadding`, `context.responsiveGap`
- **Typography**: Use `context.responsiveBodySize`, `context.responsiveTitleSize`
- **Colors**: Always use `Theme.of(context).colorScheme` (never `Colors.*`)
- **Loading**: Use `CommonLoadingWidget` for loading states
- **Empty State**: Use `CommonStatusView` for empty/error states
- **Dialogs**: Use `showAdaptiveDialog()` (never raw Material dialogs)
- **TodoStats Widget**: Displays total, active, and completed counts using `TypeSafeBlocSelector` for efficient rebuilds. Only shows when there are items.
- **TodoSearchField**: Real-time search with clear button. Filters todos by title and description as user types.
- **TodoSortBar**: Popup menu button showing current sort method (Date, Title, Manual) with dropdown arrow. Displays selected sort method text next to sort icon.
- **Undo Snackbar**: Shows after delete actions with undo button. Uses `ScaffoldMessenger` with 3-second duration.
- **RepaintBoundary**: Wraps each `TodoListItem` to prevent unnecessary repaints and improve performance.
- **Drag Handle**: Visible only when manual sorting is active. Shows drag handle icon (☰) on the left side of each item.
- **ReorderableListView**: Used when manual sort mode is active, allowing drag-to-reorder functionality.
- **Swipe Gestures**: Use `Dismissible` widget for swipe actions on mobile devices:
  - Background widgets show action labels and icons
  - Platform-adaptive styling (iOS vs Material)
  - Swipe right: Complete/uncomplete items (no confirmation)
  - Swipe left: Delete items with confirmation dialog
  - Use `onDeleteWithoutConfirmation` callback to avoid double dialogs
  - Only enabled on mobile devices (check `!context.isDesktop`)

**Swipe Gesture Implementation:**

```dart
// lib/features/todo_list/presentation/widgets/todo_list_item.dart
if (!isMobile) {
  return cardContent; // No swipe on desktop
}

return Dismissible(
  key: ValueKey('todo-dismissible-${item.id}'),
  background: _buildSwipeBackground(
    context: context,
    alignment: Alignment.centerLeft,
    color: colors.primary,
    icon: item.isCompleted ? Icons.undo_outlined : Icons.check_circle_outline,
    label: item.isCompleted
        ? l10n.todoListUndoAction
        : l10n.todoListCompleteAction,
  ),
  secondaryBackground: _buildSwipeBackground(
    context: context,
    alignment: Alignment.centerRight,
    color: colors.error,
    icon: Icons.delete_outline,
    label: l10n.todoListDeleteAction,
  ),
  confirmDismiss: (final DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      onToggle(); // Immediate toggle, no dismissal
      return false;
    } else {
      return _confirmDelete(context, item.title, l10n);
    }
  },
  onDismissed: (final DismissDirection direction) {
    if (direction == DismissDirection.endToStart) {
      (onDeleteWithoutConfirmation ?? onDelete)();
    }
  },
  child: cardContent,
);
```

## Step-By-Step Implementation Plan

### 1) Create Feature Shell

- Add `lib/features/todo_list/` with `domain/`, `data/`, `presentation/`.
- Add export barrel `lib/features/todo_list/todo_list.dart`.
- Update `lib/features/features.dart` to export the new feature.

### 2) Domain Layer

- Add `TodoItem` Freezed model.
- Add `TodoRepository` interface.

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3) Data Layer

- Create `TodoItemDto` Hive adapter.
- Implement `HiveTodoRepository extends HiveRepositoryBase`.
- Register adapter and repository in DI.

DI updates:

- `lib/core/di/injector_registrations.dart` for `registerLazySingletonIfAbsent<TodoRepository>(...)`.
- Ensure Hive adapter is registered during app startup (follow existing Hive setup patterns).

### 4) Presentation Layer

**Cubit Implementation:**

- Create `TodoListCubit` with methods: `loadInitial()`, `addTodo()`, `updateTodo()`, `toggleTodo()`, `deleteTodo()`, `undoDelete()`, `setFilter()`, `setSearchQuery()`, `setSortOrder()`, `reorderItems()`, `clearCompleted()`, `refresh()`
- Inject `TimerService` for search debouncing (300ms default)
- Implement search debouncing to reduce filtering operations while typing
- Store `_lastDeletedItem` for undo functionality
- Use `CubitExceptionHandler` for all async operations
- Guard all `emit()` calls with `if (isClosed) return;`
- Implement optimistic updates for all mutations
- Store previous state before mutations for rollback on persistence failure
- Subscribe to repository stream after initial load
- Use `CubitSubscriptionMixin` for automatic subscription cleanup
- Split large methods into helper files to keep main file under 250 lines

**Provider Setup:**

- Use `BlocProviderHelpers.withCubitAsyncInit<TodoListCubit, TodoListState>` for route-level initialization
- Pass repository via constructor injection

**UI Components:**

- Build page with stats widget, search field, filter controls, sort button, list, and add/edit dialogs
- Add `TodoStatsWidget` at the top (shows when items exist)
- Add `TodoSearchField` below stats (shows when items exist)
- Add `TodoFilterBar` with filter chips (All, Active, Completed)
- Add `TodoSortBar` and "Clear Completed" button in the same row, right-aligned (shows when items exist)
- Use `ReorderableListView` when `sortOrder == TodoSortOrder.manual` for drag-to-reorder
- Use `ListView.separated` for other sort modes
- Use `TypeSafeBlocSelector` for list items to prevent unnecessary rebuilds
- Use `TypeSafeBlocBuilder` for full state rendering
- Wrap each `TodoListItem` in `RepaintBoundary` for performance
- Show drag handle icon only when manual sorting is active
- Use `ListView.builder` for lists with 100+ items (automatic switch from `ListView.separated`)
- Set `cacheExtent: 500` on all list views for better scrolling performance
- **Implement swipe gestures** in `TodoListItem`:
  - Wrap item in `Dismissible` widget (mobile only)
  - Swipe right: Toggle completion status
  - Swipe left: Delete with confirmation dialog
  - Use `onDeleteWithoutConfirmation` callback to avoid double dialogs
  - Platform-adaptive swipe backgrounds (iOS vs Material styling)
- **Implement undo snackbar**:
  - Show snackbar after delete actions
  - Include undo action button
  - Restore deleted item if undo is pressed

**Dialog Implementation:**

- Use `showAdaptiveDialog()` for add/edit dialogs
- Do not use raw Material dialogs
- Use `PlatformAdaptive.*` widgets inside dialogs
- Use `context.l10n.*` for all strings

**Example Dialog:**

```dart
Future<void> _showAddTodoDialog(BuildContext context) async {
  final result = await showAdaptiveDialog<TodoItem>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.addTodo),
      content: const _TodoForm(),
      actions: [
        PlatformAdaptive.textButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        PlatformAdaptive.filledButton(
          onPressed: () {
            // Handle save
            Navigator.of(context).pop(todo);
          },
          child: Text(context.l10n.save),
        ),
      ],
    ),
  );
  if (result != null) {
    context.cubit<TodoListCubit>().addTodo(
      title: result.title,
      description: result.description,
    );
  }
}
```

### 5) Routing

- Add `AppRoutes.todoList` / `AppRoutes.todoListPath` in `lib/core/router/app_routes.dart`.
- Register a `GoRoute` in `lib/app/router/routes.dart`.
- Decide on deferred loading. For MVP, avoid deferred loading unless the feature grows heavy.

### 6) Localization

- Add strings to `lib/l10n/app_*.arb` for titles, actions, error messages.
- Run `flutter gen-l10n` after updates.

### 7) Tests

**Unit Tests (Repository):**

- Test DTO to domain entity mapping
- Test CRUD operations with in-memory Hive
- Test stream behavior

**Cubit Tests (bloc_test):**

- Test initial state
- Test `loadInitial()` success and error cases
- Test `addTodo()`, `updateTodo()`, `toggleTodo()`, `deleteTodo()` flows with optimistic updates
- Test filter changes
- Test sort order changes (`setSortOrder()`)
- Test drag-to-reorder (`reorderItems()`)
- Test subscription cleanup
- Test state rollback on persistence failures
- Test no-op conditions (e.g., setFilter with same filter, setSortOrder with same order, deleteTodo with missing item)

**Example Cubit Test:**

```dart
// test/features/todo_list/presentation/cubit/todo_list_cubit_test.dart
blocTest<TodoListCubit, TodoListState>(
  'loadInitial emits loading then success states',
  build: () => buildCubit(),
  act: (final cubit) async {
    await cubit.loadInitial();
  },
  expect: () => [
    _hasStatus(ViewStatus.loading),
    _hasStatus(ViewStatus.success),
  ],
);

blocTest<TodoListCubit, TodoListState>(
  'addTodo emits updated list',
  build: () => buildCubit(),
  seed: () => const TodoListState(status: ViewStatus.success, items: []),
  act: (final cubit) async {
    await cubit.addTodo(title: 'Write tests', description: '');
  },
  expect: () => [
    isA<TodoListState>()
        .having((final s) => s.items.length, 'items length', 1)
        .having((final s) => s.items.first.title, 'title', 'Write tests'),
  ],
);
```

**Widget Tests:**

- Test empty state rendering
- Test list rendering with items
- Test filter behavior
- Test add/edit dialogs
- Test error state display
- **Test swipe gestures** (mobile only):
  - Swipe right on active item completes it
  - Swipe right on completed item uncompletes it
  - Swipe left shows delete confirmation dialog
  - Swipe left cancel does not delete item
  - Swipe right does not dismiss item
  - Swipe actions only work on mobile devices

**Example Widget Test for Swipe Actions:**

```dart
// test/features/todo_list/presentation/widgets/todo_list_item_test.dart
testWidgets('swipe right on active item completes it', (
  final WidgetTester tester,
) async {
  final TodoItem activeItem = TodoItem.create(
    title: 'Active Task',
    description: null,
  );

  await tester.pumpWidget(buildWidget(item: activeItem));
  await tester.pumpAndSettle();

  final Finder dismissible = find.byType(Dismissible);
  expect(dismissible, findsOneWidget);

  final Offset start = tester.getCenter(dismissible);
  final Offset end = start + const Offset(400, 0);

  await tester.drag(dismissible, end - start);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();

  expect(onToggleCalled, isTrue);
  expect(toggledItem, equals(activeItem));
});
```

**Coverage:**

- Run `flutter test coverage`
- Update coverage summary: `dart run tool/update_coverage_summary.dart`

### 8) Validation

- Run `./bin/checklist` before finishing.
- Fix any violations from validation scripts (dialogs, buttons, timers, prints).

## Suggested File Map

```text
lib/features/todo_list/
  todo_list.dart
  domain/
    todo_item.dart
    todo_repository.dart
  data/
    hive_todo_repository.dart
    todo_item_dto.dart
  presentation/
    cubit/
      todo_list_cubit.dart (main, ~180 lines)
      todo_list_cubit_helpers.dart (static helpers)
      todo_list_cubit_logging.dart (logging)
      todo_list_cubit_methods.dart (mixin with private methods)
      todo_list_state.dart
    pages/
      todo_list_page.dart
      todo_list_page_handlers.dart (part file with handler functions)
    widgets/
      todo_list_item.dart (with swipe gesture support)
      todo_filter_bar.dart
      todo_empty_state.dart
      todo_stats_widget.dart (stats display)
      todo_search_field.dart (search input)
      todo_sort_bar.dart (sort selection with popup menu)
      todo_list_view.dart (optimized list view widget)
    helpers/
      todo_list_dialogs.dart (adaptive dialogs)
test/features/todo_list/
  data/
    hive_todo_repository_test.dart
  presentation/
    cubit/
      todo_list_cubit_test.dart
    widgets/
      todo_list_item_test.dart (swipe gesture tests)
```

## Critical Guardrails

### Compile-Time Safety

- ✅ **Always use** `context.cubit<T>()` instead of `context.read<T>()`
- ✅ **Always use** `context.selectState<C, S, T>()` for granular rebuilds
- ✅ **Always use** `TypeSafeBlocSelector`, `TypeSafeBlocBuilder`, `TypeSafeBlocConsumer`
- ❌ **Never use** `context.read()` or `BlocProvider.of()`

### Lifecycle Management

- ✅ **Always guard** async emits: `if (isClosed) return; emit(...)`
- ✅ **Always cancel** subscriptions/streams in `close()`
- ✅ **Always use** `CubitExceptionHandler` for async operations
- ✅ **Always use** `CubitSubscriptionMixin` for automatic subscription cleanup
- ✅ **Always implement** optimistic updates with state rollback for offline-first behavior
- ✅ **Always check** `isClosed` at the start of public methods
- ❌ **Never** perform side effects in `build()`
- ❌ **Never** emit after cubit is closed

### Architecture

- ✅ **Domain layer**: Pure Dart only (no `package:flutter` imports)
- ✅ **Data layer**: Implements domain contracts, maps DTOs to entities
- ✅ **Presentation layer**: Depends only on domain abstractions
- ❌ **Never** import data layer in presentation widgets
- ❌ **Never** call `Hive.openBox` directly (use `HiveRepositoryBase`)

### UI/UX

- ✅ **Always use** `Theme.of(context).colorScheme` for colors
- ✅ **Always use** `context.l10n.*` for strings (no hard-coded text)
- ✅ **Always use** `PlatformAdaptive.*` widgets (never raw Material buttons)
- ✅ **Always use** `showAdaptiveDialog()` (never raw Material dialogs)
- ✅ **Always use** responsive helpers: `context.pagePadding`, `context.responsiveGap`
- ✅ **Always implement** swipe gestures on mobile devices for better UX (iOS-style)
- ✅ **Always provide** `onDeleteWithoutConfirmation` callback for swipe-to-delete to avoid double dialogs
- ✅ **Always show** drag handle only when manual sorting is active
- ✅ **Always use** `ReorderableListView` for manual sort mode, `ListView.separated` for other modes
- ✅ **Always display** selected sort method next to sort button icon
- ❌ **Never** use `Colors.black`, `Colors.white`, etc.
- ❌ **Never** hard-code strings in widgets
- ❌ **Never** enable swipe gestures on desktop (use `context.isDesktop` check)
- ❌ **Never** show drag handle when manual sorting is not active

## Optional Enhancements

### Performance Optimizations

- ✅ **TodoStats widget** (implemented): Displays total, active, and completed counts using `TypeSafeBlocSelector`
- ✅ **RepaintBoundary** (implemented): Wraps each list item to prevent unnecessary repaints
- ✅ **Search debouncing** (implemented): 300ms debounce on search input to reduce unnecessary filtering operations while typing
- ✅ **ListView cache optimization** (implemented): `cacheExtent: 500` on all list views to improve scrolling performance
- ✅ **Filtered items optimization** (implemented): Early returns for empty lists to avoid unnecessary filtering/sorting operations
- ✅ **ListView.builder for large lists** (implemented): Automatically switches to `ListView.builder` when list has 100+ items for better performance
- Consider lazy loading if list grows beyond 1000 items (future enhancement)

### UX Enhancements

- ✅ **Swipe gesture support** (implemented):
  - Swipe right: Complete/uncomplete items
  - Swipe left: Delete items with confirmation
  - Native iOS-style swipe backgrounds with icons and labels
  - Mobile-only (disabled on desktop)
- ✅ **Undo snackbar** (implemented): Shows after delete actions with undo button using `ScaffoldMessenger`
- ✅ **Search functionality** (implemented): Real-time search by title and description with clear button
- ✅ **Sorting capabilities** (implemented):
  - Sort by date (newest/oldest first)
  - Sort by title (A-Z/Z-A)
  - Manual sort with drag-to-reorder
  - Sort button displays current selection
  - Sort order persists during session
- ✅ **Drag-to-reorder functionality** (implemented):
  - Enabled when manual sort mode is active
  - Uses `ReorderableListView` for smooth drag interactions
  - Drag handle icon (☰) visible only in manual mode
  - Manual order stored in state and preserved when adding new items

### Feature Enhancements

- ✅ **Due dates and priority levels** (implemented):
  - Due dates with date picker in add/edit dialogs
  - Priority levels (None, Low, Medium, High) with visual badges
  - Overdue items highlighted in red
  - Sort by priority (high to low, low to high)
  - Sort by due date (earliest first, latest first)
- ✅ **Batch actions** (implemented):
  - Select all items
  - Individual item selection checkboxes
  - Batch delete selected items
  - Batch complete/uncomplete selected items
  - Clear selection
  - Selection count display
- Add categories/tags
- Add export/import functionality

### Architecture Enhancements

- Consider deferred route loading if dependencies grow heavy
- Add offline sync if multi-device support is needed
- Add analytics tracking for user actions

## Related References

- `docs/clean_architecture.md`
- `docs/compile_time_safety.md`
- `docs/ui_ux_responsive_review.md`
- `docs/testing_overview.md`
- `docs/validation_scripts.md`
