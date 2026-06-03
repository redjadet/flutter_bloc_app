# Code quality baseline and gate promotion (2026)

**Status:** Shipped on `main` via [PR #290](https://github.com/redjadet/flutter_bloc_app/pull/290) (2026-06-03). Phase 2: re-baseline on `main` after next checklist run; flip D05/D07 to fail when backlog allows.
**Priority:** Balanced — baseline audit, then one vertical slice per cadence.

## Artifacts

| Artifact | Path |
| --- | --- |
| Baseline | [code_quality_baseline_2026-06-03.md](../audits/code_quality_baseline_2026-06-03.md) |
| Gate spikes | [code_quality_baseline_spikes_2026-06-03.md](../audits/code_quality_baseline_spikes_2026-06-03.md) |

## Phase 2 follow-ups (post-merge)

| Item | Status (2026-06-03) | Action |
| --- | --- | --- |
| Re-baseline on clean `main` | Done | `./bin/checklist-fast`, gates, modular_metrics, integration_preflight — see [baseline audit](../audits/code_quality_baseline_2026-06-03.md) post-merge table |
| iOS integration (standard) | Done | `CHECKLIST_INTEGRATION_DEVICE=<sim> INTEGRATION_TESTS_TIER=standard ./bin/integration_tests` |
| Full `./bin/checklist` on `main` | Pre-merge proof | Rerun before next release if `lib/` changed since PR #290 |
| Integration exhaustive | Open | `INTEGRATION_TESTS_TIER=exhaustive` when macOS CI skipped |
| Flip D05/D07 warn → fail | Open | Only when deferred doc unblock criteria met |
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
