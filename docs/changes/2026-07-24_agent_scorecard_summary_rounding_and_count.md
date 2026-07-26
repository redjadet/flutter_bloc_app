# Agent scorecard summary rounding + outcome count fix

## Summary

Fixed two agent scorecard summary bugs:

1. Markdown `p50`/`p95` used `int()`, which truncates fractional medians
   (`28718.5` → `28718ms`). Display now rounds half away from zero
   (`28719ms`). Note: Python `round()` is bankers and would also keep
   even `.5` values truncated — do not use it for these displays.
2. Command `count` included `cancelled`/`aborted` events but only
   tallied `ok`/`failed`, so `integration_tests` showed `210` vs
   `150+59=209`. Outcome fields now include `cancelled`, `aborted`, and
   `other` (`invalid` still folds into `failed`); `count` equals their sum.

## Changes

- `tool/build_agent_scorecard_summary.sh` — rounding helper, full outcome
  tallies, `--self-test`, rebuild summaries
- `tool/agent_scorecard_weekly_compare.sh` — same display rounding
- `tool/run_harness_fixtures.sh` — wires `--self-test`
- [`engineering/agent_output_scorecard_v1.md`](../engineering/agent_output_scorecard_v1.md) — summary invariants
- Regenerated `analysis/agent_scorecard/summaries/scorecard-summary.{json,md}`
  and weekly compare artifacts

## Verification

```bash
./tool/build_agent_scorecard_summary.sh --self-test
./tool/build_agent_scorecard_summary.sh
bash tool/check_agent_scorecard_freshness.sh
```

Proof: `checklist` p50 `28719ms`, `integration_tests` p50 `250725ms`,
`integration_tests.cancelled=1` and `count == ok+failed+cancelled+aborted+other`.
