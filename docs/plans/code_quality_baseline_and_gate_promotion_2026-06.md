# Code quality baseline and gate promotion (2026)

**Status:** Phase 0a/0b + PR2 gates + PR3 Graphql `AppError` slice landed in workspace (2026-06-03). Re-run `./bin/checklist` before merge claims.
**Priority:** Balanced — baseline audit, then one vertical slice per cadence.

## Artifacts

| Artifact | Path |
| --- | --- |
| Baseline | [code_quality_baseline_2026-06-03.md](../audits/code_quality_baseline_2026-06-03.md) |
| Gate spikes | [code_quality_baseline_spikes_2026-06-03.md](../audits/code_quality_baseline_spikes_2026-06-03.md) |

## Remaining proof (before merge)

| Item | Action |
| --- | --- |
| Full checklist | `./bin/checklist` after catalog sync |
| Integration exhaustive | Honesty matrix only unless sim proof exists |

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
