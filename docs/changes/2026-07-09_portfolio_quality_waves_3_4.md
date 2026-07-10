# Portfolio quality waves 3–4 (2026-07-09)

## Wave 3 — Deferred gates

- Promoted **QG-D04** `check_context_read_watch.sh` (warn default, demo exclusions, fixtures)
- Resolved QG-D01/D03/D08 as **ADR-deferred**; QG-D06 **reject**
- Extended `check_engineering_quality_scorecard_gate.sh` for bare-defer detection

See [`2026-07-09_context_read_watch_qg-d04.md`](2026-07-09_context_read_watch_qg-d04.md).

## Wave 4 — Pattern program

- Migrated `AiDecisionState` to `@freezed sealed class`
- Updated [`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) (`ai_decision_demo` P4 → G)
- Scorecard Pattern program area → 10/10

## Wave 2 status (closed 2026-07-10)

- App-shell + feature tests + documented device/demo rollup exclusions
- Final proof: **85.47%** filtered / **76.04%** app shell
- See [`2026-07-10_coverage_core75_filtered85.md`](2026-07-10_coverage_core75_filtered85.md)
