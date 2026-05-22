---
name: upgrade-pr-triage-validate
description: Triage open non-draft PRs on main, merge/close/make-ready, run upgrade_validate_all, then PR and merge the resulting artifacts.
allowed-tools:
  - Shell(git:*)
  - Shell(gh:*)
  - Shell(flutter:*)
  - Shell(dart:*)
  - Read
  - Glob
  - ApplyPatch
  - AskQuestion
when_to_use: >
  Main cleanup + upgrade lane. Triggers: "/upgrade-validate-all", "upgrade validate all",
  "run upgrade lane", "triage PRs then upgrade", "merge open renovate PRs then run validation".
argument-hint: "[$base_branch=main] [$fix_rounds=3]"
arguments:
  - base_branch
  - fix_rounds
context: inline
---

# Upgrade PR triage + validate

**Procedure (canonical):** [`docs/validation_scripts/upgrade_pr_triage_validate.md`](../../../../../docs/validation_scripts/upgrade_pr_triage_validate.md)

**Canon:** `AGENTS.md`, `docs/agents_quick_reference.md`, `docs/engineering/validation_routing_fast_vs_full.md`

**Inputs:** `$base_branch` (default `main`), `$fix_rounds` (default `3`).

**Gates:** no force-push `$base_branch`; clean worktree. Lane: `SKIP_PUB_UPGRADE=1 ./bin/upgrade_validate_all`; `SKIP_PUB_UPGRADE=1 SYNC_AGENT_ASSETS=skip ./bin/upgrade_validate_all`
