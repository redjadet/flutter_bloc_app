# Offline-First Implementation Plan

This document revalidates the offline-first requirements after another pass over the codebase and folds in the existing guardrails (Hive everywhere, DI through `getIt`, responsive widgets, and checklist-driven delivery). It is intentionally implementation-oriented so each workstream can be executed without re-triaging requirements.

## Progress Update (2025-11-19)

- ✅ **Foundational services wired:** Added `ConnectivityNetworkStatusService`, `PendingSyncRepository`, and `BackgroundSyncCoordinator` with new DI registrations so every feature can subscribe to sync/connection state (see `lib/shared/services/network_status_service.dart` and `lib/shared/sync/*`).
- ✅ **Sync operation primitives:** Defined the `SyncOperation` Freezed model + Hive-backed storage, plus unit tests (`test/shared/sync/pending_sync_repository_test.dart`) ensuring queue behavior.
- ✅ **Coordinator hooks + status surface:** Introduced `SyncableRepository` + registry, taught `BackgroundSyncCoordinator` to pull/process operations per entity, autostarted it from `AppScope`, and added `SyncStatusCubit` so widgets can consume live network/sync state.
- ✅ **Counter UX wiring:** Counter page now shows `CounterSyncBanner` state (offline/syncing/pending) and dev-only sync inspector, backed by new l10n strings across locales.
- ✅ **Counter widget coverage:** Added widget/bottom-sheet tests (`test/features/counter/presentation/widgets/counter_sync_banner_test.dart`) to lock down banner states and inspector behavior.
- ✅ **Offline repo regression test:** Added `CounterCubit` unit coverage ensuring the offline-first repository queues operations when a remote backend is unavailable (`test/counter_cubit_test.dart`).
- ✅ **Offline repo integration tests:** Covered `processOperation`/`pullRemote` flows via `test/features/counter/data/offline_first_counter_repository_test.dart` and verified a coordinator flush path in `test/features/counter/data/background_sync_counter_flow_test.dart`.
- ✅ **Counter replay coverage:** `test/counter_cubit_test.dart` now asserts cubit state updates when the repository emits flushed snapshots.
- ✅ **Coordinator retry tests:** Added failure/backoff coverage in `test/shared/sync/background_sync_coordinator_test.dart`.
- ✅ **Coordinator test coverage:** Added unit tests for `ConnectivityNetworkStatusService` and `BackgroundSyncCoordinator` to lock down status emissions (`test/shared/services/network_status_service_test.dart`, `test/shared/sync/background_sync_coordinator_test.dart`).
- ⚙️ **Immediate focus:** Cover counter replay/flush behavior, expand coordinator retry tests, and onboard the next feature into the sync registry.

## Immediate Next Steps

1. **Counter coverage**
   - Finalize metadata migration tests and add UI assertions that persisted `lastSyncedAt`/`changeId` surface correctly (queueing + coordinator flush are already covered by repo/cubit tests).
2. **Coordinator test coverage**
   - Expand coordinator tests to cover retry/backoff edge cases and network failure handling beyond the initial happy-path coverage now in place.
3. **Expand sync adoption**
   - Begin wiring the next feature (chat/search) into the sync registry following the matrix in §7, documenting contracts under `docs/offline_first/`.

## Recommendations / Next Improvements

### Code Quality & Architecture

- **Coordinator test isolation**: Ensure retry/backoff tests use deterministic time (e.g., `FakeTimerService`) to avoid flakiness. Consider injecting a clock abstraction for precise delay verification.
- **SyncableRepository interface evolution**: As more features adopt sync, consider adding optional hooks like `onSyncStart()`, `onSyncComplete()`, `onSyncError()` for feature-specific side effects (analytics, notifications).
- **Batch processing optimization**: When multiple operations queue for the same entity type, batch them into a single remote call where APIs support it (e.g., counter increments can be summed before syncing).
- **Memory management**: For large payloads (chat history, search results), implement pagination in local stores and eviction policies to prevent unbounded Hive growth. Consider `compute()` for heavy serialization work.

