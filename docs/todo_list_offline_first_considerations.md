# Todo List Offline-First Architecture Considerations

This document outlines the considerations and requirements for implementing offline-first architecture for the todo list feature, following the pattern established by the counter feature.

## Overview

Phase 3 of the Firebase Realtime Database integration involves wrapping the repository with an offline-first layer that enables:

- Local-first data persistence (Hive)
- Background sync with Firebase
- Conflict resolution
- Sync status indicators in UI

## How the Offline-First Pattern Works

The todo list feature uses a **hybrid offline-first architecture** that combines:

1. **Primary Offline Support**: Hive-based local storage (our custom pattern)
2. **Secondary Offline Support**: Firebase Realtime Database persistence (Firebase's built-in cache)

### Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    User Action (Save/Delete)                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│         OfflineFirstTodoRepository                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Write to Hive immediately (no network needed)   │   │
│  │  2. Generate changeId & mark synchronized: false    │   │
│  │  3. Enqueue SyncOperation to PendingSyncRepository │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              BackgroundSyncCoordinator                       │
│  • Monitors network status                                  │
│  • Processes queued operations when online                  │
│  • Calls processOperation() on repository                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│     OfflineFirstTodoRepository.processOperation()            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Call RealtimeDatabaseTodoRepository (Firebase)  │   │
│  │  2. Firebase uses its own cache (setPersistenceEnabled)│
│  │  3. Update Hive with synchronized: true              │   │
│  │  4. Update lastSyncedAt timestamp                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

#### Write Operations (Save/Delete)

1. **Immediate Local Write**: User action writes to Hive immediately via `HiveTodoRepository`
   - No network required
   - UI updates instantly
   - Data is persisted locally

2. **Sync Operation Queueing**: Operation is enqueued to `PendingSyncRepository`
   - Generates `changeId` for idempotency
   - Marks item as `synchronized: false`
   - Stores operation payload (JSON)

3. **Background Sync**: `BackgroundSyncCoordinator` processes queue when online
   - Checks network status before sync
   - Calls `processOperation()` for each pending operation
   - Handles retries with exponential backoff

4. **Remote Sync**: `processOperation()` calls Firebase
   - Firebase operations benefit from Firebase's own persistence cache
   - Updates local Hive storage with sync status
   - Marks `synchronized: true` and sets `lastSyncedAt`

#### Read Operations (Fetch/Watch)

1. **Local-First**: All reads come from Hive immediately
   - `fetchAll()` returns cached data from Hive
   - `watchAll()` streams from Hive box
   - No network delay for UI

2. **Background Pull**: `pullRemote()` fetches from Firebase when online
   - Compares timestamps for conflict resolution
   - Merges newer remote data into local Hive storage
   - UI automatically updates via stream

### Benefits of Hybrid Approach

1. **Primary: Hive-Based Pattern**
   - ✅ Instant writes (no network delay)
   - ✅ Explicit sync control (we control when/how sync happens)
   - ✅ Conflict resolution (last-write-wins based on `updatedAt`)
   - ✅ Sync metadata tracking (`changeId`, `lastSyncedAt`, `synchronized`)
   - ✅ Operation queueing for offline scenarios

2. **Secondary: Firebase Persistence**
   - ✅ Additional resilience during Firebase operations
   - ✅ Automatic retry for Firebase network calls
   - ✅ Firebase's own offline cache as backup
   - ✅ Seamless integration with Firebase Realtime Database features

### Firebase Persistence Integration

Firebase Realtime Database persistence is enabled via `setPersistenceEnabled(true)` in the DI factory:

```dart
final FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app)
  ..setPersistenceEnabled(true);
```

This means:

- Firebase maintains its own local cache
- Firebase operations can work offline and sync automatically
- Our pattern controls **when** sync happens (via `BackgroundSyncCoordinator`)
- Firebase's cache provides resilience during sync operations

### Conflict Resolution

- **Strategy**: Last-write-wins based on `updatedAt` timestamp
- **Comparison**: Remote data is merged if `remoteItem.updatedAt.isAfter(localItem.updatedAt)`
- **Idempotency**: `changeId` ensures operations can be safely retried
- **Sync Metadata**: `synchronized` flag tracks sync status per item

### Sync Coordination

The `BackgroundSyncCoordinator` orchestrates synchronization:

- **Periodic Sync**: Runs every 60 seconds when online
- **Network-Aware**: Checks network status before sync
- **Retry Logic**: Exponential backoff for failed operations
- **Status Updates**: Emits sync status (idle, syncing, degraded, error)
- **Registry-Based**: Processes operations for all registered `SyncableRepository` instances

### Bidirectional Real-Time Synchronization

The implementation provides **bidirectional, real-time synchronization with automatic retry for failures**. This ensures that changes made on either side (Flutter app or Firebase Realtime Database) are immediately reflected on the other side when possible, or queued for retry when network conditions prevent immediate synchronization.

#### Flutter → Firebase (Immediate Sync with Retry)

When a user performs a save or delete operation:

1. **Immediate Local Write**: The operation is written to Hive immediately (no network required)
2. **Immediate Remote Sync Attempt**: The system attempts to sync to Firebase immediately if online
   - If successful: The local item is updated with `synchronized: true` and `lastSyncedAt` timestamp
   - If failed: The operation is enqueued in `PendingSyncRepository` for retry by `BackgroundSyncCoordinator`
3. **Automatic Retry**: Failed operations are automatically retried when network connectivity is restored

**Benefits**:

- ✅ Changes propagate to Firebase as quickly as possible when online
- ✅ No delay in synchronization when network is available
- ✅ Automatic fallback to queue-based retry when offline or network fails
- ✅ Operations never lost (queued for retry if immediate sync fails)

**Implementation Details**:

- `save()` method attempts immediate remote sync after local save
- `delete()` method attempts immediate remote delete after local delete
- Failed operations generate a `SyncOperation` with idempotency key (`changeId`)
- `BackgroundSyncCoordinator` processes queued operations with exponential backoff

#### Firebase → Flutter (Real-Time Listener)

The system actively listens to changes in Firebase Realtime Database:

1. **Real-Time Subscription**: `watchAll()` initiates a subscription to Firebase's `watchAll()` stream
2. **Automatic Merging**: When remote changes are detected, they are automatically merged into local Hive storage
3. **Conflict Resolution**: The `_shouldApplyRemote()` logic applies last-write-wins based on `updatedAt` timestamps
4. **UI Updates**: Merging into Hive triggers the local `watchAll()` stream, which automatically updates the UI

**Benefits**:

- ✅ Changes made on other devices or via Firebase console are immediately reflected
- ✅ Multi-device synchronization works seamlessly
- ✅ No polling required (uses Firebase's real-time capabilities)
- ✅ Conflict resolution ensures data consistency

**Implementation Details**:

- `_startRemoteWatch()` subscribes to `_remoteRepository.watchAll()`
- `_mergeRemoteIntoLocal()` processes incoming remote items and applies conflict resolution
- Only one subscription is active at a time (guarded by `_remoteWatchSubscription`)
- Errors are logged but don't break the subscription (error handling in stream listener)

#### Complete Synchronization Flow

```text
┌─────────────────────────────────────────────────────────────┐
│              Flutter App Changes (User Action)              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  1. Save to Hive (immediate)  │
         │  2. Attempt Firebase sync     │
         │     (immediate if online)     │
         └───────────┬───────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   [Success]                 [Failure]
        │                         │
        ▼                         ▼
┌───────────────┐      ┌──────────────────────┐
│ Mark synced   │      │ Queue for retry      │
│ Update UI     │      │ (BackgroundSync)     │
└───────────────┘      └──────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│         Firebase Realtime Database Changes                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  Firebase watchAll() stream   │
         │  emits change event           │
         └───────────┬───────────────────┘
                     │
                     ▼
         ┌───────────────────────────────┐
         │  _mergeRemoteIntoLocal()      │
         │  • Fetch current local items  │
         │  • Apply conflict resolution  │
         │  • Save to Hive               │
         └───────────┬───────────────────┘
                     │
                     ▼
         ┌───────────────────────────────┐
         │  Hive watchAll() stream       │
         │  emits updated items          │
         └───────────┬───────────────────┘
                     │
                     ▼
         ┌───────────────────────────────┐
         │  UI automatically updates     │
         │  (TodoListCubit receives      │
         │   updated stream events)      │
         └───────────────────────────────┘
```

#### Key Features

1. **Immediate Synchronization**: Changes attempt to sync immediately when online, minimizing delay
2. **Automatic Retry**: Failed operations are automatically queued and retried when network is available
3. **Real-Time Updates**: Firebase changes are received in real-time and automatically merged
4. **Conflict Resolution**: Last-write-wins strategy ensures data consistency across devices
5. **Resilient**: Operations never lost, even if network fails during sync
6. **Efficient**: No unnecessary polling; uses Firebase's real-time capabilities and local streams

## How Hive and Firebase Work Together

The todo list feature uses a **two-layer offline strategy** where Hive and Firebase persistence work together to provide robust offline support:

### Layer 1: Hive (Primary Offline Storage)

**Purpose**: Immediate local persistence and explicit sync control

**Characteristics**:

- **Instant Writes**: All user operations write to Hive immediately, no network required
- **Single Source of Truth**: Hive is the authoritative local database for the UI
- **Sync Metadata**: Tracks `changeId`, `lastSyncedAt`, and `synchronized` status per item
- **Operation Queueing**: Stores pending sync operations when offline
- **Conflict Resolution**: Manages last-write-wins logic based on `updatedAt` timestamps

**When It's Used**:

- Every user action (save, delete, clear completed)
- All read operations (UI always reads from Hive)
- Sync operation queuing when offline
- Conflict resolution during `pullRemote()`

### Layer 2: Firebase Persistence (Secondary Cache)

**Purpose**: Additional resilience during Firebase operations and automatic caching

**Characteristics**:

- **Automatic Caching**: Firebase maintains its own local cache via `setPersistenceEnabled(true)`
- **Network Resilience**: Firebase operations can work offline and queue automatically
- **Automatic Sync**: Firebase syncs its cache when connectivity returns
- **Transparent**: Works behind the scenes during `processOperation()` calls

**When It's Used**:

- During `processOperation()` when syncing to Firebase
- When `pullRemote()` fetches data from Firebase
- As a fallback cache if Firebase operations fail temporarily
- During Firebase's automatic sync when network returns

### How They Work Together

```text
┌─────────────────────────────────────────────────────────────┐
│                    User Action: Save Todo                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Hive (Immediate)                                   │
│  • Write to HiveTodoRepository instantly                    │
│  • Mark synchronized: false                                  │
│  • Generate changeId                                         │
│  • Enqueue SyncOperation                                     │
│  ✅ User sees update immediately, no network needed          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ (Background, when online)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  BackgroundSyncCoordinator                                    │
│  • Checks network status                                     │
│  • Processes queued SyncOperation                            │
│  • Calls processOperation()                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Firebase (Sync Time)                               │
│  • RealtimeDatabaseTodoRepository.save() called             │
│  • Firebase SDK uses its persistence cache                  │
│  • If offline: Firebase queues operation automatically      │
│  • If online: Firebase writes immediately                   │
│  • Firebase syncs its cache when network returns            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Hive (Update Sync Status)                          │
│  • Update synchronized: true                                 │
│  • Update lastSyncedAt timestamp                             │
│  • Keep changeId for idempotency                             │
│  ✅ Item now marked as synchronized                          │
└─────────────────────────────────────────────────────────────┘
```

### Key Interactions

#### 1. Write Operations

**Flow**:

1. **User saves todo** → Written to Hive immediately (Layer 1)
2. **Operation queued** → Stored in `PendingSyncRepository` (Layer 1)
3. **Background sync** → `BackgroundSyncCoordinator` processes queue
4. **Firebase call** → `RealtimeDatabaseTodoRepository.save()` uses Firebase persistence (Layer 2)
5. **Status update** → Hive updated with sync status (Layer 1)

**Benefits**:

- User gets instant feedback (Hive write)
- Operation survives app restart (queued in Hive)
- Firebase operations benefit from Firebase's cache (Layer 2)
- Sync status tracked in Hive (Layer 1)

#### 2. Read Operations

**Flow**:

1. **UI requests data** → Reads from Hive immediately (Layer 1)
2. **Background pull** → `pullRemote()` fetches from Firebase (Layer 2)
3. **Firebase cache** → Firebase uses its cache if available (Layer 2)
4. **Merge & update** → Conflict resolution, then update Hive (Layer 1)
5. **UI updates** → Stream emits updated data from Hive (Layer 1)

**Benefits**:

- Instant UI loading (Hive read)
- Background refresh (Firebase pull)
- Firebase cache speeds up Firebase operations (Layer 2)
- Single source of truth (Hive) for UI

#### 3. Offline Scenarios

**When Network is Offline**:

1. **User actions** → Written to Hive (Layer 1) ✅ Works
2. **Operations queued** → Stored in `PendingSyncRepository` (Layer 1) ✅ Works
3. **BackgroundSyncCoordinator** → Skips sync (network check) ⏸️ Waits
4. **Firebase operations** → Would use Firebase cache if called, but not called yet ⏸️ Waits

**When Network Returns**:

1. **BackgroundSyncCoordinator** → Detects network, starts processing ✅
2. **processOperation()** → Calls Firebase (Layer 2) ✅
3. **Firebase** → Uses its cache if available, syncs automatically ✅
4. **Hive update** → Marks items as synchronized (Layer 1) ✅

### Why Both Layers?

#### Hive (Layer 1) Provides

- ✅ **Explicit Control**: We control when/how sync happens
- ✅ **Sync Metadata**: Track sync status per item
- ✅ **Operation Queueing**: Reliable queue that survives restarts
- ✅ **Conflict Resolution**: Our logic determines which data wins
- ✅ **Instant UI**: All reads/writes are immediate
- ✅ **Single Source of Truth**: UI always reads from Hive

#### Firebase Persistence (Layer 2) Provides

- ✅ **Additional Resilience**: Firebase handles network failures during sync
- ✅ **Automatic Retry**: Firebase's built-in retry mechanisms
- ✅ **Cache Efficiency**: Firebase caches data for faster operations
- ✅ **Transparent Fallback**: Works automatically during Firebase calls
- ✅ **Firebase Features**: Leverages Firebase's offline capabilities

### Best of Both Worlds

The combination gives us:

1. **Immediate User Experience**: Hive ensures instant writes and reads
2. **Reliable Sync**: Our queue system ensures operations aren't lost
3. **Resilient Network Operations**: Firebase persistence handles network issues during sync
4. **Clear Sync Status**: We track sync state in Hive for UI display
5. **Conflict Resolution**: Our logic controls how conflicts are resolved
6. **Automatic Recovery**: Firebase cache helps during temporary network issues

This hybrid approach leverages the strengths of both systems while maintaining explicit control over sync timing and conflict resolution.

## Current State

- ✅ **Phase 1 Complete**: `RealtimeDatabaseTodoRepository` implemented
- ✅ **Phase 2 Complete**: Unit tests and security rules documented
- ✅ **Phase 3 Complete**: Offline-first wrapper implemented with sync metadata

## Prerequisites

Before implementing the offline-first wrapper, the following changes are required:

### 1. Domain Model Updates

Add sync metadata fields to `TodoItem` domain model:

```dart
@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required final String id,
    required final String title,
    // ... existing fields ...

    // New sync metadata fields:
    final String? changeId,
    final DateTime? lastSyncedAt,
    @Default(false) final bool synchronized,
  }) = _TodoItem;
}
```

**Impact**: This is a breaking change that requires:

- Regenerating Freezed code: `dart run build_runner build --delete-conflicting-outputs`
- Updating all existing code that creates `TodoItem` instances
- Updating `TodoItemDto` to handle sync metadata
- Potentially migrating existing Hive data

### 2. DTO Updates

Update `TodoItemDto` to include sync metadata:

```dart
class TodoItemDto {
  // ... existing fields ...

  final String? changeId;
  final DateTime? lastSyncedAt;
  final bool synchronized;

  // Update fromMap/toMap to handle sync fields
}
```

### 3. Repository Implementation

Create `OfflineFirstTodoRepository` following the pattern from `OfflineFirstCounterRepository`:

```dart
class OfflineFirstTodoRepository
    implements TodoRepository, SyncableRepository {
  OfflineFirstTodoRepository({
    required final HiveTodoRepository localRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    final TodoRepository? remoteRepository,
  });

  // Implement all TodoRepository methods
  // Implement SyncableRepository interface
  // Register with registry
}
```

## Implementation Steps

### Step 1: Update Domain Model

1. Add sync metadata fields to `lib/features/todo_list/domain/todo_item.dart`
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Update all `TodoItem.create()` calls (if needed, add sync metadata parameters)

### Step 2: Update DTO

1. Add sync metadata fields to `lib/features/todo_list/data/todo_item_dto.dart`
2. Update `fromMap()` and `toMap()` methods
3. Update `fromDomain()` and `toDomain()` methods

### Step 3: Update Hive Repository

1. Ensure `HiveTodoRepository` handles sync metadata fields
2. Verify data migration if needed (existing todos won't have sync metadata)

### Step 4: Create Offline-First Repository

1. Create `lib/features/todo_list/data/offline_first_todo_repository.dart`
2. Follow the pattern from `OfflineFirstCounterRepository`
3. Implement `SyncableRepository` interface
4. Handle sync operations for todos (create, update, delete)

### Step 5: Update Dependency Injection

1. Update `createTodoRepository()` in `injector_factories.dart` to use `OfflineFirstTodoRepository`
2. Wire local + remote repositories
3. Register with `SyncableRepositoryRegistry`

### Step 6: Add Sync Status UI

1. Create sync status banner component (similar to `CounterSyncBanner`)
2. Display sync status in todo list page
3. Show pending operations count
4. Display last synced timestamp

### Step 7: Testing

1. Unit tests for `OfflineFirstTodoRepository`
2. Test sync operations
3. Test conflict resolution
4. Test offline scenarios
5. Widget tests for sync status UI

## Key Considerations

### Conflict Resolution Strategy

- **Last-write-wins**: Use `updatedAt` timestamp to determine which version wins
- **Merge strategy**: For more complex scenarios, consider merging fields
- **User notification**: Inform users of conflicts (optional, depends on UX requirements)

### Sync Operations

Each todo operation needs to be tracked:

- **Create**: Generate `changeId`, mark `synchronized: false`, enqueue sync operation
- **Update**: Update `changeId`, mark `synchronized: false`, enqueue sync operation
- **Delete**: Mark for deletion, enqueue sync operation
- **Clear Completed**: Enqueue multiple delete operations

### Data Migration

When adding sync metadata to existing `TodoItem` instances:

- Existing todos in Hive will have `null` for sync metadata fields
- This is acceptable - they'll be synced on first sync operation
- Consider a migration script to mark all existing todos as synchronized (if they predate sync feature)

### Performance

- Batch sync operations when possible
- Use multi-location updates for `clearCompleted()`
- Consider pagination if todo lists become very large (>1000 items)

## Reference Implementation

The counter feature provides a complete reference implementation:

- **Domain Model**: `lib/features/counter/domain/counter_snapshot.dart`
- **Offline-First Repository**: `lib/features/counter/data/offline_first_counter_repository.dart`
- **Sync Status UI**: `lib/features/counter/presentation/widgets/counter_sync_banner.dart`
- **Documentation**: `docs/offline_first/counter.md`

## When to Implement

Phase 3 should be implemented when:

- ✅ Phase 1 and Phase 2 are complete and validated
- ✅ Offline functionality is a priority
- ✅ Multi-device sync is required
- ✅ There is time for domain model changes and testing

## Alternative: Defer Implementation

If offline-first is not immediately needed:

- Continue using `RealtimeDatabaseTodoRepository` directly
- Implement offline-first later when requirements change
- Domain model changes can be done incrementally

## Related Documentation

- [Todo List Firebase Realtime Database Plan](todo_list_firebase_realtime_database_plan.md)
- [Counter Offline-First Implementation](offline_first/counter.md)
- [Offline-First Adoption Guide](offline_first/adoption_guide.md)
- [Syncable Repository Pattern](offline_first/IMPLEMENTATION_COMPLETE.md)
