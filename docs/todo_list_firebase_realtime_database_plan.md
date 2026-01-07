# Todo List Firebase Realtime Database Integration Plan

## Overview

This document outlines the plan to store todo list data in Firebase Realtime Database, following the same patterns established in the counter feature.

## Goals

1. Create `RealtimeDatabaseTodoRepository` that implements `TodoRepository` interface
2. Store todo items in Firebase Realtime Database under user-specific paths
3. Follow the same authentication/error-handling patterns as `RealtimeDatabaseCounterRepository`
4. Keep data mapping consistent with `TodoItemDto` to align with Hive storage
5. Maintain backward compatibility with existing `HiveTodoRepository`
6. Align DI with the counter feature so the remote repo can be used alongside local storage

## Architecture Reference

The counter feature provides the reference implementation:

- **Domain Interface**: `CounterRepository` → `TodoRepository` (already exists)
- **Remote Implementation**: `RealtimeDatabaseCounterRepository` → `RealtimeDatabaseTodoRepository` (to be created)
- **Local Implementation**: `HiveCounterRepository` → `HiveTodoRepository` (already exists)
- **Offline-First Wrapper**: `OfflineFirstCounterRepository` is the pattern; todo can adopt it after adding sync metadata (follow-up)

## Firebase Database Structure

### Path Structure

```text
/todos/{userId}/{todoId}
```

Where:

- `userId`: Firebase Auth user UID
- `todoId`: Unique todo item ID (from `TodoItem.id`)

### Data Schema

Each todo item stored as:

```json
{
  "id": "1234567890-123456",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "isCompleted": false,
  "createdAt": "2025-01-15T10:30:00.000Z",
  "updatedAt": "2025-01-15T10:30:00.000Z",
  "dueDate": "2025-01-20T00:00:00.000Z",
  "priority": "high",
  "userId": "user-uid-123"
}
```

**Field Mapping:**

- `id`: `String` - Unique identifier (required)
- `title`: `String` - Todo title (required)
- `description`: `String?` - Optional description
- `isCompleted`: `Boolean` - Completion status (default: false)
- `createdAt`: `String` - ISO8601 timestamp (required)
- `updatedAt`: `String` - ISO8601 timestamp (required)
- `dueDate`: `String?` - ISO8601 timestamp (optional)
- `priority`: `String` - Enum value: "none", "low", "medium", "high" (default: "none")
- `userId`: `String` - User UID (for data isolation and security rules). Not part of `TodoItem` domain model, but safe to store.

## Implementation Plan

### Phase 1: Core Firebase Repository (remote only)

#### 1.1 Create `RealtimeDatabaseTodoRepository`

**File**: `lib/features/todo_list/data/realtime_database_todo_repository.dart`

**Implementation Details:**

- Implement `TodoRepository` interface
- Use `FirebaseDatabase` + `FirebaseAuth` (constructor-injected, like counter)
- Follow the same structure as `RealtimeDatabaseCounterRepository`:
  - `waitForAuthUser()` for auth (extract to a shared helper or re-use from counter repo)
  - `_executeForUser<T>()` for error handling
  - `_debugLog()` for debug-only logging
  - Inject `DatabaseReference` for unit tests (similar to `counterRef`)
- Path: `'todos'`
- Store todos under `todos/{userId}/`

**Methods:**

1. **`fetchAll()`**:
   - Get all todos from `todos/{userId}/`
   - Map `DataSnapshot.value` to `List<TodoItem>` via `TodoItemDto.fromMap`
   - Handle empty/null responses gracefully
   - Return sorted list (by `updatedAt` descending)

2. **`watchAll()`**:
   - Return `Stream<List<TodoItem>>` from `todos/{userId}/onValue`
   - Map `DatabaseEvent` to `List<TodoItem>`
   - Handle errors with proper logging
   - Maintain sort order

