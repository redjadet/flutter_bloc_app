# AIDLC workflow (repo-native lifecycle)

## Why

Agents needed a brownfield lifecycle for non-trivial work: classify depth,
record intent/extensions/gates, separate approve from continue, and keep
existing owners (validation, safety, skills) as the execution surface. Upstream
AIDLC ideas inform terminology only; this repo owns the contract.

## Change

- Owner: [`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md)
- Schemas + rule IDs: [`../engineering/aidlc_artifact_contract.md`](../engineering/aidlc_artifact_contract.md)
- Tools: `tool/scaffold_aidlc_run.sh`, `tool/check_aidlc_artifacts.sh`
  (`--self-test`, `--discover`), fixtures under `tool/fixtures/aidlc_artifacts/`,
  deps `tool/requirements-aidlc.txt` (PyYAML)
- Shared skill: `agents-aidlc-workflow` (Cursor + Codex via `tool/agent_asset_lib.sh`)
- Maintain: preflight discovers runs (log only); closeout validates when present;
  checklist path-triggers AIDLC check; engineering closeout skips coverage proof
  when `coverage/lcov.info` missing (docs/tooling scopes)
- Codex review fixes: unique active identity by `run_id`; validate questions/audit/
  artifacts companions; stage-then-promote scaffold with restore on failure

## Ownership

Lifecycle semantics stay in [`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md). Validation schemas stay in the
artifact contract. Specialist skills and safety contracts remain controlling for
implementation and external authority.

## Decisions

- T0 / T1 Lite / T2 full activation; one `active` run per host
- `run_status` ≠ `current_stage`; structured `extensions` + `gate_events`
- Approve ≠ continue ≠ Git/deploy/cloud authority
- Host sync apply requires explicit authorization (R3); PLAN_ONLY closeout until then
- High-risk Construction still stops until a named human approver exists (R1)

## Validation

```bash
bash -n tool/scaffold_aidlc_run.sh tool/check_aidlc_artifacts.sh tool/validate_task_trackers.sh
bash tool/check_aidlc_artifacts.sh --self-test
bash tool/check_aidlc_artifacts.sh --discover
bash tool/validate_task_trackers.sh
bash tool/run_harness_fixtures.sh
bash tool/check_docs_gardening.sh --paths \
  docs/ai/aidlc_workflow.md \
  docs/engineering/aidlc_artifact_contract.md \
  docs/changes/2026-09-09_aidlc_workflow.md
bash tool/check_agent_knowledge_base.sh
bash tool/check_agent_safety_contracts.sh
bash tool/check_ai_failure_risk_register.sh
bash tool/check_harness_scorecard_gate.sh
./bin/agent-maintain after-host-edit
bash tool/sync_agent_assets.sh --dry-run
bash tool/check_agent_asset_drift.sh
./bin/agent-maintain closeout
CHECKLIST_ALLOW_REUSE=0 ./bin/checklist
```

## Limitations

- R1: no named high-risk approver in governance yet
- Adoption claim still requires human verdict on this change note + proof
- Local `tasks/*/aidlc/**` run dirs remain gitignored operator work
