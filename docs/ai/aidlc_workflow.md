# AIDLC workflow (repo-native)

Brownfield AI-Driven Development Life Cycle for this repository. Orchestrates
existing owners; does not replace them.

Schemas: [`../engineering/aidlc_artifact_contract.md`](../engineering/aidlc_artifact_contract.md).
Safety: [`../agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md).
Finish: [`../agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md).
Roles: [`governance.md`](governance.md).

## Activation

| Depth | When | Artifacts |
| --- | --- | --- |
| T0 | Trivial one-line / obvious convention (≥95%) | None |
| T1 Lite | Non-trivial local task | `## AIDLC` YAML in `tasks/{host}/todo.md` |
| T2 full | Cross-feature, medium/high risk, architecture, release, or explicit lifecycle request | `tasks/{host}/aidlc/{run-id}/` + tracker pointer |

Unknown risk blocks Construction until classified. One `run_status: active` per host.

## Stages

| Stage | Answers | Typical repo work |
| --- | --- | --- |
| Inception | What / why | Classify, scope, write-set, extensions, proof plan |
| Construction | How | Implement, test, review, validate, doc reconciliation |
| Operation | Ship / run | Build/release/deploy/monitor **only** when authorized; else `not_applicable` |

Keep `run_status` (`active` / `blocked` / `superseded` / `complete`) separate from
`current_stage` (`inception` / `construction` / `operation`).

## Approve vs continue

Every gated transition needs two `gate_events`:

1. `approve` — artifact quality accepted
2. `continue` — permission to execute the next stage

Neither grants Git, push, PR, merge, deploy, cloud, install, or other external
authority. Safety contracts remain controlling.

| Risk / mode | Approve | Continue |
| --- | --- | --- |
| T1 low | Implementer | Implementer |
| T1 medium | Reviewer | Human |
| T2 low | Implementer | Implementer |
| T2 medium | Independent Reviewer | Human |
| Any high | Named human | Same human / recorded delegate |
| Operation | — | Explicit user auth for the concrete op |

## Extensions

Record every known key with `status` + `reason` (see artifact contract). Route to
existing owners; do not duplicate validation/security prose here.

- Selected when the change matches the extension surface
- Skipped with a concrete negative reason
- Property-based testing is optional; no new package by default

## Transitions

- Inception → Construction: classified risk; approved scope/write-set; extensions;
  proof plan; `approve` then `continue`
- Construction → Complete: Operation `not_applicable` (usual local work); proof
  recorded; set `run_status: complete`
- Construction → Operation: only with Operation authority
- Material scope/product/architecture/proof change: `invalidate` downstream
  approvals (`supersedes`) and return to owning gate
- `blocked`: require `blocker`, `blocker_owner`, `unblock_condition`

## Documentation reconciliation

Before terminal complete:

1. Changed behavior → update owning canon doc
2. Shipped workflow → `docs/changes/` note (when implementation slice closes)
3. Generated indexes → owner generator only (e.g. `tool/fix_validation_docs.sh`)

## Commands

```bash
bash tool/scaffold_aidlc_run.sh --host cursor --mode lite --dry-run
bash tool/scaffold_aidlc_run.sh --host cursor --mode full --slug my-task --dry-run
bash tool/check_aidlc_artifacts.sh
bash tool/check_aidlc_artifacts.sh --discover
bash tool/check_aidlc_artifacts.sh --self-test
bash tool/validate_task_trackers.sh
```

Record Lite state in the host tracker (or use scaffold `--apply`).

## Host sync proof lanes

`closeout` may run `after-host-edit` (live apply) when host templates changed.
Before apply authorization: dry-run + `AGENT_MAINTAIN_PLAN_ONLY=1` closeout only.
After authorization: `after-host-edit` → dry-run → drift → normal closeout → full checklist.

## Stop

Stop for product/architecture/security/release ambiguity, high risk without named
approver, secret/transcript capture pressure, or any attempt to treat approve as
continue / Git authority.