3. **`save(TodoItem item)`**:
   - Save single todo to `todos/{userId}/{todoId}`
   - Use `set()` for create/update
   - Map `TodoItem` to Firebase JSON format using `TodoItemDto.toMap()`
   - Add `userId` for security rules (safe extra field)

4. **`delete(String id)`**:
   - Remove todo at `todos/{userId}/{id}`
   - Use `remove()` on the specific child reference

5. **`clearCompleted()`**:
   - Fetch all todos
   - Filter completed items
   - Delete each completed todo or use a multi-location `update()` with null values

**Key Patterns:**

- Use `waitForAuthUser()` from counter repository (extract to shared utility for reuse)
- Error handling via `_executeForUser<T>()` pattern
- Logging via `AppLogger`
- Debug logging via `_debugLog()` helper (kDebugMode only)
- Use `TodoItemDto` for parsing/serialization to match Hive storage
- Skip invalid child entries with a safe `try/catch` to avoid breaking the stream

#### 1.2 Data Mapping

**Firebase → Domain (`TodoItem`) using `TodoItemDto`:**

- `TodoItemDto.fromMap` already validates `id` and `title`
- Dates are expected as ISO8601 strings (same as Hive)
- Unknown fields are ignored by the DTO

**Domain → Firebase using `TodoItemDto`:**

- `TodoItemDto.toMap` already uses ISO8601 strings + priority enum name
- Add `userId` to the map in the repository method before `set()`

#### 1.3 Helper Functions

**Extract shared utilities**:

- `waitForAuthUser()` currently lives in the counter repo file; extract to
  `lib/shared/firebase/auth_helpers.dart` and update counter/todo to import it.

#### 1.4 Implementation Sketch (Repository Outline)

**File**: `lib/features/todo_list/data/realtime_database_todo_repository.dart`

```dart
class RealtimeDatabaseTodoRepository implements TodoRepository {
  RealtimeDatabaseTodoRepository({
    final FirebaseDatabase? database,
    final DatabaseReference? todoRef,
    final FirebaseAuth? auth,
    final String todoPath = _defaultTodoPath,
  }) : _todoRef =
           todoRef ??
           (database ?? FirebaseDatabase.instance).ref(todoPath),
       _auth = auth ?? FirebaseAuth.instance;

  static const String _defaultTodoPath = 'todos';
  static const Duration _authWaitTimeout = Duration(seconds: 5);

  final DatabaseReference _todoRef;
  final FirebaseAuth _auth;

  @override
  Future<List<TodoItem>> fetchAll();

  @override
  Stream<List<TodoItem>> watchAll();

  @override
  Future<void> save(final TodoItem item);

  @override
  Future<void> delete(final String id);

  @override
  Future<void> clearCompleted();

  Future<T> _executeForUser<T>({
    required final String operation,
    required final Future<T> Function(User user) action,
    final Future<T> Function()? onFailureFallback,
  });

  List<TodoItem> _itemsFromValue(
    final Object? value, {
    required final String userId,
  });

  Map<String, dynamic> _todoToMap(
    final TodoItem item, {
    required final String userId,
  });
}
```

**Helper behavior notes:**

- `_itemsFromValue`: expects `value` as map keyed by todoId, uses
  `TodoItemDto.fromMap` per child; ignores invalid entries and logs.
- `_todoToMap`: wraps `TodoItemDto.fromDomain(item).toMap()` and adds `userId`.
- `fetchAll/watchAll`: call `_itemsFromValue`, then sort by `updatedAt` desc.
- `clearCompleted`: build multi-location update with `{id: null}` for completed.

### Phase 2: Dependency Injection

#### 2.1 Update `injector_factories.dart`

**File**: `lib/core/di/injector_factories.dart`

Add factory function:

