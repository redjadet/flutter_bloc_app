# Offline-First Implementation Plan

This document revalidates the offline-first requirements after another pass over the codebase and folds in the existing guardrails (Hive everywhere, DI through `getIt`, responsive widgets, and checklist-driven delivery). It is intentionally implementation-oriented so each workstream can be executed without re-triaging requirements.

## Progress Update (2025-11-24)

- ⚙️ **Immediate focus:** Observability polish (telemetry exports/history UI) and optional chat UX retries; core Remote Config and GraphQL offline-first work are complete.

- ✅ **Foundational services wired:** Added `ConnectivityNetworkStatusService`, `PendingSyncRepository`, and `BackgroundSyncCoordinator` with new DI registrations so every feature can subscribe to sync/connection state (see `lib/shared/services/network_status_service.dart` and `lib/shared/sync/*`).
- ✅ **Sync operation primitives:** Defined the `SyncOperation` Freezed model + Hive-backed storage, plus unit tests (`test/shared/sync/pending_sync_repository_test.dart`) ensuring queue behavior.
- ✅ **Coordinator hooks + status surface:** Introduced `SyncableRepository` + registry, taught `BackgroundSyncCoordinator` to pull/process operations per entity, autostarted it from `AppScope`, and added `SyncStatusCubit` so widgets can consume live network/sync state.
- ✅ **Counter UX wiring:** Counter page now shows `CounterSyncBanner` state (offline/syncing/pending) and dev-only sync inspector, backed by new l10n strings across locales.
- ✅ **Counter widget coverage:** Added widget/bottom-sheet tests (`test/features/counter/presentation/widgets/counter_sync_banner_test.dart`) to lock down banner states and inspector behavior.
- ✅ **Offline repo regression test:** Added `CounterCubit` unit coverage ensuring the offline-first repository queues operations when a remote backend is unavailable (`test/counter_cubit_test.dart`).
- ✅ **Offline repo integration tests:** Covered `processOperation`/`pullRemote` flows via `test/features/counter/data/offline_first_counter_repository_test.dart` and verified a coordinator flush path in `test/features/counter/data/background_sync_counter_flow_test.dart`.
- ✅ **Counter metadata tests:** Offline-first counter save now verified to generate changeId, mark unsynchronized, and enqueue pending ops when remote exists (`test/features/counter/data/offline_first_counter_repository_test.dart`).
- ✅ **Counter replay coverage:** `test/counter_cubit_test.dart` now asserts cubit state updates when the repository emits flushed snapshots.
- ✅ **Coordinator retry tests:** Added failure/backoff coverage in `test/shared/sync/background_sync_coordinator_test.dart`.
- ✅ **Coordinator test coverage:** Added unit tests for `ConnectivityNetworkStatusService` and `BackgroundSyncCoordinator` to lock down status emissions (`test/shared/services/network_status_service_test.dart`, `test/shared/sync/background_sync_coordinator_test.dart`).
- ✅ **Docs centralized:** Offline-first plan + adoption guide now live under `docs/offline_first/` for a single source of truth.
- ✅ **Chat adoption contract drafted:** Added `docs/offline_first/chat.md` outlining store/repo/queue/UI/testing steps for chat onboarding.
- ✅ **Chat local store wired:** Added Hive-backed `ChatLocalDataSource` with round-trip persistence tests and DI swap away from secure storage as the first step of chat onboarding.
- ✅ **Coordinator edge cases covered:** Added partial-batch failure, retry, and offline-event handling coverage in `test/shared/sync/background_sync_coordinator_test.dart`.
- ✅ **Chat metadata added:** `ChatConversation`/`ChatMessage` now carry sync fields (`changeId`, `lastSyncedAt`, `synchronized`, `clientMessageId`) to support pending-send queues.
- ✅ **Chat offline-first repo:** Added `OfflineFirstChatRepository` wired through DI, with pending-operation enqueue + processing tests and sync registry registration. **Improved**: `processOperation` now persists user messages locally before remote calls to prevent data loss during sync failures.
- ✅ **Counter sync stamp test:** Added regression test ensuring local-only counter saves set `lastSyncedAt`/`synchronized` for UI display.
- ✅ **Counter UI assertions:** Added banner widget coverage to validate sync messaging under different states, prep for rendering last-synced metadata.
- ✅ **Counter metadata surfaced:** Counter sync banner now shows last synced timestamp + changeId when available with l10n support and widget tests.
- ✅ **Chat sync banner:** Chat page now surfaces offline/sync status via `SyncStatusCubit` to prep for pending-send UX.
- ✅ **Counter goldens refreshed:** Updated counter page goldens with fake sync/network services so the new banner/metadata states stay stable without hitting platform plugins.
- ✅ **Chat data persistence improvement:** Enhanced `OfflineFirstChatRepository.processOperation` to persist user messages locally before remote calls, ensuring no data loss if sync fails. Added test coverage for this behavior.
- ✅ **Test harness hardened:** App and widget tests stub sync/network services to avoid background timers during coverage runs, keeping offline-first infra isolated in non-sync suites.
- ✅ **Chat pending-state UI:** Chat messages now surface pending/sync/offline status underneath user bubbles to reflect unsent messages even when offline.
- ✅ **Chat offline send flow:** `OfflineFirstChatRepository` now throws a dedicated `ChatOfflineEnqueuedException` when it queues messages, and `ChatCubit` treats that as success so pending messages no longer surface error states (see `test/chat_cubit_test.dart`).
- ✅ **Chat manual sync banner:** Added `ChatSyncBanner` with offline/pending messaging, pending counts, and a manual “Sync now” action wired to `BackgroundSyncCoordinator.flush()` so users can retry queued sends.
- ✅ **Chat flush regression tests:** `test/chat_cubit_test.dart` now covers the full offline-first pipeline, proving coordinator-driven flushes clear pending user messages and append the assistant reply.
- ✅ **Chat banner widget coverage:** `test/chat_page_test.dart` adds a widget test that wires `ChatSyncBanner` + pending pills to a manual flush flow, ensuring the UI clears pending labels/counts after replay.
- ✅ **Counter page metadata widget test:** `test/features/counter/presentation/pages/counter_page_sync_metadata_test.dart` verifies the `CounterSyncBanner` renders the localized `counterLastSynced` + `counterChangeId` copy when metadata exists.
- ✅ **Coordinator edge-case suite expanded:** `test/shared/sync/background_sync_coordinator_test.dart` now exercises orphaned operations, retry-on-next-flush behavior, and connectivity flapping mid-flush to keep regression coverage high.
- ✅ **Search offline-first implementation:** Added `SearchCacheRepository` (Hive) for caching search results, `OfflineFirstSearchRepository` implementing `SyncableRepository`, `SearchSyncBanner` widget, and full DI wiring. Search now serves cached results when offline and refreshes in background when online. Documented in `docs/offline_first/search.md`.
- ✅ **Search test coverage complete:** Added comprehensive unit tests for `SearchCacheRepository` (`test/features/search/data/search_cache_repository_test.dart`), repository tests for `OfflineFirstSearchRepository` (`test/features/search/data/offline_first_search_repository_test.dart`), and widget tests for `SearchSyncBanner` and search page integration (`test/features/search/presentation/widgets/search_sync_banner_test.dart`, `test/features/search/presentation/pages/search_page_test.dart`). All tests passing.
- ✅ **Sync status seeding hardened:** `SyncStatusCubit` now seeds its initial network status via `getCurrentStatus()` and guards emits after close, ensuring stream events are consumed even when emitted post-build. Re-enabled `SearchSyncBanner` widget tests that cover status changes after widget build.
- ✅ **Profile offline-first foundation:** Added `ProfileCacheRepository` (Hive) and `OfflineFirstProfileRepository` (Syncable, read-only) with DI wiring through `getIt`, leveraging `NetworkStatusService` to serve cached data offline and refresh when online. Documented in `docs/offline_first/profile.md` with cache + repository tests.
- ✅ **Profile sync surface:** Added `ProfileSyncBanner` widget and integrated it into `ProfilePage` so offline/syncing states surface via `SyncStatusCubit`. Added widget and page tests to cover banner visibility in offline/online flows.
- ✅ **Profile manual refresh:** `ProfileSyncBanner` now exposes a “Sync now” action wired to `SyncStatusCubit.flush()`, enabling manual refresh even when coming back from offline.
- ✅ **Remote Config offline-first adoption:** Added `RemoteConfigCacheRepository` + `OfflineFirstRemoteConfigRepository`, wired DI to serve cached config values when offline, surfaced `SyncStatusCubit` inside `RemoteConfigDiagnosticsSection`, and documented contracts/tests under `docs/offline_first/remote_config.md`.
- ✅ **Remote Config metadata surfaced:** `RemoteConfigSnapshot` now tracks `dataSource` and `lastSyncedAt`, persisted via the cache repository; diagnostics display the source when loaded.
- ✅ **Profile cache controls:** Added a dev/QA-only `ProfileCacheControlsSection` to Settings so engineers can clear the cached profile snapshot, with new l10n strings and widget tests guarding the behavior (`test/features/settings/presentation/widgets/profile_cache_controls_section_test.dart`).
- ✅ **Remote Config cache reset:** Settings → Remote Config diagnostics now include a clear-cache control that wipes the Hive snapshot and refetches values via the offline-first repository; covered by widget + cubit tests.
- ✅ **Sync telemetry hooks:** BackgroundSyncCoordinator and Remote Config offline-first repo now emit lightweight telemetry events (durations, counts, sources) for future analytics/observability.
- ✅ **Sync diagnostics UI:** Added a dev-only Sync Diagnostics section in Settings that surfaces the latest sync cycle summary (duration, per-entity queue depth, pending counts) from `SyncStatusCubit`.
- ✅ **Sync runner refactor:** Extracted `runSyncCycle` + `SyncCycleSummary` into a dedicated runner to keep `BackgroundSyncCoordinator` lean and lints compliant while exposing summary streams for diagnostics.
- ✅ **Prune visibility:** Sync diagnostics now surface `prunedCount` per cycle so queue maintenance is transparent during QA.
- ✅ **Runner resilience tests:** Added unit tests for `runSyncCycle` covering empty queues, successful processing, and failure/backoff telemetry to lock down coordinator behavior.
- ✅ **Telemetry completeness:** Sync runner tests now assert telemetry includes pruned counts and per-entity pending metadata so diagnostics stay reliable.
- ✅ **GraphQL demo cache-first:** Added Hive cache + offline-first wrapper so countries/continents load offline and refresh cache on success; documented in `docs/offline_first/graphql_demo.md`.
- ✅ **GraphQL demo polish:** Staleness metadata (24h expiry) and cache clear control (`GraphqlCacheControlsSection` in Settings) are complete.
- ✅ **Counter documentation:** Added `docs/offline_first/counter.md` documenting offline-first counter implementation, storage plan, conflict resolution, UI integration, and testing coverage.

