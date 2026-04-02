# Doctor Case Study Supabase Private Storage Plan

**Status:** Implemented — schema, edge delete-by-prefix, remote upload/history/playback, gating + badge shipped; verification complete.

## Current implementation status (as of 2026-04-02)

Already implemented:

- Supabase schema via MCP migration:
  - private bucket `case_study_videos`
  - table `public.case_studies` with `case_id text`, `remote_answers jsonb`,
    `status`, `submitted_at`, constraints + indexes
  - RLS enabled with owner-only CRUD policies
  - storage policies on `storage.objects` for `case_study_videos` scoped to
    `user/<auth.uid()>/...`
- Edge Function `delete-case-study` deployed (JWT verified):
  - derives `userId` from JWT
  - deletes all objects under `user/<userId>/case/<caseId>/` (paginated + batched)
  - deletes DB row for `(case_id, user_id)`
- App model split started (prevents breaking local playback):
  - `CaseStudyDraft.answers` remains **local file paths**
  - `CaseStudyDraft.remoteObjectKeysByQuestion` added for **remote object keys**
- Playback widget supports both local paths and signed URLs:
  - `CaseStudyVideoTile` now accepts `file://`-style local paths and `http/https`
    URLs (for signed playback)
- Remote delete is wired:
  - `CaseStudyRemoteDeleteRepository` + `SupabaseCaseStudyRemoteDeleteRepository`
  - `abandonCase()` calls remote delete best-effort after local cleanup
- `CaseStudySessionCubit` split into part files to satisfy file-length rules
  even after `dart format`.

Previously-next milestones (now implemented):

- Remote upload + finalize (`case_studies` upsert + `remote_answers`)
- Remote submitted-history list + detail (Supabase mode)
- Signed URL minting strategy for history playback (direct client signing per plan)
- Supabase gating UI (Supabase auth gate) + data source badge in Case Study pages

Verification:

- `./bin/router_feature_validate` ✅
- `./bin/checklist` ✅

This plan extends the existing dentist case-study demo so it can use Supabase
private storage and per-user records while preserving the current local-only
mode when Supabase is not configured.

Read first:

