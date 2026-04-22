# Integration metrics baseline (rollout)

Use this table to track integration health before and after runner or suite
changes. Populate from:

- `artifacts/integration/<timestamp>/summary.json` (local or CI artifacts)
- `tool/agent_scorecard_weekly_compare.sh` / scorecard events where configured

| Metric                              | Baseline | Current | Target (example)        | Notes                         |
| ----------------------------------- | -------- | ------- | ----------------------- | ----------------------------- |
| Flake rerun rate                    | TBD      | TBD     | ≤ 60% of baseline       | from `retried` + events       |
| Median integration runtime          | TBD      | TBD     | tier-dependent          | `duration_ms` in summary      |
| p95 integration runtime             | TBD      | TBD     |                         | aggregate from history        |
| Journey coverage (J1–J4)            | TBD      | TBD     | 100% must-have          | `integration_journey_map`     |
| Uncategorized failures              | TBD      | TBD     | 0                       | `failure_category`            |

When CI integration is manual-only, collect timing from workflow runs or local
`./bin/integration_tests` with same `INTEGRATION_TESTS_TIER` you care about.
