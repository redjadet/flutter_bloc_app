# Harness Quick Wins (Cursor/Codex audit follow-up)

Implemented high-ROI harness gaps from the Flutter harness engineering audit.

## Added

- [`review/security_checklist.md`](../review/security_checklist.md) — auth, secrets, injection, sync review pass
- [`review/performance_checklist.md`](../review/performance_checklist.md) — rebuild, list, I/O, lifecycle + `check_perf_*` scripts
- [`bloc/cubit_file_template.md`](../bloc/cubit_file_template.md) — copy-paste Cubit/Freezed/test starter
- [`architecture/feature_brief_scaffold_example.md`](../architecture/feature_brief_scaffold_example.md) — filled `audit_demo` brief example (no runtime feature)
- `agents-create-cubit` host skill — routes to template + bloc standards

## Updated

- [`clean_architecture.md`](../clean_architecture.md) — prefer Freezed for new state; Equatable legacy OK
- [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) — new code uses `presentation/cubit/` only
- [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) — golden/visual regression row
- [`CODEMAP.md`](../../CODEMAP.md) — `counter` marked legacy; do not copy layout
- [`ai/harness_scorecard.md`](../ai/harness_scorecard.md), [`README.md`](../README.md), [`ai_code_review_protocol.md`](../ai_code_review_protocol.md), [`ai/skill_routing.md`](../ai/skill_routing.md)
- `tool/check_harness_scorecard_gate.sh` — requires new owners + skill wiring

## Proof

```bash
bash tool/check_harness_scorecard_gate.sh
bash tool/scaffold_feature_contract.sh --name audit_demo
./bin/agent-maintain after-host-edit
```
