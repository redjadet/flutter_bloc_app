# Plan: Supabase Auth Gate and Per-User Data for IoT Demo

## Goals

1. **Auth gate**: User must sign in with Supabase before accessing the IoT demo page. Unauthenticated users are redirected to the Supabase sign-in page.
2. **Per-user data**: Each user’s devices are stored and loaded separately. Users only see and modify their own data; no cross-user visibility.

## Current State

- **Auth**: App uses Firebase Auth for main flow; Supabase auth exists via `SupabaseAuthRepository` / `SupabaseAuthPage` (`/supabase-auth`). IoT demo route has no auth check.
- **Remote**: `iot_devices` table has no `user_id`; RLS allows anon read/write. All users share the same rows.
- **Local**: Single Hive box `iot_demo_devices`, key `devices`; not scoped by user.
  `PersistentIotDemoRepository` also seeds a shared default device list when
  storage is empty, which conflicts with remote-per-user ownership.
- **Sync**: Pending operations are global; no user filter. `runSyncCycle` and `getPendingOperations` have no user context.

## 1. Route: Require Supabase Sign-In for IoT Demo

### 1.1 Redirect when unauthenticated

- **Option A (recommended)**: Add a redirect in the router for the IoT demo route: when the user is not signed in with Supabase, redirect to `/supabase-auth` (or a dedicated “Sign in for IoT Demo” route that then goes to IoT demo after sign-in).
- **Option B**: Wrap the IoT demo route in a guard widget that checks `SupabaseAuthRepository.currentUser`; if null, show a full-screen “Sign in required” with a button to navigate to `/supabase-auth`.

**Implementation (Option A)**:

- In the split route file that owns the IoT demo route (currently
  `lib/app/router/routes_demos.dart`), do not render `IotDemoPage` directly.
  Instead, use a wrapper that:
  - Reads `SupabaseAuthRepository` (from DI or context).
  - If `!SupabaseBootstrapService.isSupabaseInitialized` → redirect to a safe route (e.g. counter) and optionally show a message (same as “Supabase not configured”).
  - If Supabase is initialized but `currentUser == null` → redirect to `AppRoutes.supabaseAuthPath` (e.g. with a query or extra so that after sign-in we can return to `/iot-demo`).
- **Return-to-IoT after sign-in**: On `SupabaseAuthPage` (or in the cubit), after successful sign-in, if the user was sent from IoT demo (e.g. `redirectAfterLogin == '/iot-demo'`), navigate to `/iot-demo` instead of a default route.

**Dependencies**: Router (or shell) must have access to `SupabaseAuthRepository`. Use the same injector as elsewhere (e.g. `getIt<SupabaseAuthRepository>()` in route builder).

### 1.2 Optional: Deep link

- If the user opens the app via deep link to `/iot-demo` and is not signed in, redirect to Supabase sign-in, then back to `/iot-demo` after success. The same redirect + return path logic applies.

---

## 2. Supabase: Per-User Table and RLS

### 2.1 Schema change

- Add column to `public.iot_devices`:
  - `user_id` (or `owner_id`) — `uuid`, references `auth.users(id)`, NOT NULL.
- Migrate existing rows (if any): assign to a single “legacy” user or delete; decide per product.
- Add index: `CREATE INDEX iot_devices_user_id_idx ON public.iot_devices(user_id);` (or equivalent) for fast per-user queries.

### 2.2 RLS policies

- **Enable RLS** on `iot_devices` (if not already).
- **SELECT**: Allow only where `user_id = auth.uid()`.
- **INSERT**: Allow only when `user_id = auth.uid()` (and enforce in app).
- **UPDATE / DELETE**: Allow only where `user_id = auth.uid()`.

So: each user can only see and modify their own rows. Use Supabase MCP or SQL migrations to apply.

### 2.3 Seed data

- Default/seed devices (if any) must be created **per user** after first sign-in (e.g. in app on first load for that user), not as shared rows. Alternatively, use a DB function/trigger to copy from a template table into `iot_devices` with `user_id = auth.uid()` on first access.

---

## 3. App: Remote Layer (Supabase Client)

### 3.1 Always use authenticated session

- Ensure Supabase client is used only when the user is signed in (redirect in step 1 guarantees this for the IoT demo page; other call sites should check or rely on the same gate).
- **SupabaseIotDemoRepository**:
  - `fetchDevices()`: Do **not** add an explicit `.eq('user_id', ...)` filter; RLS will restrict to `auth.uid()` automatically. Keep `.select().order('id')` (or equivalent).
  - `connect`, `disconnect`, `sendCommand`: No change to query shape; RLS ensures only the current user’s rows are updated.
  - If you ever insert new devices from the app, set `user_id` to the current user’s id (e.g. `Supabase.instance.client.auth.currentUser?.id`); optionally enforce in DB with a trigger.

### 3.2 No schema change in domain

