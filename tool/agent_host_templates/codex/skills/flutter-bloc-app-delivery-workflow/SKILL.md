---
name: flutter-bloc-app-delivery-workflow
description: Codex delivery loop; tracker path and validation picks are Codex-specific.
---

# Flutter BLoC app delivery (Codex)

Shared loop: **Plan -> Execute -> Verify -> Report**. Canon links: `AGENTS.md`, `docs/agent_knowledge_base.md`, `docs/agent_project_context.md`, `docs/ai_code_review_protocol.md`, `docs/agents_quick_reference.md`.

## Context ladder and durable memory

**context ladder:** map docs -> durable memory -> structural graph -> targeted raw-file reads. **File verified reusable conclusions** -> owning doc / `docs/changes/` / `docs/plans/` / `tasks/lessons.md`.

## Design/UI

Use `DESIGN.md` and `docs/design_system.md` before visual code.

## Codex-only

- Tracker: `tasks/codex/todo.md`.
- Lifecycle/reliability: `docs/REPOSITORY_LIFECYCLE.md`, `docs/reliability_error_handling_performance.md`.

- **Plan:** no edits before **95% confident**; one observe/revise loop; proof via tools/graph/browser/MCP.
  Separate intent/spec/implementation; specs need evals, implementation follows repo seams. Audit related landmines before feature/refactor.
- **Verify:** **Self-verify final response** vs request, diff, proof, blockers, risk.
- **Report:** **Report only after Verify.** **Surgical diff**: each changed line traces to request or required validation/doc update.

## Validation picks

- Router / gates / auth UI -> `./bin/router_feature_validate`
- Broad / pre-ship -> `./bin/checklist`
- Integration -> `./bin/integration_tests`
- Upgrade lane -> `./bin/upgrade_validate_all`
- Design brief -> `./tool/check_design_md.sh`; Mix -> `./tool/run_mix_lint.sh`
- Agent docs -> `./tool/check_agent_knowledge_base.sh`

## Codex rules

- Call repo shell entrypoints directly.
- Do not invoke `./tool/request_codex_feedback.sh` unless user asks cross-host second opinion.
- Proof-first; state material uncertainty. Repo canon wins.

## Subagents

Fewest agents; one objective each; read-only default; avoid multi-writer; never delegate current blocker; output = summary + verified artifacts (draft until coordinator validates). Details: `agents-meta-behavior`, `docs/agent_knowledge_base.md#multi-agent-hub`.
