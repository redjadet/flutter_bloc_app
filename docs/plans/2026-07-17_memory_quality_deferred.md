# Memory quality — intentionally deferred / incomplete (2026-07-17)

Owner index for what the A→B1 memory program **did not** finish. Current how-to
stays under [`docs/performance/memory_*.md`](../performance/memory_management.md).

## Merge / ops (open)

| ID | Item | Status | Unblock |
| --- | --- | --- | --- |
| **MQ-M01** | Wave B0 PR [#551](https://github.com/redjadet/flutter_bloc_app/pull/551) | OPEN → `main` | Review + merge |
| **MQ-M02** | Wave B1 PR [#552](https://github.com/redjadet/flutter_bloc_app/pull/552) | OPEN, base = B0 branch | Merge after #551; retarget to `main` if base branch disappears |
| **MQ-M03** | B1 CI `build` job | Was still in progress at doc time | Wait for green / fix if red |

Wave A [#550](https://github.com/redjadet/flutter_bloc_app/pull/550) is **merged**.

## Planned waves (not started)

| ID | Wave | Scope | Boundary |
| --- | --- | --- | --- |
| **MQ-B2** | B2 | Promote **only** proven product leak classes from ignore / dry-run evidence (`TextEditingController`, `ScrollController`, `FocusNode`, auth flow objects, `ParticleSystem`, …) | No global `withIgnoredAll()` removal until evidence supports it |
| **MQ-B3** | B3 | AST rules for timers / listeners (`Timer.periodic`, `addListener`/`removeListener`, `ChangeNotifier` fields) | Defer alias / GetIt / context-capture rules until FP rate is proven low |

Roadmap table: [`../performance/memory_management.md`](../performance/memory_management.md) § Wave B backlog.

## Explicit non-goals still open

| ID | Item | Why deferred |
| --- | --- | --- |
| **MQ-N01** | Flip default test suite off `withIgnoredAll()` | B0 baseline: ~49 tearDownAll leak fails, 309 `notDisposed` — mostly harness noise |
| **MQ-N02** | Wire dry-run into checklist / required CI | Report-only by design (`tool/run_memory_leak_tracking_dry_run.sh` always exits 0) |
| **MQ-N03** | Dedicated memory CI job / leak report artifact | Wave A/B use checklist stdout only |
| **MQ-N04** | Broad production ownership rewrite from dry-run list | Program priority is prevention automation, not fix-all-leaks |
| **MQ-N05** | Tag full `RealtimeMarketPage` + fl_chart under leak_tracker | Finalization hang; B1 uses thin `BlocBuilder` surface instead |
| **MQ-N06** | Retire shell `check_memory_*.sh` heuristics | Evaluate after B3+ AST coverage |

## B0 audit leftovers (optional / evidence)

From [`../audits/memory_quality_wave_b0_review_2026-07-17.md`](../audits/memory_quality_wave_b0_review_2026-07-17.md):

| ID | Item | Notes |
| --- | --- | --- |
| **MQ-E01** | Second-pass flake matrix on the 49 dry-run failing files | Single run only; pattern looked stable |
| **MQ-E02** | Separate harness (`GoRouter*`, images, `TextPainter`, gestures) vs product ignores before any B2 promotion | Required triage before ignore-list surgery |
| **MQ-E03** | Product-leaning dry-run classes not fixed in app code | Controllers / `ParticleSystem` / sparse auth flows — candidates for B2 journeys or production dispose fixes, not silently ignored |

## Lint surface still out of Wave A

Documented in [`../performance/memory_lints.md`](../performance/memory_lints.md) § Wave B exclusions:

- `Timer.periodic`
- `addListener` / `removeListener`
- `ChangeNotifier` fields
- GetIt singleton holding `BuildContext`
- Closure capture of disposables / context

These are **MQ-B3** (or later) unless a high-confidence narrow rule ships earlier.

## B1 delivered (not deferred)

For contrast — already on the B1 branch / PR #552:

- Auth route sign-out leak journey (`app_route_auth_gate_test.dart`)
- App-shell `go` + `NoTransitionPage`
- Realtime thin-surface teardown
- BLE tab leave → `leakSafeTestWidgets`
- Helper harness-layer ignore allowlist
- `tool/run_memory_leak_tests.sh` scoped tagged gate
- Docs under `docs/performance/memory_*.md` + B0/B1 audits/changes

## Related

- [`../performance/memory_management.md`](../performance/memory_management.md)
- [`../performance/memory_testing.md`](../performance/memory_testing.md)
- [`../performance/memory_ci.md`](../performance/memory_ci.md)
- [`../audits/memory_quality_wave_b0_review_2026-07-17.md`](../audits/memory_quality_wave_b0_review_2026-07-17.md)
- [`../audits/memory_quality_wave_b1_review_2026-07-17.md`](../audits/memory_quality_wave_b1_review_2026-07-17.md)
