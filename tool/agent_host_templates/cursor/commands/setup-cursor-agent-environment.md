---
name: setup-cursor-agent-environment
description: Sync repo Cursor/Codex adapters, optionally install global vendor skills, trim duplicates, and refresh skill inventory. Usage /setup-cursor-agent-environment
---

# setup-cursor-agent-environment

Run the repo’s **host agent environment** lane for this machine. Repo canon and
thin synced skills win over vendor globals.

## When to use

- New machine or fresh Cursor profile
- After changing `tool/agent_host_templates/**`
- After `bash tool/install_global_agent_skills.sh` (dedupe + inventory)
- User asks to “set up Cursor agents”, “sync skills”, “reduce skill bloat”

## Closed loop

1. Read `docs/agent_environment_setup.md` (one screen).
2. Run the orchestrator (do not hand-compose a longer shell sequence):

```bash
# Preview
bash tool/setup_cursor_agent_environment.sh

# Usual: sync repo adapters + drift check
bash tool/setup_cursor_agent_environment.sh --apply

# Full vendor install + balanced trim + inventory (network)
bash tool/setup_cursor_agent_environment.sh --apply --install

# Flutter-first trim (less iOS kit noise)
bash tool/setup_cursor_agent_environment.sh --apply --install --trim-mode full
```

1. Tell the user to **reload Cursor** after `--apply`.
2. If skill budget still breaches, report `docs/audits/skill_inventory_latest.json`
   and suggest `bash tool/trim_duplicate_agent_skills.sh --mode full --apply`.

## Safety

- Do not edit `~/.cursor/skills/*` by hand; change `tool/agent_host_templates/` then sync.
- Do not skip trim after bulk global install unless user explicitly opts out.
- Install/trim touches only host paths under `~/.cursor`, `~/.codex`, `~/.agents/skills`.