### Performance Optimizations

- **Debounced sync triggers**: Avoid triggering sync on every single mutation; batch operations within a short window (e.g., 2-5 seconds) before enqueueing.
- **Selective pull strategies**: Not all features need full remote pulls on every sync cycle. Add flags like `requiresFullPull` vs `incrementalSync` to reduce bandwidth.
- **Stream subscription management**: Ensure `watch()` streams in repositories properly cancel when cubits dispose, and use `BlocSelector` to minimize rebuilds when sync status changes.
- **Background sync throttling**: Respect platform battery constraints by reducing sync frequency when the device is in low-power mode or backgrounded.

### Testing Enhancements

- **Integration test coverage**: Add end-to-end tests that simulate full offline→online transitions with multiple queued operations across different entity types.
- **Golden test updates**: Update golden tests to include sync banners/indicators in various states (offline, syncing, degraded) to catch visual regressions.
- **Network simulation**: Create a test utility that simulates network failures, slow connections, and intermittent connectivity to validate retry/backoff behavior.
- **Coordinator edge cases**: Test scenarios like coordinator restart after app resume, concurrent sync attempts, and queue corruption recovery.

### Documentation & Developer Experience

- **Architecture decision records**: Document why we chose `SyncableRepository` over alternatives, retry strategies, and conflict resolution approaches in `docs/offline_first/decisions/`.
- **Feature adoption guide**: Create a step-by-step guide in `docs/offline_first/adoption_guide.md` showing how to wire a new feature into the sync system (local store → repository wrapper → registry → UI).
- **Debug tooling**: Extend the dev-only sync inspector to show operation history, retry counts, and failure reasons. Consider adding a "force sync" button for testing.
- **Migration runbook**: Document the process for migrating existing features (e.g., `SecureChatHistoryRepository` → `ChatLocalDataSource`) including data migration scripts and rollback procedures.

### Security & Privacy

- **Encryption key rotation**: Plan for Hive encryption key rotation without data loss, especially for sensitive features like chat. Document the migration path.
- **User data controls**: Add settings toggles allowing users to clear cached data, disable background sync, or view storage usage per feature.
- **Audit logging**: For sensitive operations (chat messages, profile edits), consider logging sync attempts to secure storage for compliance/debugging.

### Monitoring & Observability

- **Sync metrics**: Track metrics like `sync_operations_queued`, `sync_operations_completed`, `sync_operations_failed`, `sync_duration_ms` and expose them via analytics/Crashlytics.
- **Error categorization**: Classify sync failures (network timeout, auth error, conflict, server error) and surface actionable error messages to users.
- **Health checks**: Add periodic validation that local stores are consistent (e.g., checksums) and alert if corruption is detected.

### Edge Cases & Error Handling

- **Queue size limits**: Implement max queue size (e.g., 1000 operations) with eviction policies (FIFO or priority-based) to prevent storage exhaustion.
- **Operation dependencies**: For features with dependent operations (e.g., chat message → conversation), ensure operations sync in correct order or handle dependency failures gracefully.
- **Partial sync failures**: When a batch sync partially fails, ensure completed operations are marked as such and only failed ones are retried.
- **App lifecycle handling**: Test coordinator behavior during app backgrounding, termination, and resume to ensure sync state persists correctly.

### Migration & Rollout Strategy

