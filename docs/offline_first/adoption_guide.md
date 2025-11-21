# Offline-First Adoption Guide

This guide describes how to onboard a feature into the shared offline-first stack used across the app.

## Prerequisites

- Feature has a clear domain model with JSON/Freezed serialization.
- Local storage is Hive-based via `HiveRepositoryBase` and `HiveService` (encryption by default).
- Remote repository is already DI-registered or can be injected.

## Step-by-Step

1. **Define local store**
   - Create a Hive-backed repository/data source under `lib/features/<feature>/data/` extending `HiveRepositoryBase`.
   - Add sync metadata fields (e.g., `changeId`, `lastSyncedAt`, `synchronized`) to the domain model and regen code with `dart run build_runner build --delete-conflicting-outputs`.
2. **Wrap with OfflineFirst repository**
   - Implement `<Feature>OfflineRepository` that composes the local + remote repos and implements `SyncableRepository`.
   - On `save`, write to Hive first, mark `synchronized: false`, generate `idempotencyKey`/`changeId`, and enqueue a `SyncOperation`.
   - When remote calls fail, enqueue the operation and throw/return a feature-specific “queued” signal (e.g., `ChatOfflineEnqueuedException`) so cubits can treat it as a pending success instead of an error.
   - On `processOperation`:
     - **Critical**: Persist user-generated data locally BEFORE attempting remote call to prevent data loss if sync fails.
     - Push to remote (if available) then mark local as synced.
     - If user data doesn't exist locally yet, create and persist it first, then attempt remote call.
   - On `pullRemote`, merge remote snapshots when newer.
3. **Register in DI + registry**
   - Wire the offline repo via `create<Feature>Repository` and register it in `SyncableRepositoryRegistry` within `lib/core/di/injector_registrations.dart`.
4. **Expose status to UI**
   - Consume `SyncStatusCubit` + `NetworkStatusService` to show offline/syncing/pending indicators and queued counts; add a dev-only inspector if helpful.
   - Use existing reference widgets such as `CounterSyncBanner` and `ChatSyncBanner` as patterns—they display offline/pending copy and expose manual “Sync now” actions wired to `SyncStatusCubit.flush()`.
5. **Tests**
   - Unit tests for local store serialization + migrations.
   - Repository tests for `save` queueing and `processOperation`/`pullRemote` paths.
   - Bloc/widget tests verifying UI reacts to `SyncStatusCubit` and queue counts.
6. **Docs + runbook**
   - Document box names/keys under `docs/offline_first/<feature>.md`.
   - Define and document the data retention policy for the feature's local cache (e.g., "prune synced items older than 90 days"). This is critical for managing storage.
   - Update `docs/offline_first/offline_first_plan.md` progress and run `./bin/checklist` before committing.

## Debugging tips

- Use the pending sync inspector (where available) to view queued operations.
- Inject fake timers and mock connectivity to deterministically test retry/backoff.
- Keep files under 250 LOC to satisfy `file_length_lint`.
