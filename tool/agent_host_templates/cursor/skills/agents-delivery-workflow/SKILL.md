---
name: agents-delivery-workflow
description: Non-trivial delivery start→finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Canon: `AGENTS.md`, `docs/agent_knowledge_base.md`, `docs/agents_quick_reference.md`. Default: **Plan -> Execute -> Verify -> Report**. Plan once (<=10 lines). Ask only hard blockers. Triggers: `docs/agents_quick_reference.md#automatic-workflow-triggers`.

- **Plan:** non-trivial -> plan + proof in `tasks/cursor/todo.md`.
- **Plan:** existing-code -> context ladder: map docs, durable memory, code-review-graph, targeted raw files.
- **Plan:** delegation/parallelism -> `agents-meta-behavior`.
- **Plan:** Do not edit until 95% confident in goal/scope/approach.
- **Plan:** If vague/risky, define boundaries, data flow, failure handling, and smallest verifiable slice before generation.
- **Execute:** reuse seams; keep `Presentation -> Domain <- Data`.
- **Execute:** UI/design/Mix -> `DESIGN.md` + `docs/design_system.md`; prefer `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.
- **Execute:** lifecycle -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`; prefer `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`.
- **Execute:** update DI/routes/l10n/codegen when touched.
- **Execute:** File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.
- **Verify:** AI review gate `docs/ai_code_review_protocol.md`; run smallest matching validation.
- **Verify:** Self-verify final response vs request, changed files, proof, blockers, residual risk.
- **Report:** Report only after Verify.

Docs/agent changes: targeted docs/link checks, `./tool/check_agent_knowledge_base.sh`, host-template drift path; escalate to `./bin/checklist` when guidance changed materially.

## Multi-agent

Coordinator-as-hub. Gate before fan-out.

- **Team** when >=2: blast radius, cross-layer read, high-risk logic, separate implement/review bars, or user asked plan+implement+verify.
- **Single** otherwise; tie-break single. Tracker: `Benefit: team - <reason>` or `Benefit: single - <reason>`.
- `single`: normal loop; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` (`goal.md`, `findings.md`, `plan.md`, `diff-summary.md`/`diff.md`, `review.md`). Coordinator owns artifacts + validation.
- Spawn specialists with inline context, never path-only. Max two Implementer fix loops unless user extends.

Doctrine + matrix: `docs/agent_knowledge_base.md#multi-agent-hub`; roles/redaction: `agents-meta-behavior`.

## Completion gate

- Apply AI review gate.
- Non-trivial tracker includes plan + verification.
- UI/design: `./tool/check_design_md.sh` if `DESIGN.md` edited; `./tool/run_mix_lint.sh` for Mix token/style edits.
- Review subagent output yourself.
- UI/app: prefer app-visible proof.
- Surgical diff: each line traces to request or required validation/doc update.
- Self-verify final report vs diff, validation, blockers, risk.
- Resolve selected validation failures; add focused tests when behavior warrants.

## Commit rules

Inspect `git status` + `git diff`; stage intended scope only; check `git diff --staged`. Commit message: imperative, <=72 char subject, why when not obvious, tests run/not run, no assistant mention. Full bar: `docs/testing_overview.md`, `docs/validation_scripts.md`.
