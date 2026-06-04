---
name: agents-global-skills-setup
description: Run repo host agent setup for Cursor—sync templates, install/update global vendor skills, trim ~/.agents/skills duplicates, skill inventory. Use when setting up Cursor, after install_global_agent_skills, reducing skill-list bloat, or user says sync/trim global skills.
---

# Global skills and host setup (Cursor)

Repo adapters: `tool/agent_host_templates/`. Vendor globals: `~/.agents/skills` ([skills CLI](https://skills.sh/)).

```bash
./bin/agent-maintain host-full --apply
# or: bash tool/setup_cursor_agent_environment.sh --apply --install
```

Slash: `/agent-maintain` or `/setup-cursor-agent-environment`. **Policy:** repo canon wins; trim after install; reload Cursor. Detail: [`docs/agent_environment_setup.md`](../../../../../docs/agent_environment_setup.md).