- **Feature flags**: Use Remote Config to gradually roll out offline-first features, allowing rollback if issues arise.
- **Data migration safety**: For existing users, ensure migrations from SharedPreferences → Hive boxes are idempotent and can be re-run safely.
- **Backward compatibility**: Maintain compatibility with older app versions that don't support offline-first, especially for shared data (e.g., Firebase Realtime Database).

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
- **Schema planning**: Create one encrypted box per bounded context (`chat_conversations`, `chat_pending_messages`, `profile`, `remote_config_cache`, etc.) and document keys. Keep payloads serialized via existing domain models (Freezed/JSON) to avoid double maintenance and stay under the `file_length_lint` limit by breaking helpers into dedicated files when needed.
- **Migrations**: Update `SharedPreferencesMigrationService` (or add a dedicated `OfflineDataMigrationService`) to copy legacy SharedPreferences data into new boxes on upgrade and to seed defaults for fresh installs. Use `InitializationGuard.executeSafely` so failed migrations never brick startup.
- **DI wiring**: Register the new local data sources in `_registerStorageServices`/feature-specific sections, and expose them through repositories so cubits consume a single `OfflineFirst*Repository` instead of juggling multiple sources manually. Remember to register dispose callbacks for queue/controllers so `getIt.reset()` in tests remains deterministic.

### 3.2 Domain layer metadata & contracts

- **Augment domain models** with sync metadata: add `DateTime lastSyncedAt`, `int version`/`String etag`, a `bool synchronized` flag (per Flutter’s offline-first guidance), and optional `SyncStatus status` enums to entities like `ChatConversation`, `ChatMessage`, `CounterSnapshot`, and any list items that can be mutated offline.
- **Repository contracts** should expand beyond `load/save` to include `upsert`, `markPending`, `resolveConflict`, and `watchPendingOperations` as needed. Keep interfaces pure (no Flutter imports) so they remain testable.

### 3.3 Conflict resolution strategies

- **Counter**: Promote a multi-source strategy where local increments/decrements record a monotonic `lastChanged` and client-generated `changeId`. When syncing, compare timestamps and favor the highest `lastChanged`, but merge counts by replaying unapplied changeIds to avoid lost updates.
- **Chat**: Assign `clientMessageId` when composing a message. Persist drafts + pending sends locally, and when the HuggingFace response arrives, reconcile by matching IDs. If a remote reply arrives for a deleted conversation, keep it but mark conversation as `resurrected` so the UI can prompt the user.
- **List-based features (search, profile favorites, map pins)**: Use per-item hashes or incremental versions. During sync, compute diffs on the device and send batches; if the server returns conflicting changes, store both versions and surface resolution prompts via cubit state.
- **Error handling**: Wrap merges with `CubitExceptionHandler` and emit domain-specific failures (`CounterError.sync`, `ChatError.conflict`) so the UI can display inline banners.

### 3.4 Pending operation queue & sync orchestration

- **SyncOperation model**: Define a `SyncOperation` Freezed class (box-backed) capturing entity type, payload snapshot, dependencies, retry metadata (attempt count, `nextRetryAt`), and an idempotency token so remote APIs can drop duplicates.
- **Queue repository**: Build `PendingSyncRepository` on Hive to enqueue operations whenever the user mutates data while offline or when remote calls fail. Provide APIs to peek + lock batches for processing, and rely on `StorageGuard` + `HiveService` to guarantee encrypted storage.
- **Sync coordinator service**: Implement a `BackgroundSyncCoordinator` singleton that:
  - Observes connectivity via a new `NetworkStatusService` (wrapping `connectivity_plus` or platform channels) and app lifecycle events.
  - Uses `TimerService` to trigger periodic flushes (e.g., every 60s while online) and exponential-backoff retries for failed batches.
  - Streams `SyncStatus` updates (idle, syncing, degraded) to interested cubits/selectors so widgets can show inline indicators and stay responsive via `BlocSelector`.
- **Remote pull channel**: For features that support push (WebSocket, Firebase listeners, Firebase Cloud Messaging), persist incoming payloads immediately and mark them as synced so offline consumers read the same boxes. Combine push notifications (server-triggered sync) with the periodic background task so devices stay current without polling.
- **Safety rails**: Guard coordinator emits with `CubitExceptionHandler`, never call `emit()` after close, and ensure timers/streams are disposed via `TimerService` + repository `dispose()` callbacks when `getIt.reset()` runs in tests.

### 3.5 Presentation & UX updates

