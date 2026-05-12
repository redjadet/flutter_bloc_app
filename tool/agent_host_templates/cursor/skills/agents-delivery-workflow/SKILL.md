---
name: agents-delivery-workflow
description: Non-trivial delivery start-to-finish, validation routing, meta/subagent pointers, and completion gate before done/commit.
---

# Delivery workflow

Canon + loop (**Plan -> Execute -> Verify -> Report**): `AGENTS.md`, `docs/agent_knowledge_base.md`, `docs/agent_project_context.md`, `docs/agents_quick_reference.md`. Auto-trigger routing: `docs/agents_quick_reference.md#automatic-workflow-triggers`.

**context ladder:** map docs -> durable memory -> structural graph -> targeted raw-file reads (`docs/agent_knowledge_base.md`). **File verified reusable conclusions** go to owning source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md` (not chat-only).

- **Plan:** Goal / Context / Boundaries / Verification. Non-trivial -> `tasks/cursor/todo.md`. Context ladder uses `docs/agent_project_context.md`. Delegation + hub matrix -> `agents-meta-behavior` + `docs/agent_knowledge_base.md#multi-agent-hub`. No edits until >=95% confident. One observe/revise loop. Prefer repo tools, code graph, browser, MCP over memory. Avoid giant prompts, context flooding, single-agent overload.
- **Execute:** `Presentation -> Domain <- Data`; update DI/routes/l10n/codegen when touched. UI/Mix -> `DESIGN.md` + `docs/design_system.md`; prove real workflow and states.
- **Verify:** `docs/ai_code_review_protocol.md`; narrowest validation lane; empty tool output != proof. Legibility -> `docs/agent_knowledge_base.md#agent-legibility`. **Self-verify final response** vs request, diff, proof, blockers, residual risk.
- **Report:** **Report only after Verify.** **Surgical diff:** each changed line traces to request or required validation/doc update.

Doc/host changes: `./tool/check_agent_knowledge_base.sh` + asset drift path; escalate to `./bin/checklist` if agent guidance changed materially.

## Multi-agent

Coordinator hub: gate before fan-out. **Team** when blast radius, cross-layer read, high-risk logic, separate implement/review bars, or user asked plan+implement+verify: create `tasks/cursor/team/<run-id>/` (`goal.md`, `findings.md`, `plan.md`, diff artifacts, `review.md`); coordinator owns validation. **Single** otherwise; log `Benefit: team - <reason>` or **`Benefit: single - <reason>`**. Pass **inline** context to specialists (never path-only); max 2 implementer fix loops unless user extends; specialist returns summary + verified artifacts only. Doctrine: `agent_knowledge_base.md#multi-agent-hub`.

## Completion gate

Non-trivial: AI review + tracker proof. UI: `./tool/check_design_md.sh` if `DESIGN.md` edited; Mix: `./tool/run_mix_lint.sh`. Prefer app-visible proof. Resolve validation failures; add focused tests when warranted.

## Commit rules

Inspect `git status` / `git diff` / `git diff --staged`. Imperative <=72-char subject; note tests run/skipped. Full bar: `docs/testing_overview.md`, `docs/validation_scripts.md`.
