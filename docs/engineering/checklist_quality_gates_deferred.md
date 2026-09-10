# Checklist quality gates — deferred backlog

**Status:** Post-MVP. MVP (M0–M4) shipped 2026-05-20; several follow-ups
promoted since. This doc is the **open** backlog only. Source MVP proof:
[checklist quality gates baseline](checklist_quality_gates_baseline.md).

**Already shipped (do not re-open as missing work):**

| ID | Gate | Severity | Note |
| --- | --- | --- | --- |
| MVP | `check_navigation_outside_presentation.sh`, `check_sync_io_in_presentation.sh` | fail | Wired 2026-05-20 |
| MVP→fail | `check_remote_image_cache_hints.sh`, `check_cubit_subscription_cancel.sh` | fail | Promoted 2026-06-03 |
| **QG-D02** | `file_length_lint` / `file_too_long` | fail | Promoted 2026-06-08 |
| **QG-D04** | `check_context_read_watch.sh` | fail | Fail-default 2026-08-04; in `CHECK_SCRIPTS` |
| **QG-D05** | `check_deferred_heavy_routes.sh` | fail | Fail-default 2026-06-03; in `CHECK_SCRIPTS` |
| **QG-D07** | `check_lifecycle_observer_dispose.sh` | fail | Fail-default 2026-06-03; in `CHECK_SCRIPTS` |
| themes | `CHECK_SCRIPT_THEMES` + `CHECKLIST_EXPLAIN_THEMES=1` | meta | Length must match `CHECK_SCRIPTS` |
| router | path-triggered `./bin/router_feature_validate` | auto | Skip: `CHECKLIST_SKIP_ROUTER_VALIDATE=1` |

---

## How to use this doc

| Column | Meaning |
| --- | --- |
| **ID** | Stable backlog key for issues/plans |
| **Unblock** | Measurable done-criteria before implementation starts |
| **Decision** | `ADR-deferred` = parked with owner; `reject` = do not pursue as written; `open (warn)` = shipped inventory, checklist wiring still optional |

When an item ships to fail-in-checklist, move it into the shipped table above and
delete its open-backlog row. Note the change in [`docs/changes/`](../changes/README.md).

---

## Open backlog

| ID | Theme | Proposed gate / tool | Decision | Why open | Unblock criteria |
| --- | --- | --- | --- | --- | --- |
| **QG-D01** | State / rebuild | `bloc_lint` (custom analyzer) | **ADR-deferred** | Overlaps [`check_cubit_isclosed.sh`](../validation_scripts.md); needs curated rule set + CI budget. Non-blocking for Engineering scorecard. | Owner: [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md) § follow-up; document which `bloc_lint` rules complement existing gates before promotion. |
| **QG-D03** | Rebuild | `check_bloc_rebuild_scoping.sh` | **open (warn)** | Inventory scanner shipped 2026-08-04 (report-only). Default `CHECK_BLOC_REBUILD_SCOPING_MODE=warn`; presentation non-demo; `*_demo/**` excluded; fixtures `tool/fixtures/bloc_rebuild_scoping/`; **not** in `CHECK_SCRIPTS`. PR0: 2 non-demo candidates classified intentional / residual. | Flip to checklist fail only after FP classification + promotion criteria; change note [`../changes/2026-08-04_bloc_rebuild_scoping_qg-d03.md`](../changes/2026-08-04_bloc_rebuild_scoping_qg-d03.md). |
| **QG-D08** | Checklist UX | `CHECK_THEME` env filter | **ADR-deferred** | Needs subset runner tests so partial runs do not skip required fail gates. Non-blocking for Engineering scorecard. Agent speed win once safe. | Owner: [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md) § quality-gate promotion follow-up; spec `CHECK_THEME=navigation ./bin/checklist` + safety test before promotion. |
| **QG-D06** | Startup | `check_startup_work_in_build.sh` | **reject** | Overlaps `check_side_effects_build.sh`; duplicate signals for this repo. | Revisit only if side-effects script misses a class of startup-in-build violations with evidence. |
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
| Parallel static checks | `CHECK_SCRIPTS` (~85) run with `CHECKLIST_JOBS` (default CPU count, capped at 8). Prefer path auto-skip inside expensive scripts over dropping fail gates. | Expand per-script auto-skip only with fixture proof; do not thin CI. |
| Codex plan review (May 2026) | Three delegate runs aborted; no external review merged. | Optional re-run for open IDs only; not required for MVP closure. |

---

## Related docs

- MVP baseline & fixtures: [`checklist_quality_gates_baseline.md`](checklist_quality_gates_baseline.md)
- Change note: [`../changes/2026-05-20_checklist_quality_gates.md`](../changes/2026-05-20_checklist_quality_gates.md)
- Script catalog: [`../validation_scripts/catalog.md`](../validation_scripts/catalog.md) (Quality theme gates)
- Fast vs full routing: [`validation_routing_fast_vs_full.md`](validation_routing_fast_vs_full.md)