- **State modeling**: Extend shared `ViewStatus` usage with offline nuances (`ViewStatus.offline`, `ViewStatus.syncing`) or add derived getters on feature states to surface `hasPendingSync`, `lastSyncedAt`, etc.
- **User feedback**: Reuse `PlatformAdaptive` components to show toasts/banners when the device falls back to offline mode, display queued actions count, and offer manual "Sync now" actions that call the coordinator.
- **Navigation guards**: Ensure pages that require fresh remote data (e.g., GraphQL demo) check `SyncStatus` before letting users perform destructive actions, falling back to cached data instead of blank screens.

### 3.6 Testing & diagnostics

- **Unit tests**: For every new local data source and queue repository, add tests under `test/shared/storage` or feature folders that cover serialization, migrations, and error paths using temporary Hive directories (pattern already used in `test/hive_counter_repository_test.dart`). Keep each file <250 LOC per lint.
- **Bloc tests**: Update cubit tests to simulate offline flows by injecting fake repositories/timer services. Ensure `ChatCubit`, `CounterCubit`, etc., emit the correct states when sync succeeds/fails, and assert pending-queue interactions.
- **Integration/golden**: Cover offline banners and queued indicators in widget + golden tests to catch regressions and keep responsive padding in sync with `shared/extensions/responsive.dart`.
- **Observability**: Add structured logs via `AppLogger`, emit analytics/sync metrics when online, and pipe severe sync failures through `ErrorNotificationService` for a consistent UX.

## 4. Execution Roadmap

1. **Foundational services**
   - Add `NetworkStatusService` + `ConnectivityCubit` to track reachability (wrap `connectivity_plus` and expose derived `ConnectivityViewState` for widgets).
   - Create `PendingSyncRepository` + `SyncOperation` models and register them in DI, including dispose callbacks so tests can reset cleanly.
   - Implement `BackgroundSyncCoordinator` using `TimerService` and expose it via GetIt; start it from `AppScope` after `configureDependencies()` completes.
2. **Domain metadata updates**
   - Update Freezed models (`CounterSnapshot`, `ChatConversation`, `ChatMessage`, etc.) with sync fields + migrations.
   - Adjust JSON serialization + ensure `flutter pub run build_runner build --delete-conflicting-outputs` stays in sync; update `coverage/coverage_summary.md` after running `./bin/checklist`.
3. **Repository layering per feature**
   - Counter: Wrap remote + Hive repos into an `OfflineFirstCounterRepository` that always writes to Hive, mirrors to remote when online, and enqueues operations when offline.
   - Chat: Introduce `ChatLocalDataSource` (Hive) to replace `SecureChatHistoryRepository`, persist conversations/messages/pending sends, and reroute `ChatCubit` to hydrate from disk first.
   - GraphQL/Search/Profile (and other data reads): Cache latest payloads + user-generated changes in dedicated boxes and apply similar offline wrappers.
4. **Conflict resolution logic**
   - Implement merge strategies + helpers under each domain (`counter/domain/conflict_resolver.dart`, `chat/domain/message_merger.dart`), keeping heavy transforms off the UI thread via `compute()` when needed.
   - Unit test conflict scenarios and ensure cubits surface actionable errors through `ErrorNotificationService`.
5. **Background sync flows**
   - Wire coordinator to repositories via interfaces like `SyncableRepository` (methods: `pullRemote`, `pushPending`, `onRemoteEvent`).
   - Add app-wide listeners (e.g., in `AppScope` or a root widget) to start/stop sync based on lifecycle + permissions, and gate iOS background fetch hooks for future phases.
6. **Presentation updates**
   - Update feature cubits/states + widgets to show offline data, queued operations, and manual retry actions.
   - Add `BlocSelector`s for sync banners to avoid unnecessary rebuilds and ensure responsive spacing when banners appear.
7. **Testing + checklist**
   - Expand unit/bloc/widget coverage for new flows.
   - Update `./bin/checklist` expectations if new scripts/configs are needed, and document the offline-first architecture in `docs/` (e.g., `docs/offline_first.md`).

