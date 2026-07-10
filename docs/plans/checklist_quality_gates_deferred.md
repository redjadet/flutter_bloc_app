# Checklist quality gates — deferred backlog

**Status:** Post-MVP (2026-05-20). MVP (M0–M4) is **shipped**; items below are **not**
blocking merge of the four new gates. Source plan:
[checklist quality gates](checklist_quality_gates_baseline.md) (MVP proof).

**MVP shipped (do not re-open as “missing work”):**

- Fail: `check_navigation_outside_presentation.sh`, `check_sync_io_in_presentation.sh`
- Fail (promoted 2026-06-03): `check_remote_image_cache_hints.sh`, `check_cubit_subscription_cancel.sh`
- Fail (promoted 2026-06-08): `file_length_lint` / `file_too_long` (native plugin, max 225 lines under `lib/`)
- `CHECK_SCRIPT_THEMES`, `CHECKLIST_EXPLAIN_THEMES=1`, path-triggered
  `./bin/router_feature_validate`, `background_sync_coordinator_test.dart` regression

---

## How to use this doc

| Column | Meaning |
| --- | --- |
| **ID** | Stable backlog key for issues/plans |
| **Unblock** | Measurable done-criteria before implementation starts |
| **Decision** | `defer` = later; `reject` = do not pursue as written |

When an item ships, remove its row here and note the change in
[`docs/changes/`](../changes/README.md) or a dated change note.

---

## Backlog

| ID | Theme | Proposed gate / tool | Decision | Why deferred | Unblock criteria |
| --- | --- | --- | --- | --- | --- |
| **QG-D01** | State / rebuild | `bloc_lint` (custom analyzer) | **ADR-deferred** | Overlaps [`check_cubit_isclosed.sh`](../validation_scripts.md); needs curated rule set + CI budget. Non-blocking for Engineering scorecard. | Owner: [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md) § follow-up; document which `bloc_lint` rules complement existing gates before promotion. |
| **QG-D02** | File size | `file_length_lint` (native plugin) | **promoted (fail)** | Shipped 2026-06-08: plugin enabled in `analysis_options.yaml`, `file_too_long: error`, `max_lines: 225`, 0 violations on `lib/`; `./tool/run_file_length_lint.sh`. | Split oversized files into `*.part.dart`; do not raise `max_lines` to hide violations; change note [`../changes/2026-06-08_file_length_lint_qg-d02.md`](../changes/2026-06-08_file_length_lint_qg-d02.md). |
| **QG-D03** | Rebuild | `check_bloc_rebuild_scoping.sh` | **ADR-deferred** | `BlocBuilder` without `buildWhen` is common in demos; false-positive rate unknown without analyzer ruleset. Non-blocking for Engineering scorecard. | Owner: [`docs/plans/code_quality_baseline_and_gate_promotion_2026-06.md`](code_quality_baseline_and_gate_promotion_2026-06.md); fixture trio + FP rate threshold before promotion. |
| **QG-D04** | Rebuild / context | `check_context_read_watch.sh` (presentation) | **promoted (warn)** | Shipped 2026-07-09: default `CHECK_CONTEXT_READ_WATCH_MODE=warn`; excludes `*_demo/**/presentation/**`; fixtures under `tool/fixtures/context_read_watch/`. | Flip to fail only after precision pass on held-out router/widget files; change note [`../changes/2026-07-09_context_read_watch_qg-d04.md`](../changes/2026-07-09_context_read_watch_qg-d04.md). |
| **QG-D05** | Navigation / perf | `check_deferred_heavy_routes.sh` | **promoted (fail)** | Shipped 2026-06-03 warn; flipped 2026-06-03: default `CHECK_DEFERRED_HEAVY_ROUTES_MODE=fail` (0 violations on `apps/mobile/lib/app/router`). | Revert to warn only if a second deferred route file is added intentionally; keep fixtures under `tool/fixtures/deferred_heavy_routes/`. |
| **QG-D06** | Startup | `check_startup_work_in_build.sh` | **reject** | Overlaps `check_side_effects_build.sh`; duplicate signals for this repo. | Revisit only if side-effects script misses a class of startup-in-build violations with evidence. |
| **QG-D07** | Lifecycle | `check_lifecycle_observer_dispose.sh` | **promoted (fail)** | Shipped 2026-06-03 warn; flipped 2026-06-03: default `CHECK_LIFECYCLE_OBSERVER_MODE=fail` (0 violations on `lib/`). | Revert to warn only when adding a new observer site without dispose yet; fixtures under `tool/fixtures/lifecycle_observer_dispose/`. |
| **QG-D08** | Checklist UX | `CHECK_THEME` env filter | **ADR-deferred** | Needs subset runner tests so partial runs do not skip required fail gates. Non-blocking for Engineering scorecard. | Owner: [`docs/plans/code_quality_baseline_and_gate_promotion_2026-06.md`](code_quality_baseline_and_gate_promotion_2026-06.md); spec `CHECK_THEME=navigation ./bin/checklist` + safety test before promotion. |
| **QG-D10** | Blocking IO | `check_sync_io_in_lib.sh` (entire `lib/`) | **reject** | Data layer **legitimately** uses `existsSync` / `*Sync` in Hive and file stores; presentation-only gate is the correct boundary. | Revisit only if data layer moves sync IO off hot paths **and** presentation gate is insufficient. |

---

## Cancelled (optional MVP, explicitly not doing)

| ID | Item | Reason |
| --- | --- | --- |
| **QG-X01** | `check_presentation_build_method_size.sh` | Optional M3 scope; build-size rules already partially covered by other scripts; cost/benefit low for checklist runtime. |

---

## Infrastructure notes (not separate gates)

| Topic | Current behavior | Follow-up |
| --- | --- | --- |
| Router validate without git | `should_run_router_feature_validate_auto` returns run when `HAS_GIT_REPO≠1` (conservative: cannot diff → may run validate). | Document in validation_scripts; optional tighten to skip when no changed-file list. |
| Codex plan review (May 2026) | Three delegate runs aborted; no external review merged. | Optional re-run for deferred IDs only; not required for MVP closure. |

---

## Related docs

- MVP baseline & fixtures: [`checklist_quality_gates_baseline.md`](checklist_quality_gates_baseline.md)
- Change note: [`../changes/2026-05-20_checklist_quality_gates.md`](../changes/2026-05-20_checklist_quality_gates.md)
- Script catalog: [`../validation_scripts/catalog.md`](../validation_scripts/catalog.md) (Quality theme gates)
- Fast vs full routing: [`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
