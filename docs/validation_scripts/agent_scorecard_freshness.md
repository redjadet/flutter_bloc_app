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

## Related

- [`agent_output_scorecard_v1.md`](../engineering/agent_output_scorecard_v1.md)
- [`../../analysis/agent_scorecard/summaries/scorecard-summary.md`](../../analysis/agent_scorecard/summaries/scorecard-summary.md)
