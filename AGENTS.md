# AGENTS - Flutter BLoC App Map

Map only. Repo `docs/` canon; host assets thin. No learned prose here—use the
owner doc ([operator preferences](docs/agent_knowledge_base.md#operator-preferences-durable)).

## Authority

Priority: map -> repo docs -> `.cursor/rules/*.mdc` -> synced host adapters.
Done: Plan, Execute, Verify, Report proof. This source syncs to Codex home and
worktrees.

## Start

1. `AGENTS.md`
2. Canonical context ladder: [`docs/ai/context_loading.md`](docs/ai/context_loading.md) →
   one matching skill from [`docs/ai/skill_routing.md`](docs/ai/skill_routing.md)
3. Route by task: `./bin/agent-maintain tools --intent "<goal>" --paths <files>`.
   Owner unknown: [`docs/README.md`](docs/README.md).

## Loop

Plan once → execute → verify → report proof. Ask only credentials/tooling,
unsafe ambiguity below 95% confident, or user-owned choice. Non-trivial: [`AI Failure
Risks`](docs/ai/ai_failure_risks.md) Pre-Flight + `agents-common-pitfalls` +
`./bin/agent-maintain preflight`; record Goal / Context / Boundaries /
Verification in [`tasks/codex/todo.md`](tasks/codex/todo.md) or
[`tasks/cursor/todo.md`](tasks/cursor/todo.md). Compact evidence; reset corrupt
context. Finish gate: [`Agent Knowledge Base`](docs/agent_knowledge_base.md).

## Map

- Agent system: [`knowledge base`](docs/agent_knowledge_base.md),
  [`safety contracts`](docs/agent_kb/agent_safety_contracts.md),
  [`project context`](docs/agent_project_context.md), [`operating manual`](docs/ai/agent_operating_manual.md),
  [`harness scorecard`](docs/ai/harness_scorecard.md), [`harness maintenance`](docs/ai/harness_auto_maintenance.md),
  [`host maintenance`](docs/agent_kb/host_maintenance_automation.md), [`host notes`](docs/agent_host_notes.md).
- Commands / quality: [`quick reference`](docs/agents_quick_reference.md),
  [`validation routing`](docs/engineering/validation_routing_fast_vs_full.md),
  [`engineering scorecard`](docs/engineering/engineering_quality_scorecard.md),
  [`testing`](docs/testing_overview.md), [`code quality`](docs/CODE_QUALITY.md).
- Build / review: [`architecture`](docs/clean_architecture.md), [`feature contract`](docs/architecture/feature_structure_contract.md),
  [`reference features`](docs/architecture/reference_features.md), [`BLoC`](docs/bloc_standards.md),
  [`review playbook`](docs/review/code_review_playbook.md), [`AI review`](docs/ai_code_review_protocol.md),
  [`Git workflow`](docs/git_and_branching_strategy.md).
- Product / platform: [`DESIGN.md`](DESIGN.md), [`design system`](docs/design_system.md),
  [`offline first`](docs/offline_first/adoption_guide.md), [`reliability`](docs/reliability_error_handling_performance.md),
  [`observability`](docs/observability.md).
- Navigation / history: [`docs index`](docs/README.md),
  [`changes`](docs/changes/README.md), [`audits`](docs/audits/README.md), [`CODEMAP.md`](CODEMAP.md),
  [`PLAN.md`](PLAN.md), [`llms.txt`](llms.txt), [`environment`](docs/agent_environment_setup.md).

## Must Keep

Invariants only — expanded rules in [`docs/agent_project_context.md`](docs/agent_project_context.md) § Current Caveat Shortlist.

- Smallest reversible change; Surgical diff: every changed line traces to request or required validation/doc update; follow [`agent_safety_contracts.md`](docs/agent_kb/agent_safety_contracts.md) (`SAFETY-01..06`, `SAFETY-REPORT`).
- Flutter/UI edits: hot reload when session active; runtime bugs → DTD — [`docs/agent_kb/tool_orchestration.md`](docs/agent_kb/tool_orchestration.md), [`docs/agent_kb/devtools_runtime_errors.md`](docs/agent_kb/devtools_runtime_errors.md).
- Flutter SDK/framework is read-only; do not patch `/Flutter_SDK/flutter/**` or Dart/Flutter toolchain sources to fix app issues.
- Pub APIs: MCP + pinned source — [`docs/agent_kb/package_docs_mcp.md`](docs/agent_kb/package_docs_mcp.md).
- Clean Architecture + SOLID are mandatory: `Presentation -> Domain <- Data`; domain pure Dart; wire DI/routes/l10n/codegen when touched — [`docs/clean_architecture.md`](docs/clean_architecture.md), [`docs/architecture/solid_principles.md`](docs/architecture/solid_principles.md), [`docs/review/architecture_checklist.md`](docs/review/architecture_checklist.md).
- Platforms & UI: `flutter-cross-platform-modern`; [`DESIGN.md`](DESIGN.md) + [`docs/design_system.md`](docs/design_system.md) (reusable widgets, responsive layout, cross-platform form factors).
- Widget tests — [`docs/testing_overview.md`](docs/testing_overview.md), [`docs/testing/widget_test_playbook.md`](docs/testing/widget_test_playbook.md).
- Git / branch / PR / worktree actions — [`docs/git_and_branching_strategy.md`](docs/git_and_branching_strategy.md); inspect state first and preserve user work.
- Destructive/external side effects: confirm same turn; list affected items first.
- Coding reports: Files Changed + Follow-up Actions.
- After `.dart` changes: `./bin/format` (or `dart format .`) before finish — [`docs/agent_kb/operator_preferences_durable.md`](docs/agent_kb/operator_preferences_durable.md) § Validation.
- Repeated failure ⇒ repo capability — [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md) § Missing Capability Loop.
- Host maintain: `agent-maintain preflight` / `agent-maintain closeout` — [`docs/agent_kb/host_maintenance_automation.md`](docs/agent_kb/host_maintenance_automation.md), [`docs/ai/harness_auto_maintenance.md`](docs/ai/harness_auto_maintenance.md).
- Verified reusable agent conclusion → owning doc / [`tasks/lessons.md`](tasks/lessons.md); never `## Learned *` here — [`docs/agent_kb/operator_preferences_durable.md`](docs/agent_kb/operator_preferences_durable.md).
