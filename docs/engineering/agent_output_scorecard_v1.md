# Agent Output Scorecard v1

This document defines the v1 measurement contract for agent productivity and
quality in this repository.

## Canonical Artifacts

- Event schema: `analysis/agent_scorecard/schema_v1.json`
- Active event stream: `analysis/agent_scorecard/scorecard-events.jsonl`
- Archived events: `analysis/agent_scorecard/archive/scorecard-events-YYYY-MM-DD.jsonl.gz`
- Derived summaries:
  - `analysis/agent_scorecard/summaries/scorecard-summary.json`
  - `analysis/agent_scorecard/summaries/scorecard-summary.md`

## Writer/Rotation Contract

- Emitters always append to `analysis/agent_scorecard/scorecard-events.jsonl`.
- Emitters never write directly to dated files.
- Rollover runs at UTC day boundary and renames prior day data to
  `scorecard-events-YYYY-MM-DD.jsonl`.
- Keep 30 days hot in `analysis/agent_scorecard/`.
- Compress and move older daily files to `analysis/agent_scorecard/archive/`.
- Summary/report tooling must read both active and archived files.

## Event Correlation and Dedupe

- `task_id`: stable unit-of-work id across retries.
- `run_id`: unique id for one attempt.
- `attempt`: increment per retry.
- `dedupe_key`: `task_id + command + attempt + started_at`.
- Invalid or partial artifacts must be retained and flagged with
  `invalid_partial=true`.

## Risk Taxonomy

| Risk | Typical Scope | Delegation Default | Validation Default |
| --- | --- | --- | --- |
| `low` | docs-only, tiny single-file edits | no delegate | targeted checks |
| `medium` | non-trivial local implementation and script changes | optional bounded sidecar review | `./bin/checklist` |
| `high` | routing/auth/validation/rollout behavior changes | bounded sidecar strongly preferred | `./bin/router_feature_validate` and/or `./bin/integration_tests` |
| `unknown` | uncategorized | treat as medium until classified | `./bin/checklist` |

## KPI Definitions

- Time-to-green: elapsed time from first run attempt until first full required
  validation pass for a task.
- Scorecard coverage: percent of relevant runs emitting valid scorecard events.
- Trigger precision: true-positive routes / all positive routes.
- Trigger recall: true-positive routes / all routes that should be positive.
- Unnecessary delegation rate: delegated low-risk runs / total low-risk runs.

## Commands

- Generate summary:

```bash
./tool/build_agent_scorecard_summary.sh
```

- Validate broad health:

```bash
./bin/checklist
```
