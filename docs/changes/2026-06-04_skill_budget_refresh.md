# Skill budget refresh and follow-ups (2026-06-04)

## What we did

- Regenerated `docs/audits/skill_inventory_latest.json` (`dart run tool/skill_inventory.dart`).
- Regenerated `docs/audits/vendor_plugin_inventory_latest.json` (`bash tool/audit_vendor_plugin_skills.sh`).
- Ran `bash tool/check_skill_budgets.sh … report` and `skill_rank` on fresh inventory.

## Results

| Bucket | Approx tokens | Budget | Status |
| --- | --- | --- | --- |
| repoTemplates | ~5,060 | 12,000 | OK |
| cursorSkills | ~37,092 | 120,000 | OK |
| agentsSkills | ~66,584 | 80,000 | OK (was overstated when inventory was stale) |
| pluginCache (vendor) | ~1,178,079 | N/A | Report only; disable plugins in Cursor UI |

`trim_duplicate_agent_skills.sh` (balanced / flutter-repo / full): **0 entries** — active `~/.agents/skills` already trimmed; prior archives under `~/.agents/skills/.archived/`.

## Doc

- `docs/agent_environment_setup.md` — optional Flutter-first marketplace plugin slim-down.
- `docs/validation_scripts/operations_host_skills.md` — **§ Suggested habits** (canonical table) + monthly Cursor Plugins checklist.
- `docs/audits/README.md` — § Habits (short version + link).
- `docs/agent_kb/operator_preferences_durable.md` — Host Setup habit bullets.

## Operator actions (manual)

Moved to canonical docs: [`validation_scripts/operations_host_skills.md`](../validation_scripts/operations_host_skills.md) § Suggested habits.

## Not done

- `trim --apply` (not needed while under budget).
- Git commit (not requested).