1. [`docs/case_studies/dentists.md`](../case_studies/dentists.md)
2. [`docs/case_studies/README.md`](../case_studies/README.md) (index of case study briefs)
3. [`docs/changes/2026-04-01_dentist_case_study_demo_plan.md`](2026-04-01_dentist_case_study_demo_plan.md)
4. [Repository `README` — Case studies](../../README.md#case-studies)
5. [`AGENTS.md`](../../AGENTS.md)

## What the source case study requires

- A dentist records answers to 10 predefined questions.
- Each answer is a separate video clip.
- Clips are uploaded together with doctor name, case type, and optional notes.
- The user can start a new case, view prior submitted cases, and access
  settings.

## Goals

1. Add Supabase-backed private storage and per-user records for the case-study
   feature.
2. Preserve current local-only behavior when Supabase is not configured.
3. Require Supabase sign-in only when Supabase is configured.
4. Keep delete semantics strict: deleting a case must remove DB state and every
   storage object under that case prefix.

## Terminology (keep consistent)

- **`case_id`**: the case study identifier (v1: `text`, matches existing `cs_<timestamp>`).
- **local clip path**: device file path used for in-progress playback.
- **remote object key**: Supabase Storage object key (never used as a local file path).
- **`remote_answers`**: json map `question_id -> remote object key` stored in Postgres.

## Non-goals for v1

- Cross-device remote draft resume.
- Background upload queues or resumable chunked uploads.
- Sharing clips between users.
- Real backend processing beyond storage, metadata persistence, signed playback,
  and delete-by-prefix.

## Critical corrections to the earlier draft

These points must shape implementation. Do not ignore them.

### 1. Do not overwrite local clip paths with remote object keys

Current code uses `CaseStudyDraft.answers` and `CaseStudyRecord.answers` as
video playback paths. Record/review/history pages currently pass those strings
directly into `CaseStudyVideoTile`. **Note:** `CaseStudyVideoTile` now supports
both local files and `http/https` URLs, but the in-progress flow still depends
on `answers` being local paths.

If an agent replaces `answers[qid]` with a Supabase object key too early:

- record/review playback breaks immediately
- history playback semantics become ambiguous
- local draft resume breaks

Required fix in the plan:

- Keep **local clip paths** separate from **remote object keys**
- Do not repurpose the existing `answers` map for both meanings

Recommended v1 shape:

- Local draft model keeps local clip paths in `CaseStudyDraft.answers`
- Remote metadata keeps remote object keys in `CaseStudyDraft.remoteObjectKeysByQuestion`
- Submitted remote history maps object keys to signed playback URLs on demand

If you want to avoid a wide domain refactor, add a new field for remote object
keys instead of mutating the meaning of `answers`.

### 2. Current case IDs are not UUIDs

The current case-study flow creates ids like `cs_<timestamp>`. The original
draft plan used `uuid` as the table PK without addressing the mismatch.

Pick one and document it explicitly:

- **Option A, recommended for least churn:** keep `case_id` as `text` and use
  the existing generated ids end-to-end
- **Option B:** migrate the app to generate UUIDs before any remote schema work

Do not leave the app using text ids while the DB expects UUIDs.

### 3. Draft rows and submitted rows do not fit the same current model cleanly

Current `CaseStudyRecord` requires:

- `submittedAt`
- `caseType`
- `doctorName`
- `answers`

Remote draft rows do not always have a meaningful `submittedAt`, and the app
should not treat drafts as history records.

Required rule:

- Keep remote draft and submitted-row mapping out of `CaseStudyRecord` unless
  the mapper can cleanly separate them
- Submitted history should map to `CaseStudyRecord`
- Remote draft rows should use a dedicated remote DTO or remote row mapper

### 4. Current history is local-only

The existing history pages read from the local repository, not from remote.
Adding Supabase storage alone does not make remote history work.

Required rule:

- Explicitly decide whether Supabase mode history is local-derived, remote-
  derived, or hybrid

Recommended v1:

- In local-only mode, history stays local as today
- In Supabase mode, history list/detail should read submitted rows from remote
- Signed playback URLs are minted on demand for remote history clips

### 5. Remote draft resume is expensive scope; keep it out of v1

Uploading clips during recording can be valuable for durability, but full
cross-device remote draft hydration adds substantial complexity:

- remote/local merge rules
- stale draft precedence
- auth change behavior
- cleanup for abandoned partially uploaded drafts

Recommended v1:

- Local draft remains the authoritative in-progress state
- Supabase draft rows are write-through backup / server bookkeeping only
- The app does not attempt to hydrate a remote draft onto a fresh device
- History shows submitted cases only

## Product and UX decisions

These decisions should be treated as fixed unless product explicitly changes
them.

### Supabase gating

1. If Supabase is not configured:
   - Case Study remains fully local-only
   - Do not redirect to Supabase auth
2. If Supabase is configured and user is signed out:
   - Redirect to `SupabaseAuthPage`
   - Return to the case-study route after sign-in using `redirect`
3. If Supabase is configured and user is signed in:
   - Enable remote upload, remote submitted-history fetch, signed playback, and
     remote deletion

### Data source badge

Add a badge patterned after chart data source UI:

- `Local only`
- `Supabase`

The badge should reflect current operating mode, not last request outcome.

### Upload semantics

To honor “uploaded together” without forcing a giant one-shot upload at the end:

- During recording in Supabase mode:
  - persist clip locally first
  - optionally upload that clip immediately
  - store remote object key separately if upload succeeds
- On final submit:
  - verify all 10 local clips exist
  - verify all 10 remote object keys exist, uploading any missing clips
  - upsert metadata and mark the row `submitted`

This preserves a single canonical submit gate.

### Delete semantics

- Abandon draft:
  - delete local files and local draft
  - if Supabase mode and a remote draft exists, call remote delete by `caseId`
- Delete submitted case from history:
  - delete remote row and all objects under the case prefix
  - remove any local cached representation if one exists

Delete-by-prefix must be idempotent.

## Model mapping (authoritative sources)

This is the simplest mapping that avoids breaking existing local playback:

- **Local draft (authoritative in-progress state)**:
  - metadata + local clip paths (current demo behavior)
  - persists to Hive; must remain usable offline
- **Remote row (`case_studies`)**:
  - `remote_answers` stores object keys only
  - `status` controls visibility:
    - `draft`: write-through bookkeeping only (do not show in history)
    - `submitted`: shown in remote history in Supabase mode
- **UI playback**:
  - in-progress record/review: local paths only
  - remote history/detail: signed URLs minted on demand from object keys

## Architecture fit

The repo already has the patterns needed for this work. Reuse them.

### Supabase configured check

Use:

- `SupabaseBootstrapService.isSupabaseInitialized`
- `ensureSupabaseConfigured()` from
  [`lib/core/supabase/edge_then_tables.dart`](../../lib/core/supabase/edge_then_tables.dart)

### Supabase auth-gated routing pattern

Reuse the IoT pattern instead of inventing a custom one:

- [`lib/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart`](../../lib/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart)
- existing `/supabase-auth?redirect=...` behavior in
  [`lib/features/supabase_auth/presentation/pages/supabase_auth_page.dart`](../../lib/features/supabase_auth/presentation/pages/supabase_auth_page.dart)

Recommended implementation:

- Create a `CaseStudySupabaseGate` patterned after `IotDemoAuthGate`
- Keep routing logic thin
- Route layer injects:
  - `isSupabaseInitialized`
  - `getCurrentUser`
  - `authStateChanges`
  - `supabaseAuthPath`
  - `redirectReturnPath`

### Data source badge pattern

Reuse chart badge structure:

- [`lib/features/chart/domain/chart_data_source.dart`](../../lib/features/chart/domain/chart_data_source.dart)
- [`lib/features/chart/presentation/widgets/chart_data_source_badge.dart`](../../lib/features/chart/presentation/widgets/chart_data_source_badge.dart)

Do not copy chart labels verbatim. Create a case-study specific enum and badge.

### DI pattern

Prefer the IoT demo style of “local-only when Supabase is absent, remote
enabled when configured”:

- [`lib/core/di/register_iot_demo_services.dart`](../../lib/core/di/register_iot_demo_services.dart)

For case study, keep the existing local services registered, then compose remote
services on top when Supabase is configured.

## Recommended v1 design

### Storage bucket

- Bucket name: `case_study_videos`
- Privacy: private
- Object key format:

`user/<user_id>/case/<case_id>/question/<question_id>/<clip_id>.mp4`

Prefix deletion then becomes:

`user/<user_id>/case/<case_id>/`

### Database table

Use a single `case_studies` table for remote metadata.

Recommended columns:

- `case_id text primary key`
- `user_id uuid not null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`
- `submitted_at timestamptz`
- `status text not null`
- `doctor_name text not null`
- `case_type text not null`
- `notes text not null default ''`
- `remote_answers jsonb not null default '{}'::jsonb`

Constraints:

- `status in ('draft', 'submitted')`
- `submitted_at is not null` when `status = 'submitted'`

Indexes:

- `(user_id, submitted_at desc)`
- `(user_id, created_at desc)`

### Domain and data modeling

Recommended minimum split:

- local draft stays local-first and uses local file paths
- remote metadata row stores object keys only
- submitted remote row maps to history/detail UI

Two acceptable implementation options:

1. Add remote-specific fields to current draft state
   - fastest path
   - increases coupling
2. Add dedicated remote DTO / mapper layer
   - cleaner
   - preferred if the refactor stays bounded

Do not expose Supabase SDK types in domain contracts.

## Execution order

Agents should implement in this order. Do not jump around.

### Step 1. Lock the model decisions

Before touching code or migrations, explicitly confirm in the plan:

- `case_id` stays `text` in v1
- local draft remains authoritative
- remote draft resume is out of scope
- local clip paths and remote object keys are separate

This avoids wasted work.

### Step 2. Add remote schema and policies

1. Create `case_study_videos` bucket
2. Create `case_studies` table
3. Add indexes and constraints
4. Enable RLS
5. Add storage policies scoped to `user/<auth.uid()>/...`

Policy intent:

- table select/insert/update/delete only for `user_id = auth.uid()`
- storage read/insert/delete only under `user/<auth.uid()>/...`

### Step 3. Add server-side delete

Implement `delete-case-study` edge function.

Responsibilities:

- derive `userId` from JWT
- compute case prefix
- list objects with pagination
- delete in batches
- delete DB row
- return stable result payload

Rules:

- idempotent on retry
- safe when row already missing
- safe when prefix already empty

### Step 4. Choose signed URL strategy

Default v1 choice (recommended): **direct client signing**.

- Use Supabase client APIs to create signed URLs while authenticated.
- Do not persist signed URLs anywhere; mint on demand.

When to add Edge signing (optional):

- Only if you need centralized control/auditing or want to hard-cap TTL server-side.

If you keep the Edge signing function:

- TTL max `86400`
- reject keys outside the caller’s namespace
- return 404 for missing objects

Do not add extra Edge functions unless they solve a real v1 requirement.

### Step 5. Add domain ports

Add ports under `lib/features/case_study_demo/domain/` for:

- remote metadata CRUD for submitted-history use
- clip upload
- signed playback URL creation
- remote delete by `caseId` (parameter name), deleting DB row with `case_id`

Keep contracts small and repo-native.

Recommended contracts:

- `CaseStudyRemoteRepository`
  - upload clip
  - upsert remote draft row
  - finalize submitted row
  - list submitted cases
  - get submitted case detail
  - create signed playback URL
- `CaseStudyRemoteDeleteRepository`
  - delete by case id

### Step 6. Add Supabase data implementations

Create Supabase-backed implementations under
`lib/features/case_study_demo/data/`.

Use repo patterns:

- `Supabase.instance.client.functions.invoke(...)` with bearer token headers
- stable `AppLogger.error(...)` tags
- map `PostgrestException` and generic failures to domain-level exceptions

### Step 7. Wire DI

Update:

- [`lib/core/di/register_case_study_demo_services.dart`](../../lib/core/di/register_case_study_demo_services.dart)

Rules:

- local services remain available always
- remote services activate only when Supabase is configured
- if using direct signed URLs, do not add an unnecessary Edge-signing wrapper

### Step 8. Add routing and gate behavior

Update case-study routes to:

- local-only mode when Supabase is absent
- redirect to `/supabase-auth?redirect=<case-study-path>` when configured but
  signed out
- allow flow when configured and signed in

Keep the route surface simple and covered by focused router tests.

### Step 9. Add the badge

Add a case-study data source enum and badge widget.

Badge state should be driven by mode:

- not configured -> local only
- configured and signed in -> Supabase

Do not overload it with transient network failure state in v1.

### Step 10. Integrate upload into the session flow

Current session flow is in:

- [`lib/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart`](../../lib/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart)

Required behavior in Supabase mode:

1. Persist picked clip locally first
2. Try upload for that question
3. On success, store the remote object key separately
4. Upsert remote draft metadata as best-effort
5. On submit:
   - verify all local clips still exist
   - upload any question still missing a remote object key
   - finalize remote metadata row as `submitted`

Rules:

- local progress must not be lost because remote upload failed
- failed per-question upload must be retryable
- submit must not mark remote row `submitted` until all 10 remote object keys
  are present

### Step 11. Integrate remote history and playback

In Supabase mode:

- history list comes from submitted remote rows
- detail comes from submitted remote row detail
- clip playback uses signed URLs minted on demand

In local-only mode:

- history remains current local behavior

If the app caches signed URLs:

- cache in memory only
- refresh on expiry or playback failure
- do not persist signed URLs to Hive or Postgres

### Step 12. Integrate delete flows

Add remote deletion where the user can:

- abandon an in-progress remote-backed draft
- delete a submitted remote-backed case from history

Required behavior:

- local cleanup still happens
- remote delete is attempted when Supabase mode is active and remote state may
  exist
- failures are surfaced clearly

Recommended v1 failure rule:

- do not pretend remote delete succeeded if it failed
- local draft may still be cleared, but the UI should surface that cloud cleanup
  failed and is retryable

## Edge cases and failure modes

These are the main traps agents are likely to miss.

### Auth and session

- Supabase configured but session expires mid-recording
  - further upload/sign/delete calls must fail cleanly
  - route or action path should redirect back to Supabase auth before next
    remote action
- Supabase user changes while case-study shell is mounted
  - do not upload or delete under the previous user namespace
  - rehydrate local session correctly and clear remote transient state

### Upload and local file handling

- local file copy succeeds but remote upload fails
  - keep local clip
  - allow retry
- user re-records a question
  - local old file is replaced as today
  - remote old object key must be superseded
  - best-effort immediate cleanup is optional
  - final prefix delete must remove both old and new objects eventually
- submit is pressed with one or more missing local files
  - fail submit with actionable UI
  - do not mark row submitted
- submit is pressed while an upload is already in flight
  - prevent duplicate finalize requests

### Remote metadata and schema

- remote draft row exists, but local draft was abandoned on device
  - v1 should not resurrect it automatically
- submitted row exists with malformed `remote_answers`
  - history/detail should fail gracefully, not crash
- DB row insert succeeds but one clip upload later fails
  - row remains `draft`
  - do not expose it in submitted history

### Signed playback

- signed URL expires while the user is on detail page
  - re-mint on playback failure
- object key missing or object deleted
  - show inline unavailable state
  - do not crash video playback widget

### Deletion

- delete function succeeds on DB row but partially fails on storage batch
  - function must be retryable
- delete is invoked for already-deleted case
  - return success
- very large prefix
  - list pagination and remove batching are required

### Validation and operational concerns

- current plan must not assume `flutter analyze` alone is enough
- docs-only change still needs repo docs validation

## Residual and uncompleted items

The feature is **shipped** for the demo scope above; the following gaps remain by
design, are intentionally deferred, or deserve a follow-up if this moves beyond
a case-study demo.

### Cross-cutting / product

- **Finalize remote success, local history save fails** — If
  `finalizeRemoteSubmission` succeeds but `saveRecords` / `clearDraft` / Hive
  persistence throws, the submitted case can exist in Supabase while the user
  sees a submit error and local history may not list it. Mitigations not
  implemented: retry local write with backoff, reconcile by pulling remote
  submitted list after error, or reorder operations (each has tradeoffs).
- **Surface failed cloud cleanup on abandon** — This plan’s edge-case text
  suggested optional user-visible “remote delete failed, retry” messaging.
  Current behavior: **best-effort** remote delete + `AppLogger` only.
- **Agent execution checklist** — The checkbox list at the end of this document
  is a historical scaffold; many items are done. Treat it as a traceability aid,
  not live TODO state (update or archive separately if that becomes confusing).

### Upload, progress, and media

- **Progress is step-based, not byte-based** — The UI reports fraction of
  completed steps (clips + upsert + finalize), not upload throughput; long clips
  can sit on one percentage for a while.
- **Very large video files** — `storage_client` `upload(File, …)` avoids an
  app-held `readAsBytes` of the whole file, but the client stack may still
  buffer aggressively depending on version; **resumable / chunked** uploads
  remain a **non-goal** for v1 (see Non-goals).
- **Re-record / supersede** — Replacing a gallery pick updates local paths and
  remote keys on submit; **orphan objects** from earlier uploads for the same
  question are not deleted until **case-level** delete (abandon / edge
  delete-by-prefix) or a future per-object cleanup policy.

### Client behavior and platform

- **`CaseStudyVideoTile` existence check** — Uses `compute` + top-level `existsSync` helper; `./bin/checklist` enforces no `Isolate.run` under `lib/**/presentation/**` via `tool/check_no_isolate_run_in_presentation.sh`.
  to keep slow filesystem checks off the UI isolate. Cost: one isolate spawn
  **per** local tile init; fine for a few clips, revisit if many tiles mount at
  once.
- **Signed URL expiry on detail** — Plan calls for re-mint on playback failure;
  verify end-to-end UX if a user leaves the detail page open past TTL (**may**
  be partially handled by re-navigation / reload; not fully audited here).

### Tests and manual verification

- Several **repository integration** and **two-user RLS** checks in this plan
  are still **manual / environment-dependent**; automated coverage is focused
  on cubit, gates, and codec behavior.
- **Codex / review** “nice-to-have” items that are **not** tracked as code debt
  here: exhaustive E2E on device with real Supabase project, load testing delete
  pagination, and full i18n review beyond badge + existing strings.

## Tests

Add focused tests. Keep them deterministic.

### Router and gate tests

- Supabase not configured -> case study stays local-only and does not redirect
- Supabase configured and signed out -> redirects to Supabase auth with safe
  return path
- successful auth return goes back to case-study route

### Repository tests

- upload returns object key and maps storage failures cleanly
- delete repository treats 2xx as success
- delete repository throws on non-2xx
- submitted-history fetch excludes `draft` rows
- signed playback URL method does not persist URL and respects TTL cap

### Session / cubit tests

- remote upload failure does not discard local draft progress
- submit uploads any remaining missing remote clips before finalizing
- submit does not finalize when a required local file is missing
- auth change during session does not leak prior user remote state

### UI tests

- badge shows `Local only` when Supabase is not configured
- badge shows `Supabase` when configured and signed in
- abandon/delete invokes remote delete once when appropriate
- playback unavailable state renders for missing/expired remote clip

### Manual Supabase verification

Per environment:

- two-user RLS verification for table access
- storage policy verification for read/delete outside namespace
- delete-by-prefix verification with more objects than one batch removes

## Validation

Implementation-phase validation:

- router/auth work -> `./bin/router_feature_validate`
- broader feature work -> targeted `flutter test` plus `./bin/checklist`

For this plan document change:

- `./bin/checklist`

## Agent execution checklist

- [ ] Confirm the four critical corrections at the top of this document before
      implementation
- [ ] Decide and document `case_id` type before writing migrations
- [ ] Add bucket, table, indexes, constraints, RLS, and storage policies
- [ ] Implement `delete-case-study`
- [ ] Choose direct-client or Edge-based signed URL generation
- [ ] Add domain ports and Supabase data implementations
- [ ] Wire DI without breaking local-only mode
- [ ] Add Supabase gate and return-to-route behavior
- [ ] Add case-study data mode badge
- [ ] Integrate remote upload/finalize into session flow without changing the
      meaning of local `answers`
- [ ] Add remote submitted-history fetch and signed playback
- [ ] Add remote delete to abandon/history delete paths
- [ ] Add focused tests
- [ ] Run repo validation

## Final recommendation

Keep v1 narrow:

- local draft stays authoritative
- remote draft is bookkeeping, not a second source of truth
- submitted history is the only remote list surfaced to users
- delete-by-prefix is the only required Edge function
- signing should stay as simple as the Supabase SDK and policy model allow

That path gives the team private per-user storage, recoverable uploads, and
remote submitted-history without forcing a much larger “cross-device remote
draft sync” project into the same change.
