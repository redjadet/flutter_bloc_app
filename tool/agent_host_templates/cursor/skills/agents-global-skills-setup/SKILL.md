---
name: agents-global-skills-setup
description: Run repo host agent setup for Cursor—sync templates, install/update global vendor skills, trim ~/.agents/skills duplicates, skill inventory. Use when setting up Cursor, after install_global_agent_skills, reducing skill-list bloat, or user says sync/trim global skills.
---

# Global skills and host setup (Cursor)

Repo-managed adapters (`tool/agent_host_templates/`) are separate from vendor
globals (`~/.agents/skills` via [skills CLI](https://skills.sh/)).

## Default agent path

Run the orchestrator (do not improvise a longer shell chain):

```bash
bash tool/setup_cursor_agent_environment.sh          # preview
bash tool/setup_cursor_agent_environment.sh --apply  # sync + drift
bash tool/setup_cursor_agent_environment.sh --apply --install  # + vendor install + trim + inventory
```

Slash command: `/setup-cursor-agent-environment` (see `~/.cursor/commands/` after sync).

## Individual scripts

| Step | Script |
| --- | --- |
| Sync repo skills/commands/rules | `bash tool/sync_agent_assets.sh --apply` |
| Install vendor bundles | `bash tool/install_global_agent_skills.sh` |
| Update vendors | `bash tool/update_global_agent_skills.sh` |
| Trim duplicates | `bash tool/trim_duplicate_agent_skills.sh` (`--apply`, `--mode full`) |
| Inventory / budget | `dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json` |

## Policy

- Repo canon (`AGENTS.md`, `docs/`, synced `agents-*` skills) wins over vendor skills.
- After bulk install, always trim before claiming setup is done.
- Reload Cursor after host mutations.

Details: `docs/agent_environment_setup.md`.
