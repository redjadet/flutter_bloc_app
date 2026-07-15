# Agent safety contracts

**Date:** 2026-07-15

## Why

Agent safety guidance was distributed across [`AGENTS.md`](../../AGENTS.md), adaptive execution,
the risk register, Git/security docs, the finish gate, and host templates.
Agents needed one canonical owner with stable IDs (`SAFETY-01..06`,
`SAFETY-REPORT`) plus a deterministic drift gate.

## What changed

- Added [`docs/agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md)
  as the canonical summary with deep-owner links.
- Added `RISK-SCOPE-CREEP`, `RISK-MISSING-TARGET`, and `RISK-UNAPPROVED-GIT`
  to the AI failure risk register.
- Added `tool/check_agent_safety_contracts.sh` and harness fixtures.
- Wired thin pointers in maps, context loader, operating manual, finish gate,
  common-pitfalls skill, and `agent-execution.mdc` template.
- Refreshed `ai/` discovery snapshots via `bash tool/refresh_ai_reports.sh` so
  `git_head` metadata matches current HEAD and strict-head fixtures pass.

## Proof (2026-07-15)

| Lane | Result |
| --- | --- |
| `bash tool/check_agent_safety_contracts.sh` | pass |
| `bash tool/check_ai_failure_risk_register.sh` | pass |
| `bash tool/check_agent_knowledge_base.sh` | pass |
| `bash tool/check_harness_scorecard_gate.sh` | pass |
| `bash tool/check_ai_snapshot_freshness.sh --strict-head` | pass |
| `bash tool/run_harness_fixtures.sh` | pass |
| `bash tool/validate_validation_docs.sh` | pass |
| `./bin/checklist-fast --no-reuse` | pass |
| `./bin/agent-maintain after-host-edit` | pass (same-turn approved) |
| `./bin/agent-maintain closeout` | pass |
