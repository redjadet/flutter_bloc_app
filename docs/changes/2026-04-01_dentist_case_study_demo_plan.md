# Dentist case study demo — implementation plan (final)

**Status:** Implemented (automated verification done; manual device checklist optional)
**Canonical Cursor plan:** `~/.cursor/plans/dentist_case_study_demo_9c81a229.plan.md` (if present; keep aligned with this file)

This document is the **repo-tracked** copy for PRs and reviewers. Implementation defaults and checklist match the Cursor plan frontmatter todos.

**Related docs:** [Dentists product brief](../case_studies/dentists.md) · [Case studies index](../case_studies/README.md) · [Feature overview](../feature_overview.md) · [Supabase storage extension](2026-04-02_case_study_supabase_private_storage_plan.md)

## Tooling / execution note

- **Cursor Plan mode** only allows editing plan-style markdown. Implementing Dart, `pubspec.yaml`, plist, Android manifest, and generated l10n requires **Agent (normal) mode** or a human IDE session.
- Optional Cursor-local “execution gate” plans under `~/.cursor/plans/` are **hints only**; **this `docs/changes/` file is the team source of truth**.

## Build readiness checklist

- [x] [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md) updated with scope and verification
- [x] Implementation defaults reviewed (clip retention, logout scope, schema reset, `retrieveLostData`)
- [x] After `pubspec.yaml` / ARB changes: `flutter pub get` and your repo’s l10n codegen step if applicable
- [x] `./bin/router_feature_validate` after routes/auth/example
- [x] `flutter analyze` and targeted `flutter test` (via router_feature_validate batch)
- [x] Extend stable-route expectations in [test/core/router/app_routes_test.dart](../../test/core/router/app_routes_test.dart) when new `AppRoutes` constants ship
- [x] Extend policy tests in [test/app/router/app_route_auth_gate_test.dart](../../test/app/router/app_route_auth_gate_test.dart) for the new `AppRoutePolicies` entry
- [ ] Physical device smoke (iOS + Android)
- [ ] Manual pass: auth swap, abandon flow, retake, missing file on history, background app while video playing

## Implementation defaults (v1)

| Decision | Default |
| -------- | ------- |
| Clips after mock upload success | **Retain** for history playback |
| Logout | Per-user persistence; clear session only; no cross-user draft |
| Hive schema mismatch | Wipe case-study demo store only (v1) |
| `retrieveLostData` for video | Implement if supported; else document limitation (feature README or repository dartdoc) |
| Max video duration | No app cap in v1 unless trivial via plugin; OS camera governs |

## Dependencies (expected v1)

- **`video_player`** — playback in history (and optional review preview).
- **`path`** — safe clip filenames/extensions under app documents (add explicitly if not already a direct dependency).
- **`image_picker`** — use `pickVideo` and `retrieveLostData` where applicable (already in app).

## Scope

**In:** Feature module `lib/features/case_study_demo/` (domain / data / presentation), home → new case → 10-question video wizard → mock upload → history, [AuthRepository](../../lib/core/auth/auth_repository.dart) gate ([AppRouteAuthGate](../../lib/app/router/app_route_auth_gate.dart)), Example launcher, l10n, permissions, tests.

**Out:** Real backend upload, HIPAA product, `camera` package UI.

## Architecture summary

- **Persistence authoritative** — rehydrate session on `record` / `review` entry and app resume.
- **Keys:** `questionId` `q1`…`q10` only; answers as `Map<questionId, localPath>` (typed in domain).
- **Session cubit** vs **history** read path separated (history must not depend on transient wizard-only state).
- **Repositories:** video pick, Hive persistence, mock upload — mirror [CameraGalleryResult](../../lib/features/camera_gallery/domain/camera_gallery_result.dart) patterns for pick errors.

## DI / registration

- Add `lib/core/di/register_case_study_demo_services.dart` and call it from [injector_registrations.dart](../../lib/core/di/injector_registrations.dart) alongside other feature registers.

## Routes

Full paths (nested):

| Path | Purpose |
| ---- | ------- |
| `/case-study-demo` | Home |
| `/case-study-demo/new` | Case metadata |
| `/case-study-demo/record` | Video wizard |
| `/case-study-demo/review` | Summary + mock submit |
| `/case-study-demo/history` | List |
| `/case-study-demo/history/:id` | Detail + playback |

Implementation notes:

- Prefer **`ShellRoute`** so one [AppRouteAuthGate](../../lib/app/router/app_route_auth_gate.dart) and one session `BlocProvider` wrap nested routes. That requires **`List<RouteBase>`** (not only `List<GoRoute>`) in [routes.dart](../../lib/app/router/routes.dart) and the `GoRouter(routes: …)` call in [app.dart](../../lib/app.dart).
- Add **`AppRoutePolicies.caseStudyDemo`** in [route_auth_policy.dart](../../lib/app/router/route_auth_policy.dart).
- **Async redirect** on `record` / `review` when draft is invalid; keep a light **in-page guard** as backup.
- Add `AppRoutes` constants + route **names** in [app_routes.dart](../../lib/core/router/app_routes.dart).

