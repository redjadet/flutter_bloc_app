---
name: agents-aidlc-workflow
description: >-
  Repo-native AIDLC orchestrator for lifecycle / phase-gated delivery / resume
  runs. Classifies T0/T1/T2, manages approve vs continue gates, and routes to
  specialist skills plus repo validation. Use when the task says AIDLC,
  lifecycle, phase-gated delivery, or resume an active AIDLC run.
---

# AIDLC workflow (orchestrator)

Thin orchestrator. Semantics owner:
[`docs/ai/aidlc_workflow.md`](../../../../../docs/ai/aidlc_workflow.md).
Schemas:
[`docs/engineering/aidlc_artifact_contract.md`](../../../../../docs/engineering/aidlc_artifact_contract.md).
Does **not** replace Dart/Flutter/domain skills or safety contracts.

## Start

1. Resolve repo root; run `./bin/agent-maintain preflight --intent "<goal>"`.
2. Classify depth (owner table): **T0** (no artifacts), **T1 Lite** (tracker
   `## AIDLC` YAML), **T2 full** (`tasks/{host}/aidlc/{run-id}/`).
3. Find/resume one `run_status: active` per host; never create a second active.
4. Present selected vs skipped stages/extensions with concrete reasons.
5. Scaffold only when needed:

```bash
bash tool/scaffold_aidlc_run.sh --host cursor --mode lite --dry-run
bash tool/scaffold_aidlc_run.sh --host cursor --mode full --slug <slug> --dry-run
# --apply only after user accepts the dry-run plan
```

## Loop

`Inception` → gate → `Construction` → gate → optional `Operation` → terminal
validation/report.

Keep `run_status` separate from `current_stage`. Every gated transition needs
two `gate_events`: **`approve`** then **`continue`**. Never treat approve as
continue. Neither grants Git, push, PR, merge, deploy, cloud, or install
authority — safety contracts remain controlling.

Ask only material questions; record answers in artifacts **before** using them.
On material scope/product/architecture/proof change: `invalidate` downstream
approvals and return to owning gate. Unknown risk blocks Construction.

## Route (do not re-implement)

| Concern | Go to |
| --- | --- |
| Specialist implementation | Matching skill via [`docs/ai/skill_routing.md`](../../../../../docs/ai/skill_routing.md) |
| Non-AIDLC delivery / finish gate | `agents-delivery-workflow` |
| Validation lane | Repo commands in [`docs/engineering/validation_routing_fast_vs_full.md`](../../../../../docs/engineering/validation_routing_fast_vs_full.md) |
| Artifact check | `bash tool/check_aidlc_artifacts.sh` (+ `--self-test` when changing validator) |
| Trackers | `bash tool/validate_task_trackers.sh` |

## Stop

Product/architecture/security/release ambiguity; high risk without named
approver; secret/transcript capture pressure; any attempt to infer external
authority from approve/continue.

## Host sync

Edit this skill under `tool/agent_host_templates/**` only. Live host apply needs
explicit authorization (`after-host-edit` / sync `--apply`). Until then:
`./tool/sync_agent_assets.sh --dry-run` + `AGENT_MAINTAIN_PLAN_ONLY=1` closeout.