## Immediate Next Steps

1. **Remote Config telemetry + metrics** (Priority: Done)
   - ✅ Pipe Remote Config refresh metrics into `BackgroundSyncCoordinator` analytics hooks.
   - ✅ Evaluated staged rollouts/version pinning; current payload size + tracked keys are minimal, so no differential sync is needed. Revisit only if new config payloads grow or rollout gating is introduced.

2. **Chat UX enhancements** (Priority: Medium)
   - Explore per-message "retry now" affordance (swipe/long-press) that re-enqueues a specific pending message without waiting for full coordinator batch.
   - Surface "last synced" metadata inline with conversation headers so users know when a thread last synced.
   - Add conversation-level pending count chips in history list.
   - Feed sync metrics/telemetry (queue depth, flush duration) into `ErrorNotificationService`/analytics for observability.

3. **Coordinator observability & pruning** (Priority: Medium)
   - ✅ Add diagnostics history: persist the last N `SyncCycleSummary` items and render them in the Sync Diagnostics dev UI.
   - ✅ Implement queue maintenance in `PendingSyncRepository` to clear obsolete operations via `prune()`; coordinator now triggers pruning after each sync cycle.
   - Hook into pruning policies (see §3.7) to keep boxes trimmed automatically.
   - Add periodic data pruning for local caches (e.g., chat history older than 90 days, search queries older than 30 days).

