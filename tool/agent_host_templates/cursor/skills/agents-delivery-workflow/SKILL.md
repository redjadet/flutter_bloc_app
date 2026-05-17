---
name: agents-delivery-workflow
description: Non-trivial delivery start-to-finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Canon + loop (**Plan → Execute → Verify → Report**): `AGENTS.md`, `agents-quick-reference`, `docs/agents_quick_reference.md` (routing: `#automatic-workflow-triggers`). **context ladder** + **File verified reusable conclusions** → `docs/agent_knowledge_base.md`.

- **Plan:** Goal / Context / Boundaries / Verification; non-trivial → `tasks/cursor/todo.md`; context audit before feature/refactor; delegation → `agents-meta-behavior` + `#multi-agent-hub`. No edits until **95% confident**. One observe/revise loop.
- **Execute:** preserve `Presentation -> Domain <- Data` seams; DI/routes/l10n/codegen when touched; UI/Mix → `DESIGN.md` + `docs/design_system.md`.
- **Verify:** `docs/ai_code_review_protocol.md`; narrowest validation lane; empty tool output ≠ proof. **Self-verify final response** vs request, diff, proof, blockers, risk.
- **Report only after Verify**; **Surgical diff** traces each line to request or validation/doc need.

Doc/host changes: `./tool/check_agent_knowledge_base.sh`; escalate to `./bin/checklist` if agent guidance changed materially.

## Multi-agent

Coordinator gates fan-out. **Team** when blast radius, cross-layer read, high-risk logic, separate implement/review bars, or user asked plan+implement+verify: `tasks/cursor/team/<run-id>/` (`goal.md`, `findings.md`, `plan.md`, diff artifacts, `review.md`). **Single** otherwise; log `Benefit: team - <reason>` or `Benefit: single - <reason>`. Inline context to specialists (not path-only); max 2 implementer fix loops unless user extends. Matrix: `agent_knowledge_base.md#multi-agent-hub`.

## Completion gate

Non-trivial: AI review + tracker proof. UI: `./tool/check_design_md.sh` if `DESIGN.md` edited; Mix: `./tool/run_mix_lint.sh`. Prefer app-visible proof.

## Commit rules

Inspect `git status` / `git diff` / `git diff --staged`. Imperative ≤72-char subject; note tests run/skipped. Full bar: `docs/testing_overview.md`, `docs/validation_scripts.md`.
