# Flutter fundamentals and production practices (this repo)

Interview- and onboarding-oriented answers grounded in **this** codebase.
Deep owners stay linked; this page synthesizes the stories and seams we
actually ship.

Related:

- State rules: [`bloc_standards.md`](../bloc_standards.md),
  [`architecture/state_management_choice.md`](../architecture/state_management_choice.md)
- Offline: [`offline_first/adoption_guide.md`](../offline_first/adoption_guide.md),
  [ADR 0002](../adr/0002-offline-first-data.md)
- Performance: [`performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md)
- Structure: [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md),
  [`modularity.md`](../modularity.md)
- Crash ownership: [`observability/crashlytics_triage_runbook.md`](../observability/crashlytics_triage_runbook.md)
- Portfolio walk: [`interview_showcase.md`](../interview_showcase.md)

---

## Part 1 — Widget and state fundamentals

### Why everything in Flutter is a widget

In Flutter, UI configuration is declarative: you describe a **tree of widgets**,
and the framework turns that into Elements and RenderObjects. Buttons, padding,
themes, media queries, routes, and even “invisible” adapters are widgets so
composition stays uniform.

In this app that shows up as:

- Feature **pages** and **bodies** under `presentation/pages/` and
  `presentation/widgets/`
- Shared UI in `packages/design_system` and `packages/material_ui`
- App shell composition under `apps/mobile/lib/app/` (router, scope, badges)

A widget is not the painted pixel. It is an immutable configuration object.
Rebuild means *new widget instances for dirty subtrees*, not necessarily a full
app redraw.

### What the widget tree actually is

Three related trees:

| Tree | Role |
| --- | --- |
| **Widget** | Immutable config (“what should this look like / do?”) |
| **Element** | Mutable mount that holds a widget, lifecycle, and BuildContext |
| **RenderObject** | Layout, paint, hit-test (where constraints and sizes live) |

Pipeline we care about in perf work:

```text
input/state → schedule frame → build → layout → paint → compose → raster
```

Repo detail: [`performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md)
(*Constraints go down. Sizes go up. Parents set positions.* also in
[`architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md)).

Practical consequence here: prefer **narrow rebuilds**. Counter body listens
only to loading via `TypeSafeBlocSelector`, not the whole `CounterState`:

```dart
// apps/mobile/lib/features/counter/presentation/widgets/counter_page_body.dart
TypeSafeBlocSelector<CounterCubit, CounterState, bool>(
  selector: (state) => state.isLoading,
  builder: (context, isLoading) => Skeletonizer(
    enabled: isLoading,
    child: _CounterContent(/* ... */),
  ),
);
```

### StatelessWidget versus StatefulWidget

| | StatelessWidget | StatefulWidget |
| --- | --- | --- |
| Holds | Only constructor fields | A `State` object that can change over time |
| Rebuild trigger | Parent rebuild / inherited dependency | `setState`, inherited deps, parent |
| Use when | Pure projection of inputs | Animation tickers, controllers, focus, one-off UI flags |

**This repo’s default:** feature business and async flow live in **Cubit**, not
in `State`. Pages may still be `StatefulWidget` when they need local UI
ephemera (snackbar visibility, ticker, subscription to a diagnostics stream).

Counter examples:

- `CounterPageBody` — `StatelessWidget` + Cubit selector (render loading shell)
- `CounterPage` — `StatefulWidget` for snackbar visibility flag via `setState`
- `CounterSyncQueueInspectorButton` — `StatefulWidget` for a short-lived pending
  count read while the inspector dialog opens

Rule from [`bloc_standards.md`](../bloc_standards.md): *UI-only ephemeral
toggles → local widget state if no business rule or shared state.*

### setState versus Provider, Riverpod, or Bloc

| Mechanism | What it owns | Rebuild model | Where we use it |
| --- | --- | --- | --- |
| **`setState`** | One `State` subtree | That Element and descendants | Ephemeral UI only |
| **Provider** | Inherited DI / listenables | `context.watch` / `Selector` | Not the feature-state default |
| **Riverpod** | Compile-time providers + codegen | Provider graph | Explicitly **out** without ADR |
| **Cubit/BLoC** | Presentation state machine | `BlocBuilder` / `BlocSelector` / type-safe helpers | **Canonical** feature + app-scope state |

Decision (not “Bloc is always better”): consistency, `bloc_test`, DI lifecycle,
and Clean Architecture boundaries —
[`architecture/state_management_choice.md`](../architecture/state_management_choice.md).

Comparison we actually teach:

1. **`setState`** — fine for “is this snackbar already showing?” Wrong for
   “persist counter, enqueue sync, map failures.”
2. **Provider** — fine as a DI/listen surface; we use GetIt + `BlocProvider` /
   route scope instead of Provider as the state library.
3. **Riverpod** — strong for many greenfield apps; here migration cost and dual
   patterns would slow the team
   ([`state_management_choice.md`](../architecture/state_management_choice.md);
   layering [ADR 0001](../adr/0001-architecture-and-layering.md)).
4. **Cubit/BLoC** — immutable Freezed (or allowed) states; methods/events;
   `TypeSafeBlocSelector` to avoid wide rebuilds; domain stays free of Cubits.

### Hot reload versus hot restart

| | Hot reload | Hot restart |
| --- | --- | --- |
| Keeps | Most in-memory Dart state | Almost nothing from the Dart isolate |
| Re-runs | Injects updated library code into running isolate | Re-enters `main` / re-inits app |
| Use for | UI layout, widget build, many Cubit method bodies | `main`, DI graph, global init, codegen, native channel registration |

Repo practice:

- Agents: after Dart/UI edits, **hot reload** when a debug session exists;
  **hot restart** when reload cannot apply
  (`.cursor/rules/agent-auto-hot-reload.mdc`, `/hot-reload` command).
- Storage/init path changes: Apple Hive debug doc says **hot restart or cold
  run** after init/DI/storage path edits
  ([`apple_debug_hive_storage.md`](apple_debug_hive_storage.md)).
- Native MethodChannel / EventChannel registration: **full rebuild**, not
  reload ([change note](../changes/2026-07-02_native_showcase_event_channel_telemetry.md)).

Story: Social Feed likes persisted to Hive so a **hot restart** recreating the
remote still hydrates `isLikedByMe`
([`2026-08-25_social_feed_like_persistence.md`](../changes/2026-08-25_social_feed_like_persistence.md)).

---

## Part 2 — Production questions with stories from this repo

### How do you handle offline data?

**Policy:** local-first write, queued sync, never silently overwrite newer
intent with older remote or stale queue replay
([ADR 0002](../adr/0002-offline-first-data.md),
[`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md)).

