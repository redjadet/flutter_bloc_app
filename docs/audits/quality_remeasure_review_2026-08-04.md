# Quality re-measure review — 2026-08-04 (PR0)

Fresh evidence-only audit for the quality re-measure program. **No product
behavior change and no gate mode flips in this commit.** Local artifacts under
`tmp/quality_remeasure_pr0/` and `tmp/memory_leak_dry_run/` (gitignored).

## Meta

| Field | Value |
| --- | --- |
| Branch | `quality/remeasure-wave0` |
| Baseline (branch point) | `516a06de` on `main` (clean vs `origin/main`) |
| Date (UTC) | 2026-08-04 |
| Dirty tree at start | none |
| Agent | PR0 only; PR1–3 blocked on Ranking decision below |

## Results table

| Area | Exact command | Exit / measured result | Evidence path or output | Decision impact |
| --- | --- | --- | --- | --- |
| Engineering scorecard | `bash tool/check_engineering_quality_scorecard_gate.sh` | 0; enforced filtered 86.20% then post-coverage refresh 85.10%; core ≥75% | stdout `tmp/quality_remeasure_pr0/scorecards_modularity.log` | No stop; still claim-capable |
| Engineering badge | `bash tool/update_engineering_quality_badge.sh --check` | 0; `10/10` | same log | No badge rewrite required this PR |
| Harness scorecard | `bash tool/check_harness_scorecard_gate.sh` | 0 | same log | No stop |
| Harness badge | `bash tool/update_harness_score_badge.sh --check` | 0; `10/10` | same log | No stop |
| Cross-feature edges | `bash tool/modular_metrics.sh --cross-feature-only` | exit 0; **8 edges** (not zero) | `tmp/quality_remeasure_pr0/cross_feature.txt` | Honesty note (below); does **not** re-rank PR1–3 |
| Clean Architecture | `bash tool/check_clean_architecture_imports.sh` | 0 | scorecards log | No stop |
| Modularity leaks | `bash tool/check_feature_modularity_leaks.sh` | 0 | scorecards log | No stop |
| Unit coverage refresh | `bash tool/test_coverage.sh` | 0; suite `+2800 ~4`; filtered **85.10%** | `tmp/quality_remeasure_pr0/test_coverage.log`; local [`coverage/coverage_summary.md`](../../coverage/coverage_summary.md) (gitignored) | Badge prose update only |
| Coverage 85% enforce | `COVERAGE_THRESHOLD=85 dart run tool/update_coverage_summary.dart --enforce-threshold` | 0 at **85.10%** | `tmp/quality_remeasure_pr0/coverage_enforce.log` | Still above Engineering Coverage 10/10 floor |
| App-shell coverage | `bash tool/check_engineering_core_coverage.sh` | 0 at **75.53%** (1398/1851) | `tmp/quality_remeasure_pr0/core_coverage.log` | Above ≥75% floor (was 79.25% pre-refresh using older lcov) |
| D04 fixture good | `CHECK_CONTEXT_READ_WATCH_MODE=fail … --paths …/good.dart` | 0 | `tmp/quality_remeasure_pr0/d04.log` | Contract OK |
| D04 fixture bad | `…/bad.dart` | **1** (expected) | d04.log | Contract OK |
| D04 fixture suppressed | `…/suppressed.dart` | 0 | d04.log | Contract OK |
| D04 full production scope | `CHECK_CONTEXT_READ_WATCH_MODE=fail bash tool/check_context_read_watch.sh` (default `lib/features` under `APP_ROOT`) | **0 unsuppressed hits** | `tmp/quality_remeasure_pr0/d04_full_scope.txt` | **PR1 fail flip unblocked** |
| Memory lint | `bash tool/run_memory_lint.sh` | 0 | `tmp/quality_remeasure_pr0/memory_lint.log` | No stop |
| Tagged leak journeys | `bash tool/run_memory_leak_tests.sh` | 0; `+8` | `tmp/quality_remeasure_pr0/memory_leak_tests.log` | B1 journeys still green |
| Dry-run A | `MEMORY_LEAK_DRY_RUN_STAMP=quality_remeasure_a bash tool/run_memory_leak_tracking_dry_run.sh` | wrapper 0; `flutter_test_exit=1`; `notDisposed: 310`; leak-shaped failures **19** | `tmp/memory_leak_dry_run/quality_remeasure_a/` | B2 dual-run stamp 1 |
| Dry-run B | `MEMORY_LEAK_DRY_RUN_STAMP=quality_remeasure_b …` | wrapper 0; `flutter_test_exit=1`; `notDisposed: 310`; leak-shaped failures **20** | `tmp/memory_leak_dry_run/quality_remeasure_b/` | B2 dual-run stamp 2 |

