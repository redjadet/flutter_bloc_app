# Maintainability Program

> **For agentic workers:** Execute one slice per PR. Use
> `superpowers:subagent-driven-development` (recommended) or
> `superpowers:executing-plans`. Track progress with checkboxes below.

**Status:** Slice 3 complete on branch; merge PR to close Rank 3.
**Branch / worktree:** `codex/maintainability-slice3-config-inject`
**Goal:** Improve extension seams without behavior changes or broad mechanical churn.
**Architecture:** Evidence-led, one seam per PR. Prefer constructor/router injection and narrow ports over GetIt or concrete cross-feature imports in feature presentation. Composition stays in `apps/mobile/lib/app/`.
**Tech stack:** Flutter Cubit/BLoC, GetIt (composition root only), GoRouter, existing modularity scripts.

## Global constraints

- Preserve routes, persistence shape, platform behavior, and public feature behavior unless a separately approved change requires otherwise.
- Domain stays pure Dart. Widgets render data + callbacks only.
- No GetIt / service-locator lookups in `features/*/presentation/**` (new or left behind by a slice).
- Speculative shared abstractions stay feature-local until shared lifecycle + error semantics are confirmed.
- Feature barrels remain public entrypoints. Non-trivial feature changes get a change note (+ feature brief when the brief contract applies).
- One extension seam per commit and PR. Split DI/router work from unrelated presentation cleanup.
- Do not reopen closed programs: Engineering Quality 10/10, senior-patterns Tier A/B scorecard, settings diagnostics decouple, chat→remote_config token port.

## Why this program (evidence)

Baseline run on this worktree (`2026-07-10`):

| Check | Result |
| --- | --- |
| `bash tool/check_clean_architecture_imports.sh` | Pass |
| `bash tool/check_feature_modularity_leaks.sh` | Pass |
| `bash tool/modular_metrics.sh --cross-feature-only` | **0** cross-feature edges |
| `bash tool/check_feature_folder_contract.sh` | Pass |
| `bash tool/check_feature_barrel_exports.sh` | 0 app→feature deep imports |

Hard architecture violations are already empty. Historical ports-sweep item
`case_study_demo → camera_gallery` is **resolved** (no remaining imports).
This program therefore targets **soft extension seams**: repeated composition /
locator / adapter patterns that still raise change fan-out and surprise.

Related (do not duplicate):

- [`audits/maintainability_baseline_review_2026-07-10.md`](../audits/maintainability_baseline_review_2026-07-10.md) — this program’s baseline snapshot
- [`modularity.md`](../modularity.md) — dependency direction + ports
- [`engineering/ports_adapters_modular_sweep_2026-05-12.md`](../engineering/ports_adapters_modular_sweep_2026-05-12.md) — prior port inventory
- [`audits/senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) — pattern grades (mostly closed)
- [`future_architecture_code_quality_improvement_plan.md`](future_architecture_code_quality_improvement_plan.md) — auth/sync/DI/error roadmap
- [`settings_diagnostics_decouple_plan.md`](settings_diagnostics_decouple_plan.md) — completed reference slice

## Selection rule

Choose **one** extension seam per PR.

1. **Hard violations first** — forbidden imports, cross-feature `package:` edges, concrete shared deps leaking into feature presentation. (Currently none.)
2. **Then soft seams** — repeated GetIt / bootstrap / adapter / error-policy composition with a stable contract and focused tests.
3. Break ties by lowest behavior risk, then highest change fan-out (call sites × features).
4. **Stop** when baseline has no qualifying hard or soft seam. Do not refactor for folder/naming churn alone.
5. Out-of-scorecard demos (`staff_app_demo` Firestore maps, etc.) stay deferred unless a new wave explicitly opens them.

### Finding record template

For each candidate, record before coding:

| Field | Value |
| --- | --- |
| Feature(s) | |
| Seam | |
| Dependency path | concrete import / GetIt type / adapter |
| Call sites | count + paths |
| Change fan-out | features / packages touched if seam moves |
| Behavior risk | low / medium / high + why |
| Existing tests | paths or “none” |
| Proposed fix | inject / port / move DTO / leave |

## Ranked backlog (2026-07-10)

| Rank | Seam | Evidence | Risk | Status |
| --- | --- | --- | --- | --- |
| 1 | Presentation GetIt → `BackendAvailability` | `chat_page.dart`, `iot_demo_cloud_tab.dart` resolve via `getIt` / `fromBootstrap()` | Low (banner visibility only) | **Slice 1 — done** ([change note](../changes/2026-07-10_maintainability_slice1_backend_availability_injection.md)) |
| 2 | Presentation `SecretConfig` static reads (chat) | `chat_page.dart`, `chat_list_view_navigation.part.dart` read transport/model config | Low (badge + initial model only) | **Slice 2 — done** ([change note](../changes/2026-07-10_maintainability_slice2_secret_config_injection.md)) |
| 3 | Presentation imports of app bootstrap/config beyond injected values | flavor, `FirebaseBootstrap`, `iot_ble_runtime_config`, calculator constants | Low–med | **Slice 3 — done** ([change note](../changes/2026-07-10_maintainability_slice3_app_config_injection.md)) |
| 4 | Data-layer GetIt in chat render diagnostics | `chat_render_orchestration_diagnostics.dart` | Low | **Closed** ([follow-ups note](../changes/2026-07-10_maintainability_followups_router_validate_diagnostics.md)) |
| 5 | `router_feature_validate` stale paths | `bin/router_feature_validate` after core→app move | Low | **Closed** ([follow-ups note](../changes/2026-07-10_maintainability_followups_router_validate_diagnostics.md)) |
| 6 | Yellow pattern leftovers (chat / ai_decision P5–P6, scapes P4–P5) | [`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) | Med | Optional later; not scorecard-blocking |
| 7 | Counter `ViewStatus` dual channel | Documented acceptable skip in senior-patterns | Low | Skip unless product asks |
| — | `staff_app_demo` Firestore map P3 | Explicit out-of-scorecard | High churn | Deferred |

