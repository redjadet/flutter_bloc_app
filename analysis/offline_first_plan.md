# Offline-First Implementation Plan

## 1. Current State & Observations

- **Architecture:** Features follow the clean Domain → Data → Presentation split enforced through cubits/blocs (see `lib/features/**`) and DI via GetIt (`lib/core/di/injector_registrations.dart`). Storage primitives are centralized in `lib/shared/storage` with `HiveService` + `HiveRepositoryBase` handling encrypted boxes and error guards.
- **Local persistence today:** Only a handful of repositories persist data locally (`HiveCounterRepository`, `HiveLocaleRepository`, `HiveThemeRepository`, `SecureChatHistoryRepository`). Most remote-driven features (chat, GraphQL demo, search, profile) do not hydrate from disk before calling their APIs.
- **Conflict signals:** `CounterSnapshot` already tracks `lastChanged`, but other domain models lack timestamps, versions, or sync flags, so the app cannot reconcile divergent local/remote states if the device was offline.
- **Background work:** We have `TimerService` abstractions and lifecycle hooks (e.g., counter auto-decrement) but no shared scheduler/coordinator dedicated to sync, no network reachability service, and no retry queues. Cubits rely on `CubitExceptionHandler`/`StorageGuard` but swallow offline errors rather than exposing dedicated view states.

## 2. Offline-First Goals

1. **Deterministic local data persistence** for every feature that consumes remote sources so the app boots from Hive/secure storage without hitting the network.
2. **Explicit conflict resolution paths** so concurrent edits (same entity on server & device) converge predictably.
3. **Background synchronization** that monitors connectivity, periodically flushes pending operations, and replays missed remote updates while keeping cubits informed of sync status.
4. **Test coverage & diagnostics**: each new store/sync path must have unit + bloc tests and logging/metrics to debug failures.

## 3. Architecture Additions

### 3.1 Local data persistence layer

- **Introduce feature-specific local data sources**: For every remote repository, add a Hive-backed counterpart (e.g., `ChatLocalDataSource`, `ProfileLocalDataSource`, `GraphqlCountriesCache`, `SearchHistoryRepository`) that extends `HiveRepositoryBase` and follows the `StorageGuard` pattern established in `lib/features/counter/data/hive_counter_repository.dart`.
- **Schema planning**: Create one encrypted box per bounded context (`chat_conversations`, `chat_pending_messages`, `profile`, `remote_config_cache`, etc.) and document keys. Keep payloads serialized via existing domain models (Freezed/JSON) to avoid double maintenance.
- **Migrations**: Update `SharedPreferencesMigrationService` (or add a dedicated `OfflineDataMigrationService`) to copy legacy SharedPreferences data into new boxes on upgrade and to seed defaults for fresh installs.
- **DI wiring**: Register the new local data sources in `_registerStorageServices`/feature-specific sections, and expose them through repositories so cubits consume a single `OfflineFirst*Repository` instead of juggling multiple sources manually.

### 3.2 Domain layer metadata & contracts

- **Augment domain models** with sync metadata: add `DateTime lastSyncedAt`, `int version`/`String etag`, and optional `SyncStatus status` enums to entities like `ChatConversation`, `ChatMessage`, `CounterSnapshot`, and any list items that can be mutated offline.
- **Repository contracts** should expand beyond `load/save` to include `upsert`, `markPending`, `resolveConflict`, and `watchPendingOperations` as needed. Keep interfaces pure (no Flutter imports) so they remain testable.

### 3.3 Conflict resolution strategies

- **Counter**: Promote a multi-source strategy where local increments/decrements record a monotonic `lastChanged` and client-generated `changeId`. When syncing, compare timestamps and favor the highest `lastChanged`, but merge counts by replaying unapplied changeIds to avoid lost updates.
- **Chat**: Assign `clientMessageId` when composing a message. Persist drafts + pending sends locally, and when the HuggingFace response arrives, reconcile by matching IDs. If a remote reply arrives for a deleted conversation, keep it but mark conversation as `resurrected` so the UI can prompt the user.
- **List-based features (search, profile favorites, map pins)**: Use per-item hashes or incremental versions. During sync, compute diffs on the device and send batches; if the server returns conflicting changes, store both versions and surface resolution prompts via cubit state.
- **Error handling**: Wrap merges with `CubitExceptionHandler` and emit domain-specific failures (`CounterError.sync`, `ChatError.conflict`) so the UI can display inline banners.

### 3.4 Pending operation queue & sync orchestration