## 5. Open Considerations

- **Remote API capabilities**: Hugging Face + Firebase endpoints must tolerate idempotent retries; confirm API limits and adjust queue batch sizes accordingly. If APIs lack etags, fall back to timestamp-based merges with caution.
- **Device storage limits**: Evaluate pruning policies for chat history/pending ops to avoid unbounded Hive growth, and expose settings toggles if storage pressure becomes user-facing.
- **Background execution**: For long-running sync (esp. iOS/Android), consider integrating platform-specific background fetch/WorkManager after the initial in-app coordinator lands, honoring platform battery constraints.
- **Push notification contracts**: If we rely on Firebase Cloud Messaging to trigger sync, define payload schemas, authentication requirements, and fallbacks when push delivery fails. Document these contracts under `docs/`.
- **Security & privacy**: All local data stays encrypted via `HiveService` + `HiveKeyManager`. Review whether sensitive payloads (e.g., chat) require additional secure storage or user controls for clearing caches.
- **Operational readiness**: Extend runbooks so on-call engineers know how to inspect sync queues (e.g., via debug menu), clear corrupted boxes, or temporarily disable background sync without shipping a new build.

## 6. Reference Implementation Guides

- Flutter’s official offline-first guidance on synchronization flags and push-triggered sync informs the metadata and background task design: <https://docs.flutter.dev/app-architecture/design-patterns/offline-first>
- `README.md`, `docs/new_developer_guide.md`, and other repo docs stay canonical for guardrails (Hive usage, DI lifecycle, responsive UI expectations, checklist workflow).

## 7. Feature Adoption Matrix

| Feature | Local Store | Pending Ops / Conflict Strategy | Presentation updates | Tests & Tooling |
| --- | --- | --- | --- | --- |
| Counter | Reuse `counter` Hive box with new `changeId`, `lastSyncedAt` columns | Maintain FIFO queue of increments/decrements; replay unapplied changeIds when online | Show sync badge + queued count on counter page; reuse `PlatformAdaptive` banners | Extend `hive_counter_repository_test.dart`, add bloc tests for queued ops, update golden tests for new banner |
| Chat | New `chat_conversations`, `chat_pending_messages` boxes storing `ChatConversationDto` & message draft entity | Pending send queue with `clientMessageId`; detect conflicts by matching IDs + timestamps, mark `resurrected` when needed | Hydrate history instantly, show pending indicator per message, add manual “Sync now” CTA | Unit tests for persistence/helpers, bloc/widget tests for pending message UI, update `SecureChatHistoryRepository` coverage |
| Search | `search_cache` box storing last results + queries | Queue query mutations (e.g., saved filters) with last-applied version; prefer server wins but surface diff prompts | Indicate offline mode in Search page header, disable destructive actions when stale | Add repo tests for cache eviction, bloc tests for offline query replay |
| Profile | `profile_cache` storing `ProfileUser` + gallery assets metadata | Read-only today; future edits use optimistic update with merge-by-field version stamps | Add offline badge + “Last synced …” copy; ensure responsive layout obeys spacing tokens | Widget tests verifying offline badge renders, repo tests for JSON serialization |
| Remote Config & Settings | Extend existing Hive settings boxes with version + checksum, persist remote-config payloads | On conflict, prefer newest `lastFetched` but keep fallback value for rollback | `SettingsPage` shows sync status + retry button; `RemoteConfigCubit` exposes explicit offline/error states | Bloc tests covering retry flows, integration test verifying DI wiring |
| Maps / Websocket demos | Cache map samples + recent locations per feature; queue pin updates | Use simple “last write wins” with timestamp; for WebSocket, persist inbound events for offline replay | Display offline overlay and disable streaming-only UI until sync catches up | Add fake repositories for widget tests, ensure `EchoWebsocketRepository` flushes persistent backlog |

Document per-feature decisions (box names, DTO contracts, sync strategies) under `docs/offline_first/<feature>.md` so future contributors follow the same conventions.