## Phase 0 — Branch hygiene + audit note

**Files:**

- Modify: `docs/plans/2026-07-10_maintainability_program.md` (this file; baseline table)
- Create/update: [`docs/audits/maintainability_baseline_review_2026-07-10.md`](../audits/maintainability_baseline_review_2026-07-10.md) after rebase if any row changes

- [x] **Step 0.1: Rebase on latest `origin/main`**

```bash
cd /path/to/flutter_bloc_app-maintainability
bash tool/commit_push_pr_rebase_on_main.sh
# resolve conflicts if any; then:
git status --short
git log --oneline -3
```

Expected: branch tip includes current `origin/main` (as of plan authoring: `727aac57` or newer). Worktree clean except this plan.

- [x] **Step 0.2: Re-run baseline after rebase**

```bash
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/modular_metrics.sh --cross-feature-only
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_barrel_exports.sh
rg -n "getIt\.|GetIt\." apps/mobile/lib/features --glob '*.dart' -g '!*_test.dart'
```

Expected: architecture scripts pass; `rg` still shows GetIt in chat + iot_demo presentation (Slice 1 targets). Update the evidence table if anything changed.

- [x] **Step 0.3: Confirm Slice 1 still ranks #1**

If a new hard cross-feature edge appeared on main, that becomes Slice 1 instead. Otherwise proceed.

- [ ] **Step 0.4: Commit plan-only (if not already)**

```bash
git add docs/plans/2026-07-10_maintainability_program.md docs/plans/README.md
git commit -m "$(cat <<'EOF'
docs: ready maintainability program with ranked first slice

EOF
)"
```

## Slice 1 — Inject `BackendAvailability` into chat + IoT cloud UI

**Problem:** Feature presentation reaches into the service locator for banner
policy. That couples widgets to DI lifecycle and duplicates bootstrap fallback
logic.

**Fix:** Pass `BackendAvailability` (or a `bool showBackendDisabledBanner`
derived at the composition root) into the widgets. Keep GetIt only in
`apps/mobile/lib/app/router/**` / composition.

**Files:**

- Modify: `apps/mobile/lib/features/chat/presentation/pages/chat_page.dart`
- Modify: `apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart`
- Modify: `apps/mobile/lib/app/router/pages/iot_demo_hub_page.dart` (pass availability into cloud tab)
- Modify: `apps/mobile/lib/app/router/routes_demos.dart` (and/or `.part.dart`) — resolve `BackendAvailability` once when building `ChatPage` / hub
- Test: existing chat / iot_demo widget tests under `apps/mobile/test/features/…`; add or extend focused tests for banner visibility without GetIt

**Interfaces:**

- Consumes: `BackendAvailability` from `apps/mobile/lib/app/config/backend_availability.dart` (unchanged type)
- Produces: `ChatPage({ required ErrorNotificationService errorNotificationService, required BackendAvailability backendAvailability, … })`; `IotDemoCloudTab({ required BackendAvailability backendAvailability, … })`

### Task 1.1 — Failing / characterizing tests

- [x] **Step 1: Locate or add widget tests that cover `BackendDisabledBanner` on chat and IoT cloud**

Prefer extending existing page tests. Assert banner visibility from a
**constructed** `BackendAvailability` (no `getIt` registration required).

Example shape (adapt to existing harness):

```dart
testWidgets('ChatPage hides backend banner when backends available', (tester) async {
  await tester.pumpWidget(
    /* existing test app wrapper */
    ChatPage(
      errorNotificationService: fakeErrors,
      backendAvailability: const BackendAvailability(
        firebaseInitialized: true,
        supabaseInitialized: true,
        webNoBackendMode: true,
        allowWebLocalGuestAuth: true,
        allowLocalChatFallback: true,
      ),
    ),
  );
  expect(find.byType(BackendDisabledBanner), findsOneWidget);
  // assert not visible / empty when policy says hide — match BackendDisabledBanner API
});
```

- [x] **Step 2: Run focused tests — expect fail or compile error until constructors exist**

```bash
cd apps/mobile
flutter test test/features/chat test/features/iot_demo --reporter compact
```