## Cross-feature honesty note

`modular_metrics --cross-feature-only` lists **8** import edges, all
`production_readiness` → `fcm_demo` domain types (cubit, state, page). Clean-arch
and modularity-leak scripts pass; Engineering scorecard gate still exit 0 with
badge **10/10**. Historical audits claimed **0** edges; that claim is **stale**.

| From | To | Files (paths under `apps/mobile`) |
| --- | --- | --- |
| `production_readiness` | `fcm_demo` | `…/production_readiness_cubit.dart` (4 imports), `…/production_readiness_state.dart` (2), `…/production_readiness_page.dart` (2) |

**Decision:** document only in PR0. Does **not** reorder PR1–3. Future optional
work (outside this program unless reopened): extract shared FCM ports into
composition / shared package so showcase modularity claim matches metrics.

## D04 detail

### Fixture triad (fail mode)

| Fixture | Exit | Notes |
| --- | ---: | --- |
| `good.dart` | 0 | No false positive |
| `bad.dart` | 1 | Flags `context.watch` in `build` |
| `suppressed.dart` | 0 | `check-ignore` honored |

### Full production scope

- Scope semantics: presentation under `apps/mobile/lib/features/**` excluding `*_demo/**` (via `check_helpers` → `APP_ROOT`).
- **Unsuppressed production hits: 0**
- **Suppressed production hits: 0** (no IGNORED lines printed)
- Older change-note wording about “held-out router/widget” is **incorrect** for this checker; scope is presentation-only (recorded here for ranking honesty).

**Harness fixtures:** still **absent** for D04 in `tool/run_harness_fixtures.sh` — intentional PR1 work.

## Memory dry-run dual compare

| Metric | quality_remeasure_a | quality_remeasure_b |
| --- | ---: | ---: |
| `flutter_test_exit` | 1 | 1 |
| `notDisposed` total | 310 | 310 |
| Leak-shaped failures | 19 | 20 |
| Non-leak failures | 0 | 0 |
| Window (UTC) | 15:58:21 → 16:02:47 | 16:03:13 → 16:07:18 |

### Class counts (intersection of top product-candidate heuristics)

| Class | A count | B count | Stable both runs? | Ownership bucket |
| --- | ---: | ---: | :---: | --- |
| `TextEditingController` | 32 | 32 | yes | **product** — forms/chat input (B0 MQ-E03); B1 has thin controller lifecycle tagged test |
| `ParticleSystem` | 24 | 21 | yes (slight count drift) | **product/demo** — counter particle effect |
| `ScrollController` | 13 | 13 | yes | **product** — list surfaces |
| `FocusNode` | 3 | 3 | yes | **product** (sparse) |
| `EmailAuthFlow` / `OAuthFlow` | 1 / 1 | 1 / 1 | yes | **product/auth** sparse |
| `ValueNotifier<double>` | 1 | 1 | yes | sparse product/notifier |
| `GoRouteInformationProvider` / `GoRouterDelegate` | 46 / 46 | 46 / 46 | yes | **harness/router** test disposal |
| `TextPainter` | 47 | 47 | yes | **framework** |
| `ImageStreamCompleterHandle` / `_LiveImage` | 32 / 31 | 32 / 31 | yes | **framework/image** |
| Gesture recognizers (Tap/Pan/LongPress) | 11/10/10 | 11/10/10 | yes | **framework/gesture** |
| `TransformLayer` | 2 | 2 | yes | **framework/layer** (also in B1 harness layer ignore list) |

