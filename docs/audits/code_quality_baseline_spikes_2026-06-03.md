# Phase 0b — deferred gate readiness spikes (2026-06-03)

Spike tickets for [`checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md).
Baseline: [`code_quality_baseline_2026-06-03.md`](code_quality_baseline_2026-06-03.md).

## Spike: QG-D07 — lifecycle observer dispose

- **Script:** `tool/check_lifecycle_observer_dispose.sh` (authored in PR2)
- **Dry-run:** violation_count **0** on `main` (3 `WidgetsBindingObserver` sites, all call `removeObserver` in `dispose`)
- **Inventory:** `lib/app/app_scope.dart`, `lib/features/counter/presentation/pages/counter_page.dart`, `lib/features/case_study_demo/presentation/widgets/case_study_video_tile.dart`
- **Fixtures:** `tool/fixtures/lifecycle_observer_dispose/presentation/{good,bad,suppressed}.dart`
- **FP risk:** low
- **Label:** **ready**
- **Severity (PR2):** warn-first (`CHECK_LIFECYCLE_OBSERVER_MODE=warn`)
- **Severity (PR #292):** default **fail** — 0 violations on `main` @ `dd883f31`
- **Rollback:** remove CHECK_SCRIPTS row; restore deferred doc row

## Spike: QG-D05 — deferred heavy routes

- **Script:** `tool/check_deferred_heavy_routes.sh` (authored in PR2)
- **Dry-run:** violation_count **0** — all `deferred as` imports live in allowlisted router files only
- **Allowlist:** `lib/app/router/route_groups.dart`, `lib/app/router/routes_core.dart` (per baseline appendix)
- **Fixtures:** router fixture paths under `tool/fixtures/deferred_heavy_routes/`
- **FP risk:** low
- **Label:** **ready**
- **Severity (PR2):** warn-first (`CHECK_DEFERRED_HEAVY_ROUTES_MODE=warn`)
- **Severity (PR #292):** default **fail** — 0 violations on `lib/app/router`
- **Rollback:** remove CHECK_SCRIPTS row; restore deferred doc row

## Spike: QG-D08 — CHECK_THEME filter

- **Script:** N/A (infra)
- **Dry-run:** not run
- **Label:** **needs_fixtures** — subset runner safety spec still required

## Spike: QG-D03 — bloc rebuild scoping

- **Script:** `tool/check_bloc_rebuild_scoping.sh` — **missing**
- **Label:** **needs_fixtures**

## Spike: QG-D04 — context read/watch

- **Script:** `tool/check_context_read_watch.sh` — **missing**
- **Label:** **needs_fixtures** — demo glob exclusions required

## Spike: QG-D06 — startup work in build

- **Script:** `tool/check_startup_work_in_build.sh` — **missing**
- **Label:** **needs_fixtures** — diff vs `check_side_effects_build.sh` required

## Spike: QG-D01 — bloc_lint

- **Script:** analyzer plugin — **not wired**
- **Label:** **reject** for wave 1 (wave 3 per promotion queue)

## Spike: QG-D02 — file_length_lint

- **Script:** `./tool/run_file_length_lint.sh` + native `plugins:` in `analysis_options.yaml`
- **Label (2026-06-03):** **reject** for wave 1 (wave 3 per promotion queue)
- **Status (2026-06-08):** **promoted (fail)** — see [`../changes/2026-06-08_file_length_lint_qg-d02.md`](../changes/2026-06-08_file_length_lint_qg-d02.md)

## Spike: QG-D10 — sync IO in all lib

- **Label:** **reject** (per owner deferred doc)

## Promotion queue (confirmed)

1. QG-D07 — **ready** → PR #290 (warn) → PR #292 (**fail**)
2. QG-D05 — **ready** → PR #290 (warn) → PR #292 (**fail**)
3. QG-D08 — **needs_fixtures** (subset runner safety); no script
4. QG-D03 / QG-D04 / QG-D06 — **needs_fixtures**; scripts missing
5. QG-D01 — **reject** wave 1 (analyzer plugin); QG-D02 — **promoted** 2026-06-08

## Phase 2 wave closure (2026-06-03)

No additional gate scripts promoted beyond D05/D07 fail flip. D03/D04/D08 remain spike-only until fixtures and scripts land (cadence 3+).
