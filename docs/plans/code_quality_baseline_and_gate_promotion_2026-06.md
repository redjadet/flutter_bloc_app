# Code quality baseline and gate promotion (2026)

**Status:** PR [#290](https://github.com/redjadet/flutter_bloc_app/pull/290) merged 2026-06-03. Phase 2 in open PR [#292](https://github.com/redjadet/flutter_bloc_app/pull/292) (D05/D07 fail default, MapSample `AppError`). **Cursor plan todos:** `.cursor/plans/flawless_quality_program_f3279390.plan.md`.
**Priority:** Balanced — baseline audit, then one vertical slice per cadence.

## Artifacts

| Artifact | Path |
| --- | --- |
| Baseline | [code_quality_baseline_2026-06-03.md](../audits/code_quality_baseline_2026-06-03.md) |
| Gate spikes | [code_quality_baseline_spikes_2026-06-03.md](../audits/code_quality_baseline_spikes_2026-06-03.md) |

## Todos (sync with Cursor plan)

| ID | Task | Status |
| --- | --- | --- |
| `phase-0a-snapshot` | Baseline audit snapshot | Done |
| `phase-0b-gate-spikes` | Gate spike tickets (D07/D05 minimum) | Done |
| `slice-1-audit-pr` | PR1 audit + CODE_QUALITY status | Done — #290 |
| `slice-2-gate-or-arch` | QG-D05/D07 warn-first promotion | Done — #290 |
| `slice-3-arch-plus-tests` | Graphql `AppError` slice | Done — #290 |
| `sustain-crosslinks` | Deferred backlog + changes notes | Done |
| `phase-2-gates-fail-flip` | D05/D07 default `fail` | Done — #292 (open) |
| `phase-2-maps-apperror` | MapSample `lastError` + retry | Done — #292 (open) |
| `phase-2-checklist-proof` | `./bin/checklist` + standard integration | Done — branch |
| `pr-292-merge` | Merge #292; checklist on `main` | **Pending** |
| `phase-2-spikes-remaining` | D03/D04/D08 spikes; next arch surface; exhaustive iOS | Open |

## Phase 2 follow-ups (post-merge)

| Item | Status (2026-06-03) | Action |
| --- | --- | --- |
| Re-baseline on clean `main` | Done | `./bin/checklist-fast`, gates, modular_metrics, integration_preflight — see [baseline audit](../audits/code_quality_baseline_2026-06-03.md) post-merge table |
| iOS integration (standard) | Done | `CHECKLIST_INTEGRATION_DEVICE=<sim> INTEGRATION_TESTS_TIER=standard ./bin/integration_tests` — 22/22 |
| Full `./bin/checklist` on `main` | Pending #292 | Proved on branch; rerun on `main` after merge |
| Integration exhaustive | Open | Local Xcode SPM prefetch failure; retry in CI or after `flutter clean` |
| Flip D05/D07 warn → fail | Done (#292) | Default `fail`; 0 violations on `lib/` |
| MapSample `AppError` | Done (#292) | Chart-aligned `lastError` + retry |
| Next arch slice / gate spike | Open | See baseline backlog B-05+ and [spikes](../audits/code_quality_baseline_spikes_2026-06-03.md) |

## Quick start (Day 1)

```bash
git checkout main && git pull --ff-only && git status --short
./bin/checklist && ./bin/checklist-fast
bash tool/modular_metrics.sh && bash tool/modular_metrics.sh --cross-feature-only
./bin/integration_preflight
```

Copy audit + spike templates from Cursor plan § **Build readiness** and § **Phase 0a**.

## Execution order

1. **PR1** — Phase 0a audit + [`audits/README.md`](../audits/README.md) link + [`CODE_QUALITY.md`](../CODE_QUALITY.md) status (top 3 gaps)
2. **0b** — Spikes for QG-D07, QG-D05 (minimum)
3. **PR2** — One gate (D07 or D05 warn-first)
4. **PR3** — One future-architecture slice (pick one option from owner doc)
5. **Optional PR4** — Second gate or sustain cross-links (not same week as PR3)

Do not combine PR2 + PR3 in one PR.

## Canonical owners

- Deferred gates: [`checklist_quality_gates_deferred.md`](checklist_quality_gates_deferred.md)
- Architecture slices: [`future_architecture_code_quality_improvement_plan.md`](future_architecture_code_quality_improvement_plan.md)
- Enforcement: [`../validation_scripts/catalog.md`](../validation_scripts/catalog.md), `./bin/checklist`

## Definition of done (program)

Checklist green on `main` (or documented exception), baseline audit with zero undocumented P0, ≥1 gate promoted or rejected with criteria, ≥1 named future-plan slice with tests, cross-feature imports not increasing (`tool/modular_metrics.sh --cross-feature-only`).