- Domain model `IotDevice` does not need a `supabaseUserId` field for UI; it’s a backend/DB concern. Optional: add it for debugging or future use, but not required for this plan.

---

## 4. App: Local Layer (Per-User Storage)

### 4.1 User-scoped Hive box

- **Current**: One box `iot_demo_devices`, one key `devices`.
- **Target**: One box per user so that switching users does not show another user’s cached list.
  - Box name pattern: `iot_demo_devices_<supabaseUserId>` where `supabaseUserId` is the Supabase user id (stable string, e.g. UUID). Sanitize if needed (e.g. replace characters that are invalid in Hive box names).
- **PersistentIotDemoRepository**:
  - Becomes **user-dependent**: it must receive `supabaseUserId` (or a `String? Function() getCurrentSupabaseUserId`) so it can choose the box name. When `supabaseUserId` is null, either:
    - Use a temporary/guest box and not persist across sign-out, or
    - Do not allow access (caller should not open IoT demo without being signed in).
  - `boxName` is dynamic: `'iot_demo_devices_$supabaseUserId'` (with sanitization).
  - **Lifecycle**: When the user signs out, the app can close the box for that user; when another user signs in, open the box for the new user. No need to delete boxes on sign-out unless you want to free space (optional cleanup).

### 4.2 DI and repository creation

- **Current**: `PersistentIotDemoRepository` is a lazy singleton with a fixed box name.
- **Target**: IoT demo stack (local, offline-first) must be **per-user** or **user-aware**:
  - **Option A**: Factory that takes `supabaseUserId`: e.g. `getIt<IotDemoRepository>(param1: currentSupabaseUserId)`. So each time the IoT demo page is built, it resolves the repository with the current Supabase user id. The persistent repo (and optionally the offline-first repo) may be created per user and cached in a map keyed by `supabaseUserId`, or recreated each time.
  - **Option B**: Keep a single `OfflineFirstIotDemoRepository` but inject a **provider** of the current Supabase user id and a **factory** for `PersistentIotDemoRepository(supabaseUserId)`. The offline-first repo uses the provider to get `supabaseUserId`, gets or creates the persistent repo for that user, and delegates. Registry and pending sync stay global; only the local cache is per-user.

Recommendation: **Option B** to avoid changing the router’s `getIt<IotDemoRepository>()` signature. Use a small “IoT demo user context” that provides `String? get currentSupabaseUserId` (from `SupabaseAuthRepository.currentUser?.id`) and a factory for `PersistentIotDemoRepository(supabaseUserId)`. The offline-first repo (or a thin wrapper) uses this context so that local storage is always for the current user.

Why Option B fits this repo better:

- `OfflineFirstIotDemoRepository` currently self-registers with
  `SyncableRepositoryRegistry` on construction.
- Creating one repository instance per user would either register duplicates or
  require new unregister/dispose lifecycle support in the registry.
- A single user-aware offline-first repository keeps the registry stable while
  still switching local storage by current Supabase user.

### 4.3 Sign-out behavior

- On Supabase sign-out, clear or close the in-memory “current user” context so that the next time the user opens IoT demo they must sign in again (redirect in step 1). Any in-memory cache for the previous user’s devices should not be reused for a different user.

### 4.4 Remove shared local defaults

- `PersistentIotDemoRepository` currently writes a default/shared device list
  when the local box is empty or malformed. That behavior must change for
  per-user storage.
- Target behavior:
  - Empty box for a signed-in user returns an empty list until per-user seed
    data is created or `pullRemote()` fills the cache.
  - Recovery from malformed local data may still fallback safely, but it should
    not recreate shared demo devices that are unrelated to the signed-in user.
- If product still wants demo starter devices, seed them explicitly per user
  after authentication using the remote table or a controlled first-run flow.

---

## 5. Sync: Pending Operations and User Filtering

### 5.1 Problem

- Pending sync operations are stored in a single queue. If user A enqueues an operation and then user B signs in, we must not process A’s operation in B’s session (Supabase client would be B’s; RLS would prevent updating A’s rows, but the operation would still be “consumed” or mis-attributed if we don’t filter).
- So: only process pending operations that belong to the **current** Supabase user.

### 5.2 Store Supabase user id in payload for user-scoped entities

- For IoT demo, when enqueueing a `SyncOperation`, put the current Supabase user id in the payload, e.g. `payload['supabaseUserId'] = currentSupabaseUserId`. This marks the operation as belonging to that user.

### 5.3 Filter when reading pending operations

- **PendingSyncRepository.getPendingOperations**: Add an optional parameter,
  e.g. `supabaseUserIdFilter` (or `String? supabaseUserIdForUserScopedSync`).
  When provided, after building the list of ready operations:
  - non-user-scoped entities (counter/todo/chat/etc.) continue to work with no
    `supabaseUserId` in payload
  - user-scoped IoT demo operations are returned only when
    `payload['supabaseUserId'] == supabaseUserIdFilter`
  - legacy `iot_demo` operations with missing `supabaseUserId` are **not**
    processed; log and leave them for migration/cleanup instead of replaying
    them under the wrong user
