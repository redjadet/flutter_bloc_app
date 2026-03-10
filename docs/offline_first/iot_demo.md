# IoT Demo Offline-First Contract

This document defines how the IoT demo feature adopts the shared offline-first stack with Supabase as the remote source of truth.

## Goals

- **Auth gate**: When Supabase is configured, the user must sign in before accessing the IoT demo page (unauthenticated users are redirected to `/supabase-auth` with return path `/iot-demo`). When Supabase is not configured, the IoT demo page is shown in local-only mode (no remote sync or auth required).
- All device data comes from Supabase `iot_devices` table (per user via RLS); local Hive is the per-user cache and first read.
- Connect, disconnect, send-command, and add-device actions write to local first, then enqueue sync operations with `supabaseUserId`; when online, operations for the current user are applied to Supabase.
- UI always reads from local (instant); sync status is logged only. Sync diagnostics visible in Settings when dev/qa mode is active.
- First open triggers sync so devices are pulled from Supabase when online and local is populated for the signed-in user.

## Storage Plan

- **Local**: Per-user Hive box `iot_demo_devices_<sanitized(supabaseUserId)>`, key `devices` (list of `IotDevice` JSON). Empty storage returns an empty list (no shared defaults).
- **Remote**: Supabase table `public.iot_devices` with `user_id` (uuid, RLS); columns id, name, type, last_seen, connection_state (enum: disconnected | connecting | connected), toggled_on, value, updated_at. Apply migration in `docs/offline_first/supabase_iot_demo_user_id_migration.sql`.
- Encryption: use `HiveService`/`HiveRepositoryBase`; never open Hive boxes directly.
- Merge: last-write-wins by remote; `pullRemote` replaces the current user's local device list with fetched list from Supabase.

## Repository Wiring

- **PersistentIotDemoRepository**: Hive-backed local store per user; constructor takes `supabaseUserId`; box name `iot_demo_devices_<sanitized(supabaseUserId)>`; exposes `watchDevices`, `connect`, `disconnect`, `sendCommand`, `addDevice`, and `replaceDevices`.
- **SupabaseIotDemoRepository**: Remote implementation; RLS restricts to `auth.uid()`; no app-side user filter.
- **OfflineFirstIotDemoRepository**: Implements `IotDemoRepository` and `SyncableRepository`.
  - Takes `getCurrentSupabaseUserId` and `getPersistentRepository(supabaseUserId)`; caches persistent repo per user.
  - `entityType`: `iot_demo`
  - `watchDevices(filter)`: streams from the current user's local repo with filter applied locally. Empty stream when no user. Remote changes are pulled into local storage by background sync/realtime, so the UI still updates from the local stream.
  - `connect`/`disconnect`/`sendCommand`/`addDevice`: call local first, then enqueue `SyncOperation`; for add: payload includes full device (name, type, value); for command: kind/value.
  - `processOperation`: validates user match, then delegates to `applyIotDemoSyncOperation` in `iot_demo_sync_operation_applier.dart` for add/connect/disconnect/command. Legacy ops without `supabaseUserId` are skipped.
  - `pullRemote`: calls remote `fetchDevices()`, then current user's `local.replaceDevices(remoteDevices)`; in-flight coalesced.
- DI: `OfflineFirstIotDemoRepository` built with `getCurrentSupabaseUserId` from `SupabaseAuthRepository` and factory `(id) => PersistentIotDemoRepository(hiveService, supabaseUserId: id)`; `IotDemoRepository` resolves to it. `BackgroundSyncCoordinator` receives `getSyncSupabaseUserId` and passes current user to `runSyncCycle` for user-scoped pending op filter.

## Conflict Resolution

- Single source of truth: Supabase. On `pullRemote`, local list is replaced with the fetched list (no per-device `updated_at` merge in app; Supabase has `updated_at` for future use).
- Pending operations are applied in order; idempotency keys include deviceId, action, and timestamp.

## UI Integration

- FAB (+): opens add-device dialog (name, type, initial value for thermostat/sensor). On OK, device is added to local and Supabase (via sync). New device is auto-selected.
- Filter: `SegmentedButton` for All / On only / Off only (`IotDemoDeviceFilter`). The cubit keeps one unfiltered local stream and applies the selected filter in memory so the selected filter is preserved across local and remote updates.
- Sync runs in background when the page opens via `SyncStatusCubit.ensureStarted()`. Sync status is logged; no sync banner on the IoT demo page.
- For sync observability, use the Sync Diagnostics section in Settings (visible when dev/qa mode is active).
- Device list is always from local; updates after connect/disconnect/sendCommand are immediate (local), then synced in background.

## Data Retention

- Local device list persists until overwritten by `pullRemote` or user actions (connect/disconnect/sendCommand).
- No automatic eviction; Supabase table is the source of truth.

## Testing

- Unit/repository: `SupabaseIotDemoRepository` (with mocked Supabase or when not configured); `OfflineFirstIotDemoRepository` with fake local, fake remote, fake `PendingSyncRepository` and registry.
- Repository: watchDevices returns local stream; connect enqueues op; processOperation applies to remote; pullRemote fetches and merges.
- Widget: IoT demo page shows device list; sync runs in background with status in logs.

## Implementation Status

- Auth gate: When Supabase is not configured, the IoT demo page is shown (local-only mode). When Supabase is configured but the user is not signed in, redirect to `/supabase-auth?redirect=%2Fiot-demo`; `SupabaseAuthPage` supports `redirectAfterLogin` and navigates after sign-in.
- `PersistentIotDemoRepository`: per-user box, `supabaseUserId` required; empty storage returns empty list (no shared defaults).
- `OfflineFirstIotDemoRepository`: getCurrentSupabaseUserId + getPersistentRepository factory; payload includes `supabaseUserId`; processOperation skips legacy/different-user ops.
- Sync: `getPendingOperations(supabaseUserIdFilter)`, `runSyncCycle(supabaseUserIdForUserScopedSync)`; coordinator passes current Supabase user.
- Supabase: migration SQL in `docs/offline_first/supabase_iot_demo_user_id_migration.sql` (user_id, RLS, index).
- DI and sync registry wiring in `register_iot_demo_services.dart` and `injector_registrations.dart`.
- Sync runs in background; no sync banner on page. Sync diagnostics in Settings (dev/qa only).
- Device filters: All, On only, Off only (`lib/features/iot_demo/domain/iot_demo_device_filter.dart`). Filtering is applied in `IotDemoCubit` on top of the local stream so Supabase-triggered refreshes keep the current filter. Sync operation applier: `lib/features/iot_demo/data/iot_demo_sync_operation_applier.dart`.
