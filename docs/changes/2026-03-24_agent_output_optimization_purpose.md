# Agent Output Optimization: Change Purpose

## Status

This is a **historical change-note** explaining intent and constraints for a
specific iteration. Prefer current repo workflow docs and scripts for active
guidance (for example `docs/validation_scripts.md`, `docs/testing_overview.md`,
and the repo `bin/` scripts).

## Why these changes were made

These changes establish a measurable, safer, and more predictable workflow for
AI-assisted coding in this repository. The main objective is to improve delivery
speed for low/medium-risk work without weakening quality gates.

## Primary goals

- Add machine-readable telemetry for checklist, integration, and delegate runs.
- Make delegation decisions more risk-based and less ad hoc.
- Harden delegate wrappers to reduce flaky behavior and retry churn.
- Improve router/auth validation trigger precision.
- Provide scorecard reporting and week-over-week comparison artifacts.
- Preserve existing validation standards (`checklist`, router validation,
  integration tests) while improving observability.

## What was introduced

- Scorecard event emission and canonical storage:
  - `tool/emit_agent_scorecard_event.sh`
  - `analysis/agent_scorecard/scorecard-events.jsonl`
  - `analysis/agent_scorecard/archive/`
  - `analysis/agent_scorecard/summaries/`
- Scorecard reporting and trend comparison:
  - `tool/build_agent_scorecard_summary.sh`
  - `tool/agent_scorecard_weekly_compare.sh`
  - `tool/verify_agent_rollout_gates.sh`
- Delegate wrapper hardening:
  - profile controls (`fast`, `balanced`)
  - model override/cache behavior
  - contract checks (`tool/check_delegate_wrapper_contracts.sh`)
  - repo-native Codex feedback helper (`tool/request_codex_feedback.sh`)
  - non-raw stderr heartbeat/status output so host agents do not misread quiet
    delegate runs as hangs
  - delegate-only Firebase MCP disable path (`--skip-firebase-mcp` /
    `DELEGATE_SKIP_FIREBASE_MCP=1`) instead of relying on global Codex config
- Trigger benchmark and precision check:
  - `analysis/agent_scorecard/router_trigger_benchmark_v1.json`
  - `tool/check_router_trigger_precision.sh`
- Supporting docs and workflow guidance:
  - `docs/engineering/agent_output_scorecard_v1.md`
  - `docs/engineering/validation_routing_fast_vs_full.md`

## Expected operational impact

- Better visibility into execution quality and throughput trends.
- Faster diagnosis of agent workflow regressions.
- Reduced unnecessary delegation on low-risk tasks.
- More consistent validation routing for router/auth related changes.

## Non-goals

- No removal or weakening of existing quality checks.
- No mandatory external telemetry service dependency.
- No replacement of existing gstack/delegate ecosystem.

## Quick usage

```bash
./tool/check_delegate_wrapper_contracts.sh
./tool/request_codex_feedback.sh --base main
./tool/check_router_trigger_precision.sh
./tool/build_agent_scorecard_summary.sh
./tool/agent_scorecard_weekly_compare.sh
./tool/verify_agent_rollout_gates.sh
```