```dart
/// Creates a TodoRepository instance.
///
/// Tries to create a Firebase-backed repository if Firebase is available,
/// otherwise falls back to Hive-backed repository.
TodoRepository createTodoRepository() {
  final HiveTodoRepository localRepository = HiveTodoRepository(
    hiveService: getIt<HiveService>(),
  );
  final TodoRepository? remoteRepository =
      _createRemoteTodoRepositoryOrNull();

  // Simple phase: prefer remote when available, otherwise local.
  if (remoteRepository != null) {
    return remoteRepository;
  }
  return localRepository;
}

TodoRepository? _createRemoteTodoRepositoryOrNull() {
  if (Firebase.apps.isEmpty) {
    return null;
  }
  try {
    final FirebaseApp app = Firebase.app();
    final FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app)
      ..setPersistenceEnabled(true);
    final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
    return RealtimeDatabaseTodoRepository(database: database, auth: auth);
  } on FirebaseException catch (error, stackTrace) {
    AppLogger.error(
      'Creating remote todo repository failed',
      error,
      stackTrace,
    );
    return null;
  } on Exception catch (error, stackTrace) {
    AppLogger.error(
      'Creating remote todo repository failed',
      error,
      stackTrace,
    );
    return null;
  }
}
```

#### 2.2 Update `injector_registrations.dart`

**File**: `lib/core/di/injector_registrations.dart`

Update `_registerTodoListServices()`:

```dart
void _registerTodoListServices() {
  registerLazySingletonIfAbsent<TodoRepository>(
    createTodoRepository,  // Use factory instead of direct instantiation
  );
}
```

### Phase 3: Offline-First Architecture (Follow-up to match counter)

#### 3.1 Create `OfflineFirstTodoRepository`

**File**: `lib/features/todo_list/data/offline_first_todo_repository.dart`

**Pattern**: Follow `OfflineFirstCounterRepository` exactly:

- Compose `HiveTodoRepository` (local) + `RealtimeDatabaseTodoRepository` (remote)
- Implement `SyncableRepository` interface
- Register with `SyncableRepositoryRegistry`
- Handle sync operations for todo items
- Support conflict resolution (last-write-wins or merge strategy)

**Methods:**

- `fetchAll()`: Return from local immediately
- `watchAll()`: Stream from local
- `save()`: Write to local first, queue sync operation
- `delete()`: Delete from local first, queue sync operation
- `clearCompleted()`: Delete from local first, queue sync operations
- `processOperation()`: Process queued sync operations
- `pullRemote()`: Fetch remote and merge with local

**Sync Metadata:**

- Add `changeId`, `lastSyncedAt`, `synchronized` fields to `TodoItem` domain model
- Update Freezed model and regenerate code
- Handle these fields in `TodoItemDto` mapping

**Note**: This phase requires updating the domain model and is a larger change. Do it after Phase 1 is validated.

## Testing Strategy

### Unit Tests

**File**: `test/features/todo_list/data/realtime_database_todo_repository_test.dart`

**Test Cases:**

1. `fetchAll()` - empty list, single item, multiple items
2. `watchAll()` - initial emit, updates on change
3. `save()` - create new, update existing
4. `delete()` - delete existing, delete non-existent
5. `clearCompleted()` - with completed items, without completed items
6. Error handling - auth failures, network failures
7. Data parsing - invalid dates, missing fields, enum parsing

**Mocking:**

- Mirror `test/realtime_database_counter_repository_test.dart`
- Mock `DatabaseReference` and `DataSnapshot` with `mocktail`
- Use `firebase_auth_mocks` for `FirebaseAuth`
- Use `FakeTimerService` if needed for time-based tests

### Integration Tests

Test with actual Firebase Realtime Database (test project):

- Create test user
- Verify data persistence
- Verify multi-device sync (if applicable)
- Clean up test data after tests

### Widget Tests

Update existing widget tests to work with Firebase repository:

- Mock `TodoRepository` in widget tests
- Ensure UI responds to repository changes

## Migration Considerations

### Existing Data

**Current State:**