4. **GraphQL demo offline-first** (Priority: Done)
   - ✅ Cache countries/continents data locally for offline access.
   - ✅ Follow Search pattern for read-only cache-first approach.
   - ✅ Document contracts under `docs/offline_first/graphql_demo.md`.
   - ✅ Add staleness metadata (24h expiry) to avoid serving stale cache.
   - ✅ Add dev/QA cache clear control in Settings (`GraphqlCacheControlsSection`).

5. **Testing & quality improvements** (Priority: Low)
   - Expand integration tests for end-to-end offline scenarios across all features.
   - Add golden tests for sync banners in different states.
   - Improve test determinism with better `FakeTimerService` usage patterns.

## 1. Current State & Observations

- **Architecture:** Features follow the clean Domain → Data → Presentation split enforced through cubits/blocs (see `lib/features/**`) and DI via GetIt (`lib/core/di/injector_registrations.dart`). Storage primitives are centralized in `lib/shared/storage` with `HiveService` + `HiveRepositoryBase` handling encrypted boxes and error guards.
- **Local persistence today:** Core repositories persist data locally (`HiveCounterRepository`, `HiveLocaleRepository`, `HiveThemeRepository`, `ChatLocalDataSource`, `SearchCacheRepository`, `ProfileCacheRepository`, `GraphqlDemoCacheRepository`). Counter, Chat, Search, Profile, Remote Config, and GraphQL hydrate from disk before calling their APIs.
- **Conflict signals:** `CounterSnapshot` already tracks `lastChanged`; other domain models now carry sync metadata (e.g., chat, profile snapshots, remote config, graphql cache staleness) but still avoid heavy conflict UIs—future work could add per-entity resolution prompts where needed.
- **Background work:** Shared sync stack is in place (`BackgroundSyncCoordinator`, `NetworkStatusService`, `SyncStatusCubit`, `PendingSyncRepository`); remaining gaps are observability polish and optional UX niceties (per-message retries, cache clear UX where relevant).