**B1 journey overlap (tagged `memory_leak`, still green):** app-shell route
replacement, auth gate teardown, GoRouter dispose, BLE tab leave, realtime thin
surface, controller dispose smoke, AppScope smoke — see
`bash tool/run_memory_leak_tests.sh` (+8).

**B2 candidacy (stable both runs, product bucket):** prioritize
`TextEditingController`, then `ScrollController` / `ParticleSystem`, with
ownership path proven in PR2 write-set discovery. Do **not** promote harness
classes. Do **not** remove global `withIgnoredAll()` (MQ-N01).

## Coverage hotspots (fresh unit rollup, filtered)

Filtered total **85.10%** (18915/22226). Prefer non-demo / non-device-only for
coverage fallback. Sample **in-scope-ish** low rows (from local summary; not
committed):

| Lib path (under `apps/mobile`) | Coverage |
| --- | ---: |
| `todo_list/.../todo_list_date_picker.dart` | 10% |
| `auth/.../profile_page.dart` | 11.11% |
| `todo_list/.../todo_list_page_app_bar.dart` | 25% |
| `counter/.../counter_sync_queue_inspector_button.dart` | 34.72% |
| `todo_list/.../todo_list_content.dart` | 38.89% |

Many `0%` rows are 1-line configs/adapters or demo/device surfaces — poor
fallback targets per plan.

Tracked prose: [`README.md`](README.md) coverage badge `86.24%` → **`85.10%`** from
`test_coverage.sh` (included in this PR because rollup truly refreshed).

## Ranking decision (sole authority for PR1+)

Score 0–3 each for: scorecard/checklist risk, evidence quality, fixability
without ADR expansion. Total descending. Tie-break: existing warn gate before
new script.

| Candidate | Risk | Evidence | Fixability | Total | Next PR action | Status |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| **QG-D04 fail flip** | 3 | 3 (0 prod hits + fixtures) | 3 | **9** | **PR1** — default `MODE=fail` + harness fixtures + engineering deferred row | **Locked first** |
| **MQ-B2** | 2 | 3 (dual full dry-run) | 2 (ownership TBD) | **7** | **PR2** — promote only dual-stable product classes with dispose proof; else coverage fallback | **Locked second** |
| **QG-D03 inventory** | 1 | 2 | 3 (report-only) | **6** | **PR3** — script + fixtures + classify; never fail/checklist wire | **Locked third** |
| Coverage fallback | 1 | 3 | 2 | 6 | Use **only if** PR2 finds no promotable product class | Standby for PR2 body |
| Cross-feature FCM edge reduction | 2 | 3 | 2 | 7 | **Out of this program** unless a later reopen elevates modularity honesty | Deferred separate |
| `staff_app_demo` Firestore maps | — | — | — | — | Excluded (ADR / scorecard exception) | Excluded |
| QG-D01 / QG-D08 / MQ-N01/N02 / auth SDKs | — | — | — | — | Stay ADR or intentional non-goal | Deferred |

### Provisional order confirmed

**PR1 D04 fail → PR2 B2 (or coverage fallback) → PR3 D03 report-only.**

PR1 additional gate from residual: **zero unsuppressed production hits — met.**

## Explicit non-starts (this PR)

- No `CHECK_CONTEXT_READ_WATCH_MODE` default change
- No product dispose/promotion code
- No D03 script
- No checklist wiring changes
- No commit of `coverage/lcov*.info` / [`coverage/coverage_summary.md`](../../coverage/coverage_summary.md)

## Proof commands (reproduce)

See Results table. Minimal re-check:

```bash
bash tool/check_engineering_quality_scorecard_gate.sh
CHECK_CONTEXT_READ_WATCH_MODE=fail bash tool/check_context_read_watch.sh
bash tool/run_memory_leak_tests.sh
# full dual dry-run only if re-ranking B2 (multi-minute each):
MEMORY_LEAK_DRY_RUN_STAMP=quality_remeasure_a bash tool/run_memory_leak_tracking_dry_run.sh
MEMORY_LEAK_DRY_RUN_STAMP=quality_remeasure_b bash tool/run_memory_leak_tracking_dry_run.sh
```