**Seams in code:**

1. Hive local store (`HiveRepositoryBase` / feature Hive repos).
2. Feature `OfflineFirst*Repository` implementing `SyncableRepository`.
3. `PendingSyncRepository` enqueue with idempotency / dedupe.
4. `BackgroundSyncCoordinator.flush()` (debounced; no overlapping flushes).
5. UI: pending banners (Counter/Chat) + Settings → Sync Diagnostics.

**Counter story (spine demo):**
`OfflineFirstCounterRepository.save` normalizes, writes local, marks pending,
enqueues; sync parts decide push vs apply remote with helpers that refuse older
snapshots
(`apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart`
and `*_sync.part.dart`).

**Social Feed story (harder correctness; simulated demo scope):**
online apply and queue replay could race and drop newest like/comment intent.
Fix: serialize per-viewer apply, re-read queue at the decision boundary, keep
exact remaining `pendingPostIds`. Does **not** claim a production backend or
auth model
([case study](../case_studies/engineering/social_feed_offline_ownership.md),
[queue reconciliation](../changes/2026-08-24_social_feed_offline_queue_reconciliation.md),
[like dispatch race](../changes/2026-09-01_social_feed_like_dispatch_race.md)).
Regression gate: `tool/check_offline_first_remote_merge.sh`.

**Interview one-liner:** *We treat offline as a data-layer correctness problem,
not a Cubit flag. Cubits show pending; repositories own merge and queue.*

### How do you keep an app performant?

Layers we use:

1. **Architecture defaults** — Cubit + selectors so unrelated fields do not
   rebuild lists (`TypeSafeBlocSelector`, `buildWhen`).
2. **Measurement before abstraction** — Todo selection rebuilt the whole list;
   we split lifecycle / list / selection projections **after** a baseline, then
   remeasured with Hive + Timeline
   ([case study](../case_studies/engineering/todo_measurement_gated_performance.md)).
3. **Hot-path hygiene** — throttle Counter sync flush (500 ms); cache
   `NumberFormat`; avoid swapping heavy button subtrees; controller-driven map
   camera updates
   ([`performance_bottlenecks.md`](../performance/performance_bottlenecks.md)).
4. **Budgets and demos** — `tool/perf_budgets.json`,
   `frame_timing_monitor.dart`, Production readiness frame p90/p99
   ([interview showcase §3b](../interview_showcase.md)).
