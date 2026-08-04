# QG-D03: Bloc rebuild scoping inventory (warn, not checklist) — 2026-08-04

## Summary

Shipped **report-only** `tool/check_bloc_rebuild_scoping.sh` with fixtures and
harness triad. Default **warn** (exit 0 with candidates). **Not** added to
`CHECK_SCRIPTS` / checklist themes. Does not fail the delivery gate.

## Changes

- Script: `--paths`, `CHECK_BLOC_REBUILD_SCOPING_MODE=warn|fail`, `check-ignore`,
  demo exclusion, presentation-only; matches `BlocBuilder`/`BlocConsumer` not
  `TypeSafeBloc*`
- Fixtures: `tool/fixtures/bloc_rebuild_scoping/presentation/{good,bad,suppressed}.dart`
- Harness fixtures in `tool/run_harness_fixtures.sh`
- Deferred backlog: **promoted (warn)** inventory; spikes updated

## Inventory (non-demo, 2026-08-04)

| File | Line region | Classification |
| --- | --- | --- |
| `scapes/.../scapes_page.dart` | BlocBuilder | intentional-full-state (list body) |
| `production_readiness/.../production_readiness_page.dart` | BlocBuilder | intentional-full-state ownership view |

## Verification

```bash
bash tool/run_harness_fixtures.sh
bash tool/check_bloc_rebuild_scoping.sh
```

## Explicit non-promotion

No fail-default and no checklist wiring in this program.