## 2. Offline-First Goals

1. **Single Source of Truth**: The local database (Hive) is the single source of truth for the UI. The UI reads from and writes to local repositories, never directly to the network. The sync layer is responsible for keeping the local database synchronized with the remote backend.
2. **Deterministic local data persistence** for every feature that consumes remote sources so the app boots from Hive/secure storage without hitting the network.
3. **Explicit conflict resolution paths** so concurrent edits (same entity on server & device) converge predictably.
4. **Background synchronization** that monitors connectivity, periodically flushes pending operations, and replays missed remote updates while keeping cubits informed of sync status.
5. **Resilient UX & diagnostics**: surface queued work as “pending” instead of “failed,” add logging/metrics for permanent errors, and back every flow with deterministic unit/bloc/widget coverage.

## 3. Architecture Additions

### 3.1 Local data persistence layer

- **Introduce feature-specific local data sources**: For every remote repository, add a Hive-backed counterpart (e.g., `ChatLocalDataSource`, `ProfileLocalDataSource`, `GraphqlCountriesCache`, `SearchHistoryRepository`) that extends `HiveRepositoryBase` and follows the `StorageGuard` pattern established in `lib/features/counter/data/hive_counter_repository.dart`.
- **Schema planning**: Create one encrypted box per bounded context (`chat_conversations`, `chat_pending_messages`, `profile`, `remote_config_cache`, etc.) and document keys. Keep payloads serialized via existing domain models (Freezed/JSON) to avoid double maintenance and stay under the `file_length_lint` limit by breaking helpers into dedicated files when needed.
- **Migrations**: Update `SharedPreferencesMigrationService` (or add a dedicated `OfflineDataMigrationService`) to copy legacy SharedPreferences data into new boxes on upgrade and to seed defaults for fresh installs. Use `InitializationGuard.executeSafely` so failed migrations never brick startup.
- **DI wiring**: Register the new local data sources in `_registerStorageServices`/feature-specific sections, and expose them through repositories so cubits consume a single `OfflineFirst*Repository` instead of juggling multiple sources manually. Remember to register dispose callbacks for queue/controllers so `getIt.reset()` in tests remains deterministic.

### 3.2 Domain layer metadata & contracts

- **Augment domain models** with sync metadata: add `DateTime lastSyncedAt`, `int version`/`String etag`, a `bool synchronized` flag (per Flutter’s offline-first guidance), and optional `SyncStatus status` enums to entities like `ChatConversation`, `ChatMessage`, `CounterSnapshot`, and any list items that can be mutated offline.
- **Repository contracts** should expand beyond `load/save` to include `upsert`, `markPending`, `resolveConflict`, and `watchPendingOperations` as needed. Keep interfaces pure (no Flutter imports) so they remain testable, and define explicit “queued” semantics (e.g., feature-specific `*OfflineEnqueuedException`s) so cubits can distinguish between real failures and pending work.

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
  - Fetches pending operations from the `PendingSyncRepository` in batches to process them efficiently.
  - Uses `TimerService` to trigger periodic flushes (e.g., every 60s while online) and exponential-backoff retries for failed batches.
  - Streams `SyncStatus` updates (idle, syncing, degraded, error) to interested cubits/selectors so widgets can show inline indicators and stay responsive via `BlocSelector`.
