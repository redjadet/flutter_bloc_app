# Agent docs and host-sync conflict repair

## Problem

Canonical AI path maps still routed shared and DI work into deleted
`apps/mobile/lib/shared/` and `apps/mobile/lib/core/` trees. Cursor's always-on
`agent-execution.mdc` existed as a template, but sync and drift checks omitted
its required project-local copy.

## Decision

- Route shared ownership to `packages/*` and app composition to
  `apps/mobile/lib/app/`.
- Normalize cwd-sensitive run commands: after `cd apps/mobile`, targets use
  `lib/main_dev.dart`.
- Treat `agent-execution.mdc` as an explicit project-only managed asset:
  synchronize it into workspace `.cursor/rules/`, never `~/.cursor/rules`.
- Guard current path ownership and project-rule registration through agent
  knowledge-base and CLI-contract checks.

## Proof

Run agent knowledge-base, failure-risk, harness scorecard, checklist CLI,
fresh checklist-fast, and agent-maintain closeout gates.
