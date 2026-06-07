# Harness fill gaps (reference features + wiring)

## Why

Max-score harness had deterministic gates but agents still lacked a single doc
for **which live features to copy** and consistent pointers from skills, risk
register, and validation routing to `check_feature_folder_contract.sh`.

## What changed

- Added [`architecture/reference_features.md`](../architecture/reference_features.md)
  — gold layouts (`remote_config`, `case_study_demo`, `iot_demo`, `profile`,
  `todo_list`) and legacy do-not-copy list (`counter`, `settings/cubits/`, root
  cubits, `staff_app_demo` flow folders).
- Wired folder-contract proof through:
  - [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md)
  - [`ai/ai_failure_risks.md`](../ai/ai_failure_risks.md)
  - [`ai/harness_scorecard.md`](../ai/harness_scorecard.md)
  - [`review/architecture_checklist.md`](../review/architecture_checklist.md)
  - [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
  - [`feature_implementation_guide.md`](../feature_implementation_guide.md)
  - [`README.md`](../README.md), [`CODEMAP.md`](../../CODEMAP.md), [`AGENTS.md`](../../AGENTS.md)
  - [`agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md)
  - `agents-feature-delivery` and `agents-canonical-rules-architecture` host skills
- Extended `tool/check_ai_failure_risk_register.sh` and
  `tool/check_harness_scorecard_gate.sh` for reference doc + folder-contract tokens.

## Proof

```bash
bash tool/check_harness_scorecard_gate.sh
bash tool/check_ai_failure_risk_register.sh
bash tool/run_harness_fixtures.sh
./bin/agent-maintain after-host-edit
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```
