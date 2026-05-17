# Global agent skills install and trim (2026-05-17)

## Why

Bulk `npx skills` installs under `~/.agents/skills` duplicated names already
synced in `~/.cursor/skills`, inflating skill-list context. Needed repo-owned
install/update/trim scripts and inventory coverage for `agentsSkills`.

## What

- `tool/setup_cursor_agent_environment.sh` (orchestrator: sync, install, trim, inventory)
- `tool/install_global_agent_skills.sh`, `tool/update_global_agent_skills.sh`,
  `tool/find_global_agent_skills.sh`, `tool/trim_duplicate_agent_skills.sh`,
  `tool/global_agent_skills_lib.sh`
- Cursor automation: command `/setup-cursor-agent-environment`, skill `agents-global-skills-setup`
- `tool/skill_inventory.dart` scans `~/.agents/skills`; budget check adds
  `SKILL_BUDGET_AGENTS_TOKENS` (default 80000)
- Docs: [`agent_environment_setup.md`](../agent_environment_setup.md),
  [`validation_scripts.md`](../validation_scripts.md),
  [`agents_quick_reference.md`](../agents_quick_reference.md)

## Host workflow

```bash
bash tool/setup_cursor_agent_environment.sh --apply --install
# or stepwise:
bash tool/install_global_agent_skills.sh
bash tool/trim_duplicate_agent_skills.sh --apply
dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
```

Cursor agents: slash command `/setup-cursor-agent-environment`, skill `agents-global-skills-setup`.

Restore archived skills from `~/.agents/skills/.archived/<timestamp>/`.
