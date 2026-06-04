---
name: agent-maintain
description: Run repo agent host maintenance or composed workflows (sync, globals, routine, host-full). Usage /agent-maintain
---

# agent-maintain

Route host upkeep through the repo entrypoint — do not hand-compose long shell chains.

**Agents:** run maintenance yourself per [`docs/agent_kb/host_maintenance_automation.md`](../../../docs/agent_kb/host_maintenance_automation.md) — do not only tell the user to run scripts.

## When to use

- **Task start / non-trivial work:** `preflight` (read-only)
- **Before claiming any task done:** `closeout` (preflight + scope `docs-sync` / `after-host-edit` / `kb`)
- **Validation-doc or markdown-only edits in scope:** `docs-sync` (or rely on `closeout`)
- After editing `tool/agent_host_templates/**`: `after-host-edit` **immediately** (same turn; `closeout` runs it when templates are in scope)
- Weekly/light host upkeep (`routine`)
- New machine or Cursor profile (`host-full` with `--apply`)
- Start of session (`preflight` or `session`)
- Before claiming globals are current (`inventory`, `update --check`)

## Commands (copy/paste)

```bash
# Agents: task start
./bin/agent-maintain preflight

# Agents: after tool/agent_host_templates/** edits (run before claiming done)
./bin/agent-maintain after-host-edit

# Agents: before claiming task done (preflight + scope host + docs-sync)
./bin/agent-maintain closeout

./bin/agent-maintain session
./bin/agent-maintain sync --apply
./bin/agent-maintain routine --apply
./bin/agent-maintain host-full --apply
./bin/agent-maintain find flutter responsive
./bin/agent-maintain list
```

## Closed loop

1. Pick command from `./bin/agent-maintain help` or `list`.
2. Use `--apply` only when intentionally mutating host files.
3. After `--apply` on sync/setup/host-full: **reload Cursor** (Developer: Reload Window).
4. Repo canon (`AGENTS.md`, `docs/`) wins over vendor globals.

## Not changed (by design)

- `closeout` runs `after-host-edit` / `kb` / `docs-sync` only when those paths are in **git scope** (empty scope → no host sync).
- Contract tests use `AGENT_MAINTAIN_PLAN_ONLY=1` — they assert **plans**, not live `sync --apply` (would mutate `~/.cursor`).
- `docs-sync` updates indexes/links/counts; agents still write narrative doc content.
- `preflight` and dry-run `sync` **warn** on drift; strict drift only after `--apply` / template closeout paths.

Table: `docs/agent_kb/host_maintenance_automation.md` (section **Not changed (by design)**).

Detail: `docs/agent_environment_setup.md`, `docs/validation_scripts/operations_host_skills.md`.
