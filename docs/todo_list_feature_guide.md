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
- Delete a todo.
- View list grouped or filtered by status (All, Active, Completed).
- Persist todos locally across app launches.

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
- Search and sorting.
- Batch actions (clear completed, select multiple).
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
  Future<void> upsert(TodoItem item);

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

- `cubit/todo_list_cubit.dart`
- `cubit/todo_list_state.dart` (Freezed)
- `pages/todo_list_page.dart`
- `widgets/` for list items, filters, empty state

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
    final String? errorMessage,
  }) = _TodoListState;

  const TodoListState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasItems => items.isNotEmpty;

  List<TodoItem> get filteredItems => switch (filter) {
    TodoFilter.all => items,
    TodoFilter.active => items.where((item) => !item.isCompleted).toList(),
    TodoFilter.completed => items.where((item) => item.isCompleted).toList(),
  };
}

enum TodoFilter { all, active, completed }
```

**Cubit Implementation Pattern:**

```dart
// lib/features/todo_list/presentation/cubit/todo_list_cubit.dart
class TodoListCubit extends Cubit<TodoListState> {
  TodoListCubit({
    required final TodoRepository repository,
  })  : _repository = repository,
        super(const TodoListState()) {
    _subscribeToRepository();
  }

  final TodoRepository _repository;
  StreamSubscription<List<TodoItem>>? _subscription;

  void _subscribeToRepository() {
    _subscription = _repository.watchAll().listen(
      (items) {
        if (isClosed) return;
        emit(state.copyWith(
          items: items,
          status: ViewStatus.success,
          errorMessage: null,
        ));
      },
      onError: (error, stackTrace) {
        CubitExceptionHandler.handleException(
          error,
          stackTrace,
          'TodoListCubit._subscribeToRepository',
          onError: (message) {
            if (isClosed) return;
            emit(state.copyWith(
              errorMessage: message,
              status: ViewStatus.error,
            ));
          },
        );
      },
    );
  }

  Future<void> loadTodos() async {
    if (isClosed) return;
    emit(state.copyWith(status: ViewStatus.loading));

    await CubitExceptionHandler.executeAsync<List<TodoItem>>(
      operation: () => _repository.fetchAll(),
      onSuccess: (items) {
        if (isClosed) return;
        emit(state.copyWith(
          items: items,
          status: ViewStatus.success,
          errorMessage: null,
        ));
      },
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(
          errorMessage: message,
          status: ViewStatus.error,
        ));
      },
      logContext: 'TodoListCubit.loadTodos',
    );
  }

  Future<void> addTodo({
    required final String title,
    final String? description,
  }) async {
    final todo = TodoItem.create(title: title, description: description);
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.upsert(todo),
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: message, status: ViewStatus.error));
      },
      logContext: 'TodoListCubit.addTodo',
    );
  }

  Future<void> toggleTodo(final String id) async {
    final todo = state.items.firstWhere((item) => item.id == id);
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.upsert(updated),
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: message, status: ViewStatus.error));
      },
      logContext: 'TodoListCubit.toggleTodo',
    );
  }

  Future<void> deleteTodo(final String id) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.delete(id),
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: message, status: ViewStatus.error));
      },
      logContext: 'TodoListCubit.deleteTodo',
    );
  }

  void setFilter(final TodoFilter filter) {
    if (isClosed) return;
    emit(state.copyWith(filter: filter));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

**Key Patterns:**

- Use `CubitExceptionHandler` for all async operations
- Guard all `emit()` calls with `if (isClosed) return;`
- Use `TypeSafeBlocSelector` for granular rebuilds
- Cancel subscriptions in `close()`

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
        init: (cubit) => cubit.loadTodos(),
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

- Create `TodoListCubit` with methods: `loadTodos()`, `addTodo()`, `toggleTodo()`, `deleteTodo()`, `setFilter()`, `clearCompleted()`
- Use `CubitExceptionHandler` for all async operations
- Guard all `emit()` calls with `if (isClosed) return;`
- Subscribe to repository stream in constructor
- Cancel subscription in `close()`

**Provider Setup:**

- Use `BlocProviderHelpers.withCubitAsyncInit<TodoListCubit, TodoListState>` for route-level initialization
- Pass repository via constructor injection

**UI Components:**

- Build page with list + filter controls + add/edit dialogs
- Use `TypeSafeBlocSelector` for list items to prevent unnecessary rebuilds
- Use `TypeSafeBlocBuilder` for full state rendering

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
- Test `loadTodos()` success and error cases
- Test `addTodo()`, `toggleTodo()`, `deleteTodo()` flows
- Test filter changes
- Test subscription cleanup

**Example Cubit Test:**

```dart
// test/features/todo_list/presentation/cubit/todo_list_cubit_test.dart
blocTest<TodoListCubit, TodoListState>(
  'loadTodos emits success with items',
  build: () {
    final repository = MockTodoRepository();
    when(() => repository.fetchAll()).thenAnswer((_) async => [todo1, todo2]);
    return TodoListCubit(repository: repository);
  },
  act: (cubit) => cubit.loadTodos(),
  expect: () => [
    const TodoListState(status: ViewStatus.loading),
    TodoListState(
      status: ViewStatus.success,
      items: [todo1, todo2],
    ),
  ],
);
```

**Widget Tests:**

- Test empty state rendering
- Test list rendering with items
- Test filter behavior
- Test add/edit dialogs
- Test error state display

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
      todo_list_cubit.dart
      todo_list_state.dart
    pages/
      todo_list_page.dart
    widgets/
      todo_list_item.dart
      todo_filter_bar.dart
      todo_empty_state.dart
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
- ❌ **Never** use `Colors.black`, `Colors.white`, etc.
- ❌ **Never** hard-code strings in widgets

## Optional Enhancements

### Performance Optimizations

- Add a `TodoStats` widget with completed/remaining counts using `TypeSafeBlocSelector`
- Add `RepaintBoundary` around list items if they become visually heavy
- Use `ListView.builder` for large lists (100+ items)
- Consider lazy loading if list grows beyond 1000 items

### UX Enhancements

- Add undo snackbar via `CommonStatusView` patterns
- Add swipe-to-delete gesture support
- Add drag-to-reorder functionality
- Add search and sorting capabilities

### Feature Enhancements

- Add due dates and priority levels
- Add categories/tags
- Add batch actions (select multiple, clear completed)
- Add export/import functionality

### Architecture Enhancements

- Consider deferred route loading if dependencies grow heavy
- Add offline sync if multi-device support is needed
- Add analytics tracking for user actions

## Related References

- `docs/clean_architecture.md`
- `docs/compile_time_safety_usage.md`
- `docs/ui_ux_responsive_review.md`
- `docs/testing_overview.md`
- `docs/validation_scripts.md`