- **Remote pull channel**: For features that support push (WebSocket, Firebase listeners, Firebase Cloud Messaging), persist incoming payloads immediately and mark them as synced so offline consumers read the same boxes. Combine push notifications (server-triggered sync) with the periodic background task so devices stay current without polling.
- **Safety rails**: Guard coordinator emits with `CubitExceptionHandler`, never call `emit()` after close, and ensure timers/streams are disposed via `TimerService` + repository `dispose()` callbacks when `getIt.reset()` runs in tests.

### 3.5 Presentation & UX updates

- **State modeling**: Extend shared `ViewStatus` usage with offline nuances (`ViewStatus.offline`, `ViewStatus.syncing`) or add derived getters on feature states to surface `hasPendingSync`, `lastSyncedAt`, etc.
- **Granular User Feedback**: The UI should provide feedback based on the nature of a sync issue.
  - **Transient Errors** (e.g., temporary network loss): The coordinator should handle these automatically with retries. The UI might show a subtle, temporary indicator (e.g., "Syncing paused...").
  - **Permanent Errors** (e.g., auth failure, invalid API key): The system should stop retrying and show a clear, actionable error message to the user (e.g., "Please log in again to sync your data.").
  - **Conflict Errors**: As defined in the conflict resolution strategy, these should surface prompts for the user to resolve the conflict.
- **User Actions**: Reuse `PlatformAdaptive` components to show toasts/banners when the device falls back to offline mode, display queued actions count, and offer manual "Sync now" actions that call the coordinator. `CounterSyncBanner`, `ChatSyncBanner`, and `SearchSyncBanner` are now the reference implementations (manual flush wired through `SyncStatusCubit.flush()` with pending counts where applicable).
- **Navigation guards**: Ensure pages that require fresh remote data (e.g., GraphQL demo) check `SyncStatus` before letting users perform destructive actions, falling back to cached data instead of blank screens.

### 3.6 Testing & diagnostics

- **Unit tests**: For every new local data source and queue repository, add tests under `test/shared/storage` or feature folders that cover serialization, migrations, and error paths using temporary Hive directories (pattern already used in `test/hive_counter_repository_test.dart`). Keep each file <250 LOC per lint.
- **Bloc tests**: Update cubit tests to simulate offline flows by injecting fake repositories/timer services. Ensure `ChatCubit`, `CounterCubit`, etc., emit the correct states when sync succeeds/fails, and assert pending-queue interactions.
- **Integration/golden**: Cover offline banners and queued indicators in widget + golden tests to catch regressions and keep responsive padding in sync with `shared/extensions/responsive.dart`.
- **Observability**: Add structured logs via `AppLogger`, emit analytics/sync metrics when online, and pipe severe sync failures through `ErrorNotificationService` for a consistent UX.
- **Chat validation coverage**: `test/chat_cubit_test.dart` (integration) and `test/chat_page_test.dart` (widget) now assert that `ChatOfflineEnqueuedException` paths keep the UI in a pending-success state and that coordinator/manual flush flows flip pending bubbles + banner counts to synced. Use these tests as the template for future features adopting the queue.
- **Search validation coverage**: `test/features/search/data/search_cache_repository_test.dart` covers cache serialization, eviction, and recent queries management. `test/features/search/data/offline_first_search_repository_test.dart` covers cache hit/miss scenarios, offline/online behavior, and `pullRemote` refresh. `test/features/search/presentation/widgets/search_sync_banner_test.dart` and `test/features/search/presentation/pages/search_page_test.dart` cover UI integration with sync status. Use these as reference patterns for cache-first read-only features.

### 3.7 Data Lifecycle and Pruning

- **Pruning Strategy**: To manage device storage and maintain performance, a data pruning strategy is essential. The `BackgroundSyncCoordinator` will be responsible for triggering a periodic compaction/pruning task.
- **Data Retention Policies**: Each feature adopting offline-first must define a retention policy. For example, chat messages older than 90 days that are confirmed as synced may be pruned from the local cache.
- **Queue Maintenance**: The `PendingSyncRepository` must include a mechanism to clear out completed (or obsolete) operations to prevent the queue from growing indefinitely.
- **User Controls**: For data-heavy features, consider exposing settings to allow users to control how much data is stored locally (e.g., "Sync 30 days of history").

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

