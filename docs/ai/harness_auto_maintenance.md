# Harness Auto-Maintenance (Cursor/Codex)

Agents keep the Cursor/Codex harness at max score by running scoped gates and
fixing owner wiring in the same turn. Canon: [`harness_scorecard.md`](harness_scorecard.md),
[`ai_failure_risks.md`](ai_failure_risks.md) (`RISK-HARNESS-SCORE-DROP`).

## Agent loop

Command when-table: [`host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md).
Harness-specific:

1. **During work:** land durable rules in owner docs/scripts/skills, not chat only.
2. **Before max-score claim:** `./bin/agent-maintain harness-maintain` (or `harness`);
   this updates the README score badge from [`harness_scorecard.md`](harness_scorecard.md).
3. **On gate failure:** fix missing owners/links/skills; rerun `harness-maintain`;
   add `docs/changes/` note when rationale matters.

`closeout` logs `scope|harness` and runs `harness-maintain` when harness paths are
in git scope (including when `docs-sync` skipped the scorecard gate).

Do not claim `10/10` while `check_harness_scorecard_gate.sh` or
`check_ai_failure_risk_register.sh` fails.

## Scope (triggers `harness-maintain` in closeout)

Git paths (staged, unstaged, untracked, deleted) matching:

| Pattern | Why |
| --- | --- |
| `tool/agent_host_templates/**` | Host skills/rules sync |
| `docs/ai/**` | Scorecard, risks, routing, context |
| [`feature_structure_contract.md`](../architecture/feature_structure_contract.md), [`reference_features.md`](../architecture/reference_features.md), [`use_case_dto_policy.md`](../architecture/use_case_dto_policy.md) | Feature harness |
| [`bloc_standards.md`](../bloc_standards.md), `docs/bloc/**` | BLoC harness |
| `docs/review/**` | Review checklists |
| [`feature_implementation_guide.md`](../feature_implementation_guide.md) | Delivery contract |
| [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) | Test matrix |
| `.cursor/rules/**` | Cursor agent rules |
| `tool/check_harness_scorecard_gate.sh`, `update_harness_score_badge.sh`, `check_ai_failure_risk_register.sh`, `check_clean_architecture_imports.sh`, `check_feature_folder_contract.sh`, `scaffold_feature_contract.sh` | Harness gates |
| [`AGENTS.md`](../../AGENTS.md) | Entry map |

`tool/agent_maintain.sh` implements this as `scope_has_harness_edits`.

## Optimization triggers (proactive)

| Change | Agent action |
| --- | --- |
| New validation script | Update `docs/validation_scripts/` catalog + checklist index; add risk register detection row if recurring |
| New host skill | Register in `tool/agent_asset_lib.sh`, [`ai/skill_routing.md`](skill_routing.md), run `after-host-edit` |
| New architecture/BLoC policy | Update contract + [`reference_features.md`](../architecture/reference_features.md) + scorecard gate needles |
| Scorecard area or README badge below 10 | Add missing owner doc, script, synced skill, or README badge update; extend `check_harness_scorecard_gate.sh` |
| Repeated agent mistake | Follow [Update Rule](ai_failure_risks.md#update-rule): script, fixture, doc, or skill |

## Commands

| Command | Purpose |
| --- | --- |
| `bash tool/update_harness_score_badge.sh` | Derive README badge from scorecard table |
| `bash tool/update_harness_score_badge.sh --check` | Fail on stale README badge |
| `./bin/agent-maintain harness-maintain` | Static harness gates (mid-task or pre-claim) |
| `./bin/agent-maintain harness` | Alias for `harness-maintain` |
| `./bin/agent-maintain closeout` | Full scoped closeout including `harness-maintain` |
| `bash tool/run_harness_fixtures.sh` | Fixture smoke for harness scripts |

## Pointers

| Need | Owner |
| --- | --- |
| 10/10 areas + proof commands | [`harness_scorecard.md`](harness_scorecard.md) |
| Visible current score | [`README.md`](../../README.md) badge linked to [`harness_scorecard.md`](harness_scorecard.md) |
| Closeout / preflight when-table | [`host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md) |
| Failure risk | [`ai_failure_risks.md`](ai_failure_risks.md) |