- **runSyncCycle**: Add an optional parameter, e.g. `String? supabaseUserIdForUserScopedSync`. Pass it through to `getPendingOperations(supabaseUserIdFilter: supabaseUserIdForUserScopedSync)`.
- **BackgroundSyncCoordinator**: When calling `runSyncCycle`, pass the current Supabase user id (e.g. `getIt<SupabaseAuthRepository>().currentUser?.id`). So the coordinator (or runner) needs a dependency on `SupabaseAuthRepository` (or a callback `String? Function() getSyncSupabaseUserId`). Inject it in DI where the coordinator is created.

### 5.4 OfflineFirstIotDemoRepository

- When enqueueing connect/disconnect/sendCommand, set `payload['supabaseUserId'] = currentUser.id` (from `SupabaseAuthRepository.currentUser?.id`). If `currentUser` is null, do not enqueue (or treat as best-effort local-only; the plan assumes we never show IoT demo without sign-in, so this should not happen).
- **processOperation**: Before calling remote connect/disconnect/sendCommand, optionally check `payload['supabaseUserId'] == currentUser.id`; if not, skip and do not mark completed (so the op remains for when that user signs in again). This is a safety net; the main isolation is via filtering in `getPendingOperations`.
- If the repository becomes user-aware rather than per-user-instanced, also
  ensure any cached in-flight state (for example, a shared `pullRemote` future
  or current local repository handle) is invalidated when the active Supabase
  user changes.

---

## 6. Pull and First-Load

### 6.1 pullRemote

- **SupabaseIotDemoRepository.fetchDevices()**: No change; RLS returns only the current user’s rows.
- **OfflineFirstIotDemoRepository.pullRemote()**: Calls remote `fetchDevices()` then `local.replaceDevices(...)`. The “local” repository must be the one for the current user (see 4.2). So after pull, only that user’s devices are in the local box for that user.

### 6.2 First open

- User signs in → navigates to IoT demo page → page loads with current Supabase user id → local repo (user-scoped box) is used; if box is empty, first sync runs and pullRemote fills it with that user’s devices. No cross-user data.
- The page should not show the old hardcoded default device list before sync.
  Empty state or per-user seed is correct; shared defaults are not.

---

## 7. Summary Checklist

| Area | Action |
| --- | --- |
| **Route** | Redirect unauthenticated users from `/iot-demo` to Supabase sign-in; support return to `/iot-demo` after sign-in. |
| **Supabase** | Add `user_id` to `iot_devices`; RLS so each user sees/edits only own rows; index on `user_id`. |
| **Seed** | Per-user seed (app-side or DB trigger), not shared rows. |
| **Remote** | RLS only; no app-side filter by user. Optional: set `user_id` on insert. |
| **Local** | User-scoped Hive box: `iot_demo_devices_<supabaseUserId>`; persistent repo (or factory) takes/uses current Supabase user id. |
| **DI** | Provide current Supabase user id and user-scoped persistent repo to offline-first IoT repo. |
| **Pending sync** | Put `supabaseUserId` in payload for IoT ops; `getPendingOperations(supabaseUserIdFilter)`; runner/coordinator pass current Supabase user id. |
| **Sign-out** | No reuse of previous user’s cache; next access requires sign-in again. |

---

## 8. Testing and Validation

- **Auth gate**: Unit or widget test: when not signed in, navigating to IoT demo redirects to Supabase auth (or shows sign-in required). When signed in, IoT demo page is visible.
- **Per-user remote**: With two test users, create devices for each; assert each user only sees their own devices via API/RLS.
- **Per-user local**: Sign in as user A, load devices, sign out; sign in as user B; assert B’s list is empty or B’s devices, not A’s.
- **Empty local state**: For a newly signed-in user with no remote data, assert
  the page shows an empty/per-user-seeded state, not the old shared default
  devices.
- **Pending sync**: Enqueue as user A, sign out, sign in as B; run sync; assert A’s op is not processed (and remains in queue). Sign back in as A and run sync; assert A’s op is processed.
- **Legacy pending IoT ops**: Add a regression test for an `iot_demo`
  operation missing `supabaseUserId`; assert it is not replayed for another
  signed-in user.
- **Lifecycle**: After sign-out, ensure no access to previous user’s Hive box for new user.

---

## 9. Documentation Updates

- Update [`offline_first/iot_demo.md`](iot_demo.md): document auth requirement, per-user storage (box name pattern), and per-user RLS. Update “Implementation Status” when done.
- Optionally add a short “Supabase auth and IoT demo” section to the main offline-first or architecture docs.
