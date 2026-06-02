# Agent context baseline (2026-05-22)

Pre-optimization snapshot for the agent context/token pass. JSON inventories stay under `docs/audits/` (gitignored).

## Skill inventory (`skill_inventory_2026-05-22.json`)

| Origin | approxTokens | Budget | Status |
| --- | ---: | ---: | --- |
| `repoTemplates` | 10411 | 12000 | OK (sum); target post-trim ≤ 4500 |
| `cursorSkills` | 41384 | 120000 | OK |
| `agentsSkills` | 506285 | 80000 | Over budget (global vendor tree; trim Slice 3) |
| `pluginCache` | 1078486 | — | Measure only; no deletes |

Largest `repoTemplates` skills:

Paths below point at current source locations; several host-neutral skills moved
to `tool/agent_host_templates/shared/` after this baseline.

| Tokens | Path |
| ---: | --- |
| 849 | [`tool/agent_host_templates/shared/skills/agents-references/SKILL.md`](../../tool/agent_host_templates/shared/skills/agents-references/SKILL.md) |
| 587 | [`tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md`](../../tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md) |
| 582 | [`tool/agent_host_templates/cursor/skills/upgrade-pr-triage-validate/SKILL.md`](../../tool/agent_host_templates/cursor/skills/upgrade-pr-triage-validate/SKILL.md) |
| 565 | [`tool/agent_host_templates/cursor/skills/agents-cursor-integration/SKILL.md`](../../tool/agent_host_templates/cursor/skills/agents-cursor-integration/SKILL.md) |
| 565 | [`tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md`](../../tool/agent_host_templates/shared/skills/agents-delivery-workflow/SKILL.md) |

## Always-on bytes

| File | Bytes |
| --- | ---: |
| [`AGENTS.md`](../../AGENTS.md) | 4625 |
| [`agent_knowledge_base.md`](../agent_knowledge_base.md) | 9318 |
| [`agents_quick_reference.md`](../agents_quick_reference.md) | 7944 |
| `tool/agent_host_templates/cursor/rules/agent-execution.mdc` | 939 |
| `tool/agent_host_templates/cursor/rules/agents-global.mdc` | 2707 |

## Global trim dry-run

`tool/trim_duplicate_agent_skills.sh` (balanced, no `--apply`): **0 entries** to archive on this machine at baseline time.

## Prior baselines (context)

- 2026-05-12: `repoTemplates` ~4887; `cursorSkills` ~47202
- 2026-05-17: `repoTemplates` post-dedupe; `cursorSkills` ~42819

## Dedup matrix

Committed: [`README.md`](../audits/README.md), [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md). `.gitignore` uses docs/audits/* plus !docs/audits/README.md and !docs/audits/dedup_matrix_*.md (not docs/audits/, which blocks re-includes).