- **SyncOperation model**: Define a `SyncOperation` Freezed class (box-backed) capturing entity type, payload snapshot, dependencies, and retry metadata (attempt count, nextRetryAt).
- **Queue repository**: Build `PendingSyncRepository` on Hive to enqueue operations whenever the user mutates data while offline or when remote calls fail. Provide APIs to peek + lock batches for processing.
- **Sync coordinator service**: Implement a `BackgroundSyncCoordinator` singleton that:
  - Observes connectivity via a new `NetworkStatusService` (wrapping `connectivity_plus` or platform channels) and app lifecycle events.
  - Uses `TimerService` to trigger periodic flushes (e.g., every 60s while online) and exponential-backoff retries for failed batches.
  - Streams `SyncStatus` updates (idle, syncing, degraded) to interested cubits/selectors so widgets can show inline indicators.
- **Remote pull channel**: For features that support push (WebSocket, Firebase listeners), persist incoming payloads immediately and mark them as synced so offline consumers read the same boxes.

### 3.5 Presentation & UX updates

- **State modeling**: Extend shared `ViewStatus` usage with offline nuances (`ViewStatus.offline`, `ViewStatus.syncing`) or add derived getters on feature states to surface `hasPendingSync`, `lastSyncedAt`, etc.
- **User feedback**: Reuse `PlatformAdaptive` components to show toasts/banners when the device falls back to offline mode, display queued actions count, and offer manual "Sync now" actions that call the coordinator.
- **Navigation guards**: Ensure pages that require fresh remote data (e.g., GraphQL demo) check `SyncStatus` before letting users perform destructive actions, falling back to cached data instead of blank screens.

### 3.6 Testing & diagnostics

- **Unit tests**: For every new local data source and queue repository, add tests under `test/shared/storage` or feature folders that cover serialization, migrations, and error paths using temporary Hive directories (pattern already used in `test/hive_counter_repository_test.dart`).
- **Bloc tests**: Update cubit tests to simulate offline flows by injecting fake repositories/timer services. Ensure `ChatCubit`, `CounterCubit`, etc., emit the correct states when sync succeeds/fails.
- **Integration/golden**: Cover offline banners and queued indicators in widget + golden tests to catch regressions.
- **Observability**: Add structured logs via `AppLogger` and consider simple metrics (counts) flushed to Crashlytics once online.

## 4. Execution Roadmap

1. **Foundational services**
   - Add `NetworkStatusService` + `ConnectivityCubit` to track reachability.
   - Create `PendingSyncRepository` + `SyncOperation` models and register them in DI.
   - Implement `BackgroundSyncCoordinator` using `TimerService` and expose it via GetIt.
2. **Domain metadata updates**
   - Update Freezed models (`CounterSnapshot`, `ChatConversation`, `ChatMessage`, etc.) with sync fields + migrations.
   - Adjust JSON serialization + ensure `flutter pub run build_runner build` stays in sync.
3. **Repository layering per feature**
   - Counter: Wrap remote + Hive repos into an `OfflineFirstCounterRepository` that always writes to Hive, mirrors to remote when online, and enqueues operations when offline.
   - Chat: Introduce `ChatLocalDataSource` (Hive) to replace `SecureChatHistoryRepository`, persist conversations/messages/pending sends, and reroute `ChatCubit` to hydrate from disk first.
   - GraphQL/Search/Profile: Cache latest payloads + user-generated changes in dedicated boxes and apply similar offline wrappers.
4. **Conflict resolution logic**
   - Implement merge strategies + helpers under each domain (`counter/domain/conflict_resolver.dart`, `chat/domain/message_merger.dart`).
   - Unit test conflict scenarios and ensure cubits surface actionable errors.
5. **Background sync flows**
   - Wire coordinator to repositories via interfaces like `SyncableRepository` (methods: `pullRemote`, `pushPending`).
   - Add app-wide listeners (e.g., in `AppScope` or a root widget) to start/stop sync based on lifecycle + permissions.
6. **Presentation updates**
   - Update feature cubits/states + widgets to show offline data, queued operations, and manual retry actions.
   - Add `BlocSelector`s for sync banners to avoid unnecessary rebuilds.
7. **Testing + checklist**
   - Expand unit/bloc/widget coverage for new flows.
   - Update `./bin/checklist` expectations if new scripts/configs are needed, and document the offline-first architecture in `docs/`.

## 5. Open Considerations

- **Remote API capabilities**: Hugging Face + Firebase endpoints must tolerate idempotent retries; confirm API limits and adjust queue batch sizes accordingly.
- **Device storage limits**: Evaluate pruning policies for chat history/pending ops to avoid unbounded Hive growth.
- **Background execution**: For long-running sync (esp. iOS/Android), consider integrating platform-specific background fetch/WorkManager after the initial in-app coordinator lands.
