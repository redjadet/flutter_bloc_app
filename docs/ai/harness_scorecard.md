# Cursor/Codex Harness Scorecard

Use before claiming this repo's AI harness is complete or at maximum score.
Scope is Cursor and Codex only; Gemini/Claude/Copilot references in product or
historical docs are not harness targets.

Visible score source: [`README.md`](../../README.md) badge. Agents update it
with `bash tool/update_harness_score_badge.sh`; score equals the lowest area
score in the table below.

## Score

| Area | Score | Required proof |
| --- | --- | --- |
| Clean Architecture | 10/10 | `bash tool/check_clean_architecture_imports.sh` + `bash tool/check_feature_modularity_leaks.sh` |
| BLoC Standards | 10/10 | [`bloc_standards.md`](../bloc_standards.md), [`review/bloc_checklist.md`](../review/bloc_checklist.md), `agents-bloc-standards` synced |
| Folder Structure | 10/10 | [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md), [`architecture/reference_features.md`](../architecture/reference_features.md) + `bash tool/scaffold_feature_contract.sh --name <feature>` + `bash tool/check_feature_folder_contract.sh` |
| Coding Principles | 10/10 | [`CODE_QUALITY.md`](../CODE_QUALITY.md), [`architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md), `./tool/analyze.sh` when app code changed |
| Testing Standards | 10/10 | [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) + focused tests named in feature brief |
| Review Checklists | 10/10 | [`review/architecture_checklist.md`](../review/architecture_checklist.md), [`review/bloc_checklist.md`](../review/bloc_checklist.md), [`review/security_checklist.md`](../review/security_checklist.md), [`review/performance_checklist.md`](../review/performance_checklist.md), [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) |
| Context System | 10/10 | [`AGENTS.md`](../../AGENTS.md), [`ai/context_loading.md`](context_loading.md), [`agents_quick_reference.md`](../agents_quick_reference.md) |
| Memory System | 10/10 | [`agent_knowledge_base.md`](../agent_knowledge_base.md), `docs/changes/`, [`tasks/lessons.md`](../../tasks/lessons.md), `tool/check_agent_memory_compounding.sh` |
| Verification System | 10/10 | `./bin/checklist`, `./bin/checklist-fast`, CI `./bin/checklist`, `./bin/agent-maintain closeout` |

## Max-Score Claim Gate

Agents may claim `10/10` only after all apply:

- [`README.md`](../../README.md) shows the current `Harness 10/10` badge and
  links back to this scorecard.
- `bash tool/update_harness_score_badge.sh --check` passes.
- `bash tool/check_ai_failure_risk_register.sh` passes.
- `bash tool/check_harness_scorecard_gate.sh` passes.
- `bash tool/check_agent_asset_drift.sh` passes.
- `./bin/checklist-fast --no-reuse` passes for docs/tooling harness changes, or
  `./bin/checklist` passes for app/runtime changes.
- `./bin/agent-maintain closeout` passes.
- Any `tool/agent_host_templates/**` change was followed by
  `./bin/agent-maintain after-host-edit` in the same turn.
- New durable rules landed in owner docs plus `docs/changes/` or
  [`ai/decision_log.md`](decision_log.md).

## Failure Modes

Failure modes live in [`ai_failure_risks.md`](ai_failure_risks.md). Keep this
file to scoring and proof gates only.

## Automatic Maintenance

Canon: [`harness_auto_maintenance.md`](harness_auto_maintenance.md). Agents run
the loop there; do not claim max score without passing gates.

- `./bin/checklist-fast --no-reuse` runs `tool/check_harness_scorecard_gate.sh`
  through harness docs checks.
- `./bin/checklist` runs `tool/check_harness_scorecard_gate.sh` in the full
  check script list.
- `tool/check_harness_scorecard_gate.sh` enforces the README score badge so the
  visible repo entrypoint stays aligned with this scorecard.
- `./bin/agent-maintain harness-maintain` updates the README badge before
  running scorecard gates.
- `./bin/agent-maintain closeout` runs `harness-maintain` when harness paths
  are in git scope (including host-only template or `.cursor/rules` edits).
- `./bin/agent-maintain docs-sync` still runs the scorecard gate when validation
  tooling or markdown docs are in scope.
- Agents may run `./bin/agent-maintain harness-maintain` (alias `harness`) any
  time before max-score claims.

## Owner Map

| Need | Owner |
| --- | --- |
| Visible score badge | [`README.md`](../../README.md) |
| Entry map | [`AGENTS.md`](../../AGENTS.md) |
| Skill route | [`ai/skill_routing.md`](skill_routing.md) |
| Failure risks | [`ai/ai_failure_risks.md`](ai_failure_risks.md) |
| Auto-maintenance loop | [`ai/harness_auto_maintenance.md`](harness_auto_maintenance.md) |
| Host sync | [`agent_kb/host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md) |
| Feature architecture | [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md), [`architecture/reference_features.md`](../architecture/reference_features.md) |
| BLoC | [`bloc_standards.md`](../bloc_standards.md) |
| Testing | [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) |
| Review | `docs/review/` |
| Validation inventory | `docs/validation_scripts/` |
