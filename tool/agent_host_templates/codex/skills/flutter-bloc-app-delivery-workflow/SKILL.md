---
name: flutter-bloc-app-delivery-workflow
description: Non-trivial delivery for Codex — planning, execution, validation, subagent rules, and completion evidence.
---

# Flutter BLoC app delivery workflow

Use at non-trivial start and before done.

Default: **Plan -> Execute -> Verify -> Report**. Plan once. Ask only hard blockers. Trigger routing: `docs/agents_quick_reference.md#automatic-workflow-triggers`.

- **Plan:** `AGENTS.md` -> `docs/agent_knowledge_base.md`; existing code uses context ladder; tracker = `tasks/codex/todo.md`.
- **Plan:** do not edit until 95% confident; if vague/risky, define boundaries, data flow, failure handling, smallest proof.
- **Plan:** one loop (`plan -> tool -> observe -> revise`); branch only when risk pays. High-risk architecture/debug => compare 2-3 candidate approaches with evidence, then choose one.
- **Plan:** use repo tools, code graph, browser/app proof, and MCP/connectors when they own current state; prompts alone are not proof.
- **Plan:** enforce TDD when practical, linting, build verification, minimal edits, architecture preservation; avoid giant prompts, giant rewrites, context flooding, single-agent overload, unverified outputs.
- **Execute:** reuse seams; keep `Presentation -> Domain <- Data`; update DI/routes/l10n/codegen when touched.
- **Execute:** UI/design/Mix -> `DESIGN.md` + `docs/design_system.md`; use `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.
- **Execute:** lifecycle -> `docs/REPOSITORY_LIFECYCLE.md` + `docs/reliability_error_handling_performance.md`.
- **Execute:** File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.
- **Verify:** `docs/ai_code_review_protocol.md`, smallest matching validation; empty/truncated tool output is not proof.
- **Verify:** runtime proof -> `docs/agent_knowledge_base.md#agent-legibility`.
- **Verify:** finish gate + Self-verify final response vs request, changed files, proof, blockers, residual risk.
- **Report:** Report only after Verify. Surgical diff: each changed line traces to request or required validation/doc update.

Validation picks:

- router / `AppRoutes` / gates / auth UI -> `./bin/router_feature_validate`
- broad / pre-ship -> `./bin/checklist`
- integration -> `./bin/integration_tests`
- upgrades/tooling -> `./bin/upgrade_validate_all`
- design brief -> `./tool/check_design_md.sh`; Mix token/style -> `./tool/run_mix_lint.sh`
- agent docs -> targeted doc checks + `./tool/check_agent_knowledge_base.sh`; semantic-lint stale plans, duplicate rules, source/host-template contradictions

Codex rules:

- Call repo shell entrypoints directly.
- Do not invoke `./tool/request_codex_feedback.sh` unless user explicitly asks second opinion/cross-host review.
- Confidence from proof; state material uncertainty.
- Host notes stay thin; repo canon wins.

## Subagents

Delegate only when it improves quality/speed/risk. Fewest agents, one goal each. Define scope/output/validation. Avoid multi-writer edits; default read-only. Don’t delegate current blocker. Subagent output = summary + verified artifacts, still draft; main agent integrates + validates. Repo canon wins.