## Platform permissions

- **iOS:** [Info.plist](../../ios/Runner/Info.plist) — **`NSMicrophoneUsageDescription`** for video recording; consider widening existing camera/library copy to mention case-study capture.
- **Android:** [AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml) — permissions for `image_picker` video consistent with your `compileSdk` / storage model.

## File lifecycle

| Event | Clips on disk | Hive draft | Hive records |
| ----- | ------------- | ---------- | ------------ |
| Save answer (copy from picker) | Persist under `caseId` / question key; **replace** prior file for that slot | Update answers map | No change |
| **Abandon** / start over (explicit) | Delete tree for `caseId` | Clear draft | No change |
| **Mock upload success** | **Keep** (v1) for history | Clear draft | Append record (paths unchanged) |
| **Mock upload failure** | Keep | Keep draft at reviewing | No change |
| App kill mid-pick | Picker temp may be gone; rely on `retrieveLostData` on Android when supported | Last persisted draft wins | N/A |
| **Schema mismatch** | Orphan clips may remain; v1 accepts “wipe demo box only” (optional follow-up cleanup job) | Cleared with box | Cleared with box |

## Edge cases, failure modes, and bugs to avoid

- **User id never use empty** — `loadDraft` / `saveDraft` / `loadRecords` must require a non-empty `AuthUser.id`. In `GoRouter` redirects, if `currentUser == null`, send to `AppRoutes.authPath` (with safe redirect) before touching Hive.
- **Account switch while shell is open** — If auth emits a different user while the case-study shell is mounted, **re-hydrate** from Hive for the new user or **close the flow** (pop/Cubit reset). Otherwise drafts can appear to “bleed” until the next navigation. Prefer listening to `authStateChanges` in the session cubit or recreating the shell subtree on user id change.
- **Picker temp paths** — Copy video into app documents **before** treating an answer as committed. Do not persist picker temp paths in Hive without copying; they may disappear after restart or be scoped to another UID.
- **Retake / replace** — When recording again for `qK`, delete the **previous** persisted file for that slot (if any) before copying the new clip to avoid orphan files and confusing playback.
- **Copy failures** — `File.copy` can fail (disk full, permission). Do not advance the wizard index until persistence succeeds; show `CameraGalleryResult`-style error handling.
- **Missing files at playback** — History/detail must handle `!File(path).existsSync()` (show inline error / placeholder, don’t crash `video_player`).
- **`video_player` lifecycle** — Dispose controllers when the preview widget is disposed; pause on `AppLifecycleState.inactive/paused` to reduce GPU/audio leaks and background crashes (align with repo lifecycle docs).
- **Request coalescing / race** — Use a **request-id guard** (same pattern as [camera gallery cubit](../../lib/features/camera_gallery/presentation/cubit/camera_gallery_cubit.dart)) so an older async pick result cannot commit after the user cancelled or moved to another question.
- **Redirect vs loading** — Async redirects must not flash infinite loops: if draft is still loading, avoid redirecting **away** from `record` based on a null draft until the first load completes (or use a dedicated “unknown” state). Prefer: redirect only after `ensureReady()` + explicit load returns.
- **`AppRoutePolicies` path** — The policy `path` must match the **authenticated subtree** you wrap (typically `/case-study-demo`). Mismatch breaks expectations in [app_route_auth_gate_test](../../test/app/router/app_route_auth_gate_test.dart) and mental model for “which routes are protected”.
- **`retrieveLostData` (video)** — If the plugin returns image-only recovery, document and return null for video; don’t assume parity with `pickImage`.
- **Deep links** — Direct navigation to `/case-study-demo/review` with an incomplete draft must **redirect** to `record` or `new`; page-level guard alone is weaker for bookmarked URLs.

## Verification

- `./bin/router_feature_validate` — formats + analyzes router/core/features + runs [test/app/router/](../../test/app/router/) and scoped feature tests.
- Broader `flutter analyze` if you touch files outside those directories.
- Widget/cubit tests for session logic and at least one persistence-oriented test.

## References

- [routes_demos.dart](../../lib/app/router/routes_demos.dart) — nested routes
- [routes_core.dart](../../lib/app/router/routes_core.dart) — auth gate patterns
- [lib/features/camera_gallery/](../../lib/features/camera_gallery/)
- [docs/camera_gallery_integration_plan.md](../camera_gallery_integration_plan.md)
- [AGENTS.md](../../AGENTS.md)