## 5. Open Considerations & Future Enhancements

### Immediate Considerations

- **Remote API capabilities**: Hugging Face + Firebase endpoints must tolerate idempotent retries and ideally support batch processing to reduce network overhead. Confirm API limits and adjust queue batch sizes accordingly. If APIs lack etags, fall back to timestamp-based merges with caution.
- **Device storage limits**: Evaluate and define clear pruning policies for chat history and pending operations to avoid unbounded Hive growth. This could involve periodic, automated compaction tasks triggered by the `BackgroundSyncCoordinator`. Expose settings toggles if storage pressure becomes user-facing.
- **Data Pruning/Compaction Strategy**: Define a formal strategy for data lifecycle management. For example, automatically prune locally cached data (like messages) older than a specific period (e.g., 90 days) if it's confirmed to be synced on the server. The `PendingSyncRepository` should also have a mechanism to clear out long-completed operations to keep the queue size manageable.

### Future Enhancements

- **Background execution**: For long-running sync (esp. iOS/Android), consider integrating platform-specific background fetch/WorkManager after the initial in-app coordinator lands, honoring platform battery constraints.
- **Push notification contracts**: If we rely on Firebase Cloud Messaging to trigger sync, define payload schemas, authentication requirements, and fallbacks when push delivery fails. Document these contracts under `docs/`.
- **Differential sync**: Implement differential sync for large datasets (e.g., only sync changed fields, use etags/version numbers) to reduce network overhead and improve sync speed.
- **Conflict resolution UI**: Add user-facing conflict resolution dialogs for features that support concurrent edits (e.g., "Server has newer version, keep local or server?").
- **Sync scheduling**: Implement intelligent sync scheduling based on user behavior patterns (e.g., sync more frequently during active hours, less during idle periods).
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
| Search | `search_cache` box storing last results + queries | Cache-first strategy: serve cached results when offline, refresh in background when online. `pullRemote` refreshes top 10 recent queries. | `SearchSyncBanner` shows offline/syncing status. Search page works transparently with cached results. | ✅ Complete: `test/features/search/data/search_cache_repository_test.dart`, `test/features/search/data/offline_first_search_repository_test.dart`, `test/features/search/presentation/widgets/search_sync_banner_test.dart`, `test/features/search/presentation/pages/search_page_test.dart` |
| Profile | `profile_cache` storing `ProfileUser` + gallery assets metadata | Cache-first strategy (read-only): serve cached profile when offline, refresh in background when online. `pullRemote` refreshes cached profile. Future edits use optimistic update with merge-by-field version stamps. | `ProfileSyncBanner` surfaces offline/syncing states + manual sync CTA, and dev/QA builds expose a `ProfileCacheControlsSection` in Settings to clear cached data. | ✅ Cache/repo tests (`test/features/profile/data/profile_cache_repository_test.dart`, `test/features/profile/data/offline_first_profile_repository_test.dart`); banner/page widget tests + `test/features/settings/presentation/widgets/profile_cache_controls_section_test.dart` |
| Remote Config & Settings | `remote_config_cache` storing config values + version/checksum + metadata (`dataSource`, `lastSyncedAt`) | Cache-first strategy via `OfflineFirstRemoteConfigRepository`; serves cache offline, refreshes via sync registry when online. | `SettingsPage` diagnostics include sync banner + retry, and show data source/last synced when available. | ✅ Cache + repo tests (`test/features/remote_config/data/remote_config_cache_repository_test.dart`, `test/features/remote_config/data/offline_first_remote_config_repository_test.dart`); widget regression in `remote_config_diagnostics_section_test.dart` |
| Maps / Websocket demos | Cache map samples + recent locations per feature; queue pin updates | Use simple “last write wins” with timestamp; for WebSocket, persist inbound events for offline replay | Display offline overlay and disable streaming-only UI until sync catches up | Add fake repositories for widget tests, ensure `EchoWebsocketRepository` flushes persistent backlog |

Document per-feature decisions (box names, DTO contracts, sync strategies) under `docs/offline_first/<feature>.md` so future contributors follow the same conventions.
