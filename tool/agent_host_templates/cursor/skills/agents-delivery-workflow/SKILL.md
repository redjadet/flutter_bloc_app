---
name: agents-delivery-workflow
description: Non-trivial delivery start→finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Canon: `AGENTS.md`, `docs/agent_knowledge_base.md`, `docs/agents_quick_reference.md`. Default: **Plan -> Execute -> Verify -> Report**. Triggers: `docs/agents_quick_reference.md#automatic-workflow-triggers`.

- **Plan:** non-trivial -> `tasks/cursor/todo.md`; existing code uses context ladder; delegation -> `agents-meta-behavior`.
- **Plan:** do not edit until 95% confident; if vague/risky, define boundaries, data flow, failure handling, smallest proof.
- **Plan:** one loop (`plan -> tool -> observe -> revise`); branch only when risk pays.
- **Execute:** reuse seams; keep `Presentation -> Domain <- Data`; update DI/routes/l10n/codegen when touched.
- **Execute:** UI/design/Mix -> `DESIGN.md` + `docs/design_system.md`; prefer `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.
- **Execute:** File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.
- **Verify:** `docs/ai_code_review_protocol.md`, smallest matching validation; empty/truncated tool output is not proof.
- **Verify:** Self-verify final response vs request, changed files, proof, blockers, residual risk.
- **Report:** Report only after Verify. Surgical diff: each line traces to request or required validation/doc update.

Docs/agent changes: targeted docs/link checks, `./tool/check_agent_knowledge_base.sh`, host-template drift path; escalate to `./bin/checklist` when guidance changed materially.

## Multi-agent

Coordinator-as-hub. Gate before fan-out.

- **Team** when >=2: blast radius, cross-layer read, high-risk logic, separate implement/review bars, or user asked plan+implement+verify.
- **Single** otherwise; tie-break single. Tracker: `Benefit: team - <reason>` or `Benefit: single - <reason>`.
- `single`: normal loop; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` (`goal.md`, `findings.md`, `plan.md`, `diff-summary.md`/`diff.md`, `review.md`). Coordinator owns artifacts + validation.
- Spawn specialists with inline context, never path-only. Max two Implementer fix loops unless user extends.
- Specialist returns summary + final result + verified artifacts only, not full transcript/reasoning dump.

Doctrine + matrix: `docs/agent_knowledge_base.md#multi-agent-hub`; roles/redaction: `agents-meta-behavior`.

## Completion gate

- AI review gate + non-trivial tracker proof.
- UI/design: `./tool/check_design_md.sh` if `DESIGN.md` edited; `./tool/run_mix_lint.sh` for Mix token/style edits.
- UI/app: prefer app-visible proof.
- Finish gate: edge cases, failure paths, readability, operational clarity, breakage impact.
- Resolve selected validation failures; add focused tests when behavior warrants.

## Commit rules

Inspect `git status` + `git diff`; stage intended scope only; check `git diff --staged`. Commit message: imperative, <=72 char subject, why when not obvious, tests run/not run, no assistant mention. Full bar: `docs/testing_overview.md`, `docs/validation_scripts.md`.
