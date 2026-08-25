# Agent scorecard freshness

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Purpose

Rejects a generated scorecard summary when its source fingerprint does not
match current active or archived event inputs. Prevents stale summaries from
acting as quality evidence.

## Command

```bash
bash tool/check_agent_scorecard_freshness.sh
```

## Refresh

Run after event-stream changes, then re-run the freshness check:

```bash
./tool/build_agent_scorecard_summary.sh
bash tool/check_agent_scorecard_freshness.sh
```

`./bin/agent-maintain closeout` enforces this check before task completion.

## Land on `main` (no PR when summary-only)

When the **only** dirty/committed paths are:

- `analysis/agent_scorecard/summaries/scorecard-summary.json`
- `analysis/agent_scorecard/summaries/scorecard-summary.md`

commit and **push directly to `main`**. Do **not** open a PR for regenerable
summary refresh. If any other path is included, use the normal PR flow.

Operator preference: [`../agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md)
§ Durable Prefs. Git note: [`../git_and_branching_strategy.md`](../git_and_branching_strategy.md).

## Related

- [`agent_output_scorecard_v1.md`](../engineering/agent_output_scorecard_v1.md)
- [`../../analysis/agent_scorecard/summaries/scorecard-summary.md`](../../analysis/agent_scorecard/summaries/scorecard-summary.md)