### Task 1.2 — Implementation

- [x] **Step 3: Add required `backendAvailability` to `ChatPage` and replace GetIt block**

```dart
class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.errorNotificationService,
    required this.backendAvailability,
    this.renderTransportDemoStrictOverride,
    super.key,
  });

  final ErrorNotificationService errorNotificationService;
  final BackendAvailability backendAvailability;
  final bool? renderTransportDemoStrictOverride;
  // ...
}

// In build:
BackendDisabledBanner(
  visible: widget.backendAvailability.webNoBackendMode &&
      (!widget.backendAvailability.firebaseInitialized ||
          !widget.backendAvailability.supabaseInitialized),
),
```

Remove `import '.../injector.dart'` from this file if unused.

- [x] **Step 4: Same for `IotDemoCloudTab` + thread through `IotDemoHubPage`**

```dart
class IotDemoCloudTab extends StatefulWidget {
  const IotDemoCloudTab({required this.backendAvailability, super.key});
  final BackendAvailability backendAvailability;
}

// Banner:
visible: widget.backendAvailability.webNoBackendMode &&
    !widget.backendAvailability.supabaseInitialized,
```

Hub page takes `backendAvailability` and passes it into `IotDemoCloudTab`.

- [x] **Step 5: Wire router / route builders**

In `routes_demos.dart` / `routes_demos.part.dart` (where `ChatPage` and
`IotDemoHubPage` are constructed), resolve once:

```dart
final BackendAvailability availability = getIt<BackendAvailability>();
// ...
child: ChatPage(
  errorNotificationService: getIt<ErrorNotificationService>(),
  backendAvailability: availability,
),
```

Same for hub construction paths that already read `BackendAvailability`.

- [x] **Step 6: Prove GetIt gone from those presentation files**

```bash
rg -n "getIt\.|GetIt\." \
  apps/mobile/lib/features/chat/presentation/pages/chat_page.dart \
  apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart
```

Expected: no matches.

### Task 1.3 — Verify + docs

- [x] **Step 7: Focused tests + analyze**

```bash
cd apps/mobile && flutter test test/features/chat test/features/iot_demo --reporter compact
./tool/analyze.sh
```

- [x] **Step 8: Architecture + modularity + router** (router script fails on missing `lib/core/router/`; `flutter test test/app/router/` green)

```bash
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/modular_metrics.sh --cross-feature-only
./bin/router_feature_validate
```

- [x] **Step 9: Change note**

Create a short note under `docs/changes/` (date-prefixed), covering: problem,
files, proof commands, behavior unchanged. Link it from this plan’s Slice 1
status once the file exists.

- [x] **Step 10: Commit**

```bash
git add apps/mobile/lib/features/chat/presentation/pages/chat_page.dart \
  apps/mobile/lib/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart \
  apps/mobile/lib/app/router/pages/iot_demo_hub_page.dart \
  apps/mobile/lib/app/router/routes_demos.dart \
  apps/mobile/lib/app/router/routes_demos.part.dart \
  apps/mobile/test \
  docs/changes \
  docs/plans/2026-07-10_maintainability_program.md
git commit -m "$(cat <<'EOF'
refactor: inject BackendAvailability into chat and IoT cloud UI

EOF
)"
```

(Adjust paths if router wiring lives only in one of the route files.)

### Slice 1 acceptance

- Observable banner policy unchanged for the same `BackendAvailability` values.
- No new cross-feature edges; no forbidden imports.
- No `getIt` in the two presentation call sites.
- Focused tests + analyze + modularity scripts green.
- One PR, one seam.

## Later slices (do not start until Slice 2 merges)

1. Re-scan soft seams (`rg getIt` and `rg SecretConfig` under `features/*/presentation`).
2. Optionally tackle one yellow pattern leftover with its own plan section + tests.
3. Stop when soft scan is empty or only deferred/out-of-scope items remain.

## Verification (every slice)

1. Focused unit / Cubit / widget tests covering old and new dependency paths.
2. `./tool/analyze.sh`
3. Baseline architecture + modularity commands (see Phase 0).
4. `./bin/router_feature_validate` when router or DI changes.
5. `./bin/checklist` for shared infrastructure, DI, or multi-feature work (Slice 1 qualifies → run before merge).

**Acceptance (program-wide):** unchanged observable behavior; no new cross-feature edges; no forbidden imports; reduced direct dependency surface; focused regression proof; backlog table updated.

## Current assumptions

- Worktree started from `c324e1e5`; **rebase onto current `origin/main` in Phase 0** before coding.
- Folder-contract and app→feature deep-import checks pass.
- Legacy layout warnings alone do not justify batch migration.
- Engineering Quality scorecard remains 10/10; this program must not regress its proof commands.

## Definition of done (program)

- Phase 0 complete on rebased branch.
- ≥2 soft seams closed with tests + change notes (Slices 1–2).
- Soft-scan `rg` for `getIt` under `features/*/presentation` shows **zero** hits; chat presentation has no `SecretConfig` reads.
- Plans README status line reflects “in progress” → “slice N done” as PRs merge.
