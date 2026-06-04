# Vendor plugin inventory split (2026-06-04)

## Problem

`skill_inventory_latest.json` mixed editable skills with ~494 marketplace plugin skills (~1.18M approx tokens), drowning budget/rank signal.

## Change

- `tool/skill_inventory.dart` excludes `pluginCache` by default; opt-in `--include-plugin-cache`.
- New `tool/skill_vendor_plugin_inventory.dart` + `tool/audit_vendor_plugin_skills.sh` → `docs/audits/vendor_plugin_inventory_latest.json` (per-plugin rollup + Flutter disable candidates).
- `tool/skill_budget_check.dart` reports vendor exclusion when applicable.
- `tool/setup_cursor_agent_environment.sh` runs vendor audit after editable inventory.

## Verify

```bash
dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
bash tool/audit_vendor_plugin_skills.sh
bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json report
```