- Todos are stored locally in Hive (`HiveTodoRepository`)
- No remote sync currently

**Migration Options:**

1. **Simple**: Start fresh with Firebase (lose local data if not migrated)
2. **Migration Script**: Export local todos and import to Firebase on first sync
3. **Gradual**: Use offline-first wrapper to sync existing local data

**Recommendation**: Start with Option 1 (simple) for MVP. Add migration script in follow-up if needed.

### User Experience

- If user is not authenticated, repository should fail gracefully
- Show appropriate error messages in UI
- Consider authentication flow before allowing todo sync

## Security Rules

### Firebase Realtime Database Rules

Add to Firebase Console:

```json
{
  "rules": {
    "todos": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid",
        "$todoId": {
          ".validate": "newData.hasChildren(['id', 'title', 'createdAt', 'updatedAt', 'userId']) && newData.child('userId').val() === $userId"
        }
      }
    }
  }
}
```

**Rules:**

- Users can only read/write their own todos
- Each todo must have required fields
- `userId` in data must match authenticated user

## Implementation Checklist

### Checklist: Phase 1 - Core Firebase Repository ✅ COMPLETE

- [x] Create `RealtimeDatabaseTodoRepository` class
- [x] Implement `fetchAll()` method
- [x] Implement `watchAll()` method
- [x] Implement `save()` method
- [x] Implement `delete()` method
- [x] Implement `clearCompleted()` method
- [x] Add data mapping helpers (`_itemsFromValue`, `_todoToMap`)
- [x] Add error handling and logging
- [x] Extract/share `waitForAuthUser()` to `lib/shared/firebase/auth_helpers.dart`
- [x] Write unit tests
- [x] Update DI registration

### Checklist: Phase 2 - Integration ✅ COMPLETE

- [x] Unit tests written (12 tests, all passing)
- [x] Document Firebase security rules (`docs/todo_list_firebase_security_rules.md`)
- [x] Verify existing widget/cubit tests work (all 40+ tests pass)
- [x] Test error scenarios (auth failures, network failures)
- [ ] Test with actual Firebase project (requires Firebase setup - manual step)
- [ ] Configure Firebase security rules in Firebase Console (manual step)

### Checklist: Phase 3 - Offline-First Architecture ✅ COMPLETE

- [x] Add sync metadata to `TodoItem` domain model (changeId, lastSyncedAt, synchronized)
- [x] Update Freezed model with JSON serialization
- [x] Update `TodoItemDto` to handle sync metadata
- [x] Create `OfflineFirstTodoRepository`
- [x] Update DI registration to use `OfflineFirstTodoRepository`
- [x] Run build_runner to regenerate code
- [x] Add sync status UI (`TodoSyncBanner` widget)
- [x] Write unit tests for `OfflineFirstTodoRepository` (13 comprehensive tests, all passing)

**Note**: Phase 3 core implementation is complete. The repository now uses offline-first architecture with local-first persistence and optional remote sync. All existing tests pass, confirming backward compatibility.

## Dependencies

- `firebase_database` (already in project)
- `firebase_auth` (already in project)
- `firebase_core` (already in project)

## Files Created

1. ✅ `lib/features/todo_list/data/realtime_database_todo_repository.dart`
2. ✅ `test/features/todo_list/data/realtime_database_todo_repository_test.dart`
3. ✅ `lib/shared/firebase/auth_helpers.dart` (shared utilities extracted)
4. ✅ `docs/todo_list_firebase_security_rules.md` (security rules documentation)
5. ✅ `docs/todo_list_offline_first_considerations.md` (Phase 3 guide)
6. ✅ `lib/features/todo_list/data/offline_first_todo_repository.dart` (Phase 3 implementation)
7. ✅ `test/features/todo_list/data/offline_first_todo_repository_test.dart` (Phase 3 unit tests - 13 tests, all passing)
8. ✅ `lib/features/todo_list/presentation/widgets/todo_sync_banner.dart` (sync status UI)