5. **Inventory without false gates** — `tool/check_bloc_rebuild_scoping.sh`
   warns on wide `BlocBuilder`s; does not fail checklist by default
   ([QG-D03](../changes/2026-08-04_bloc_rebuild_scoping_qg-d03.md)).

**Interview one-liner:** *Prove the expensive frame path, narrow the rebuild
boundary, keep a regression harness; do not invent a generic cache first.*

### How do you structure a codebase so a team can move fast?

Speed here comes from **predictable seams**, not from fewer files.

| Practice | Where it lives |
| --- | --- |
| Clean Architecture feature skeleton | [`feature_structure_contract.md`](../architecture/feature_structure_contract.md); scaffold `tool/scaffold_feature_contract.sh` |
| Cubit only in `presentation/cubit/` | [`bloc_standards.md`](../bloc_standards.md) |
| Feature modularity + leak checks | [`modularity.md`](../modularity.md); `tool/check_feature_modularity_leaks.sh` |
| Melos packages for shared infra | `packages/storage`, `networking`, `design_system`, … |
| Validation routing (fast vs full) | [`validation_routing_fast_vs_full.md`](validation_routing_fast_vs_full.md); `./bin/checklist-fast` vs `./bin/checklist` |
| One outcome per branch / worktree | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md); `./bin/agent-worktree` |
| Reference features as gold layouts | [`architecture/reference_features.md`](../architecture/reference_features.md) |
| Restraint when typing is cheap | [`critical_human_skills.md`](critical_human_skills.md) |

**Story:** dual state libraries or speculative shared packages would *look*
faster day one and slow every review. We reject Riverpod without ADR and reject
parallel skeletons (`viewmodels/`, `providers/` at feature root).

**Interview one-liner:** *Same folder contract, same state tool, same validation
lanes, smallest reversible PR — parallel work via worktrees, not shared dirty
trees.*

### How do you debug a crash you cannot reproduce?

Loop we run in production ownership demos:

1. **Classify** from Crashlytics / logs with allowlisted keys only (`flavor`,
   `app_version`, `firebase_ready`) — never attach PII/tokens
   ([`crashlytics_triage_runbook.md`](../observability/crashlytics_triage_runbook.md)).
2. **Sanitize** — bootstrap redaction (`LogRedaction`, FCM log redaction).
3. **Prefer a failing automated test** over device folklore.
4. **Smallest fix** + regression in the same series.
5. **Record** in `docs/changes/` when behavior ships.

**Story — macOS EventChannel abort (not reproducible as a Dart exception):**
Integration on macOS died with `EXC_CRASH (SIGABRT)` in
`MainFlutterWindow.awakeFromNib` while creating a telemetry EventChannel with
`makeBackgroundTaskQueue`. iOS messenger supports that optional API; macOS
relay forwards to a parent that does **not**, then aborts. Fix: register
without background task queue on macOS; keep iOS path. Proof: desktop
integration suite green again
([`2026-08-20_macos_telemetry_event_channel_crash.md`](../changes/2026-08-20_macos_telemetry_event_channel_crash.md)).

**Story — web blank startup:**
WalletConnect path threw a JS `Error` that escaped `on Exception` and blanked
startup; guard tightened to `on Object`
([`2026-09-07_web_startup_firebase_js_error.md`](../changes/2026-09-07_web_startup_firebase_js_error.md)).

**In-app proof without shipping noise:** `/production-readiness` → Emit test
non-fatal (simulated = local only; live = sanitized Crashlytics reason).

**Interview one-liner:** *Triage by sanitized fingerprints, reproduce with a
test or platform harness, fix the boundary that actually throws — including
native messengers — then lock it with automation.*

---

## Quick map: question → open this first

| Question | Open |
| --- | --- |
| Stateless vs Stateful / widget tree / setState vs Bloc | This doc Part 1 + Counter presentation |
| Hot reload vs restart | This doc + agent-auto-hot-reload rule |
| Offline | ADR 0002 + Counter offline repo + Social Feed case study |
| Performance | Todo measurement case study + performance_bottlenecks |
| Team structure | Feature structure contract + modularity |
| Unreproducible crash | Crashlytics runbook + macOS EventChannel change note |

## Validation for doc-only edits

```bash
bash tool/check_docs_gardening.sh --paths \
  docs/engineering/flutter_fundamentals_and_production_practices.md \
  docs/engineering/README.md \
  docs/case_studies/README.md \
  docs/interview_showcase.md \
  docs/new_developer_guide.md \
  docs/README.md \
  docs/changes/2026-09-09_flutter_fundamentals_and_production_practices.md \
  docs/changes/README.md
./bin/agent-maintain closeout
```