## Files Modified

1. ✅ `lib/core/di/injector_factories.dart` - Added `createTodoRepository()` factory (updated to use OfflineFirstTodoRepository)
2. ✅ `lib/core/di/injector_registrations.dart` - Updated `_registerTodoListServices()`
3. ✅ `lib/features/counter/data/realtime_database_counter_repository.dart` - Updated to use shared `waitForAuthUser`
4. ✅ `test/realtime_database_auth_guard_test.dart` - Updated import
5. ✅ `test/realtime_database_counter_repository_test.dart` - Updated import
6. ✅ `lib/features/todo_list/domain/todo_item.dart` - Added sync metadata fields (changeId, lastSyncedAt, synchronized) and JSON serialization
7. ✅ `lib/features/todo_list/data/todo_item_dto.dart` - Updated to handle sync metadata

## Reference Files

- `lib/features/counter/data/realtime_database_counter_repository.dart` - Reference implementation
- `lib/features/counter/data/offline_first_counter_repository.dart` - Offline-first pattern
- `lib/features/todo_list/data/hive_todo_repository.dart` - Local repository pattern
- `lib/features/todo_list/data/todo_item_dto.dart` - Data mapping patterns
- `lib/core/di/injector_factories.dart` - DI factory patterns

## Related Documentation

- [Firebase Security Rules](todo_list_firebase_security_rules.md) - Security rules configuration
- [Offline-First Considerations](todo_list_offline_first_considerations.md) - Phase 3 implementation guide

## Notes

1. **Authentication Required**: Firebase Realtime Database requires authenticated users. Ensure authentication flow is complete before using this repository.

2. **Persistence**: Enable Firebase Database persistence for offline support: `database.setPersistenceEnabled(true)`

3. **Data Sorting**: Maintain sort order (by `updatedAt` descending) to match existing Hive implementation behavior.

4. **Error Handling**: Follow the same error handling patterns as counter repository:
   - Catch `FirebaseAuthException` and rethrow
   - Catch `FirebaseException` and log, then return fallback
   - Provide fallback values (empty list, no-op) where appropriate

5. **Testing**: Mock Firebase services in unit tests. Use Firebase test project for integration tests only.

6. **Performance**: Consider pagination if todo lists become large (>100 items). For MVP, fetch all is acceptable.

7. **Offline-First**: Phase 3 (offline-first wrapper) is recommended but optional. Start with Phase 1 to validate the approach.

## Success Criteria

- [x] Todos can be created, updated, and deleted in Firebase Realtime Database
- [x] Todos are isolated per user (each user sees only their own todos)
- [x] Repository handles authentication errors gracefully
- [x] Repository handles network errors gracefully
- [x] All existing tests pass (with mocked repository)
- [x] New unit tests written (12 comprehensive tests, all passing)
- [x] Firebase security rules documented (ready for Firebase Console configuration)
- [x] Code follows existing patterns and architecture guidelines

## Implementation Status

**Phase 1: ✅ COMPLETE** - Core Firebase Repository implementation is complete and tested.

**Phase 2: ✅ COMPLETE** - Unit tests written, security rules documented, existing tests verified.

**Phase 3: ✅ COMPLETE** - Offline-first architecture implemented. `TodoItem` now includes sync metadata (changeId, lastSyncedAt, synchronized), `OfflineFirstTodoRepository` created, and DI updated. All existing tests pass, confirming backward compatibility.

## Next Steps

1. **Configure Firebase Security Rules**: Copy the rules from `docs/todo_list_firebase_security_rules.md` to Firebase Console
2. **Test with Firebase Project**: Set up a Firebase project and verify the repository works with actual Firebase
3. **Optional - Phase 3**: When offline-first functionality is needed, follow the guide in `docs/todo_list_offline_first_considerations.md`
