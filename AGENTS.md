# AGENTS - Flutter BLoC App Map

Map only. Repo docs under `docs/` are system of record; host assets stay thin.
No learned bullets or long prose here—link to owning `docs/` (see
[`docs/agent_knowledge_base.md#operator-preferences-durable`](docs/agent_knowledge_base.md#operator-preferences-durable)).

## Authority

Priority: this map -> repo docs -> `.cursor/rules/*.mdc` -> synced host adapters.
Done = Plan, Execute, Verify, Report proof.
Source map: this file. Codex host sync copies this file to the Codex home
AGENTS file and Codex worktrees.

## Start

1. `AGENTS.md`
2. Canonical ladder: [`docs/ai/context_loading.md`](docs/ai/context_loading.md); skills: [`docs/ai/skill_routing.md`](docs/ai/skill_routing.md)
3. Review/commands when needed:
   [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md),
   [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)

## Snapshot

Flutter 3.44.4 / Dart 3.12.2. Pinned facts and caveats:
[`docs/agent_project_context.md`](docs/agent_project_context.md),
[`docs/tech_stack.md`](docs/tech_stack.md).

## Loop

Plan once -> execute end-to-end -> verify -> Report proof. Ask only blockers
(credentials/tooling, unsafe ambiguity below 95% confident, user-owned choice).
Non-trivial work: [`docs/ai/ai_failure_risks.md`](docs/ai/ai_failure_risks.md) Pre-Flight +
`agents-common-pitfalls`; [`tasks/codex/todo.md`](tasks/codex/todo.md) or
[`tasks/cursor/todo.md`](tasks/cursor/todo.md) + context ladder + one observe/revise loop.
Outcome: Goal / Context / Boundaries / Verification. Finish gate:
[`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md).
Long session health: compact evidence, watch context drift, reset plan when state corrupts.

## Map

- Doctrine: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
- Harness scorecard: [`docs/ai/harness_scorecard.md`](docs/ai/harness_scorecard.md)
- Harness auto-maintenance: [`docs/ai/harness_auto_maintenance.md`](docs/ai/harness_auto_maintenance.md)
- AI failure risks: [`docs/ai/ai_failure_risks.md`](docs/ai/ai_failure_risks.md)
- Project context: [`docs/agent_project_context.md`](docs/agent_project_context.md)
- Environment setup: [`docs/agent_environment_setup.md`](docs/agent_environment_setup.md)
- Host maintain (agents run): [`docs/agent_kb/host_maintenance_automation.md`](docs/agent_kb/host_maintenance_automation.md) · `./bin/agent-maintain`
- Review: [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
- Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
- Docs index: [`docs/README.md`](docs/README.md)
- Feature harness: [`docs/architecture/feature_structure_contract.md`](docs/architecture/feature_structure_contract.md), [`docs/architecture/reference_features.md`](docs/architecture/reference_features.md), [`docs/architecture/use_case_dto_policy.md`](docs/architecture/use_case_dto_policy.md), [`docs/testing/matrix_required_by_change.md`](docs/testing/matrix_required_by_change.md)
- BLoC standards: [`docs/bloc_standards.md`](docs/bloc_standards.md), [`docs/bloc/cubit_file_template.md`](docs/bloc/cubit_file_template.md), [`docs/review/bloc_checklist.md`](docs/review/bloc_checklist.md), [`docs/review/security_checklist.md`](docs/review/security_checklist.md), [`docs/review/performance_checklist.md`](docs/review/performance_checklist.md)
- Design/UI: [`DESIGN.md`](DESIGN.md), [`docs/design_system.md`](docs/design_system.md)
- Validation: [`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
- Architecture: [`docs/architecture_details.md`](docs/architecture_details.md), [`docs/clean_architecture.md`](docs/clean_architecture.md), [`docs/architecture/reduce_surprise_patterns.md`](docs/architecture/reduce_surprise_patterns.md)
- Quality: [`docs/CODE_QUALITY.md`](docs/CODE_QUALITY.md), [`docs/testing_overview.md`](docs/testing_overview.md)
- Lifecycle: [`docs/REPOSITORY_LIFECYCLE.md`](docs/REPOSITORY_LIFECYCLE.md), [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md)
- Offline-first: [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md), [`docs/offline_first/hive_schema_migrations.md`](docs/offline_first/hive_schema_migrations.md)
- Plans/history: [`docs/plans/README.md`](docs/plans/README.md), [`docs/changes/README.md`](docs/changes/README.md), [`docs/audits/README.md`](docs/audits/README.md)
- AI engineering: [`PLAN.md`](PLAN.md), [`CODEMAP.md`](CODEMAP.md), [`docs/ai/governance.md`](docs/ai/governance.md), [`docs/ai/skill_routing.md`](docs/ai/skill_routing.md), [`docs/ai/agent_operating_manual.md`](docs/ai/agent_operating_manual.md), [`ai/reports/README.md`](ai/reports/README.md)
- Host/env notes: [`docs/agent_host_notes.md`](docs/agent_host_notes.md), [`docs/agent_environment_setup.md`](docs/agent_environment_setup.md)
- Operator prefs/learning: [`docs/agent_knowledge_base.md#operator-preferences-durable`](docs/agent_knowledge_base.md#operator-preferences-durable)
- Interview/portfolio walk: [`docs/interview_showcase.md`](docs/interview_showcase.md), [`docs/adr/0005-interview-showcase-scope.md`](docs/adr/0005-interview-showcase-scope.md)
- Observability (Crashlytics when Firebase on; analytics doc-only): [`docs/observability.md`](docs/observability.md), [`docs/plans/future_observability.md`](docs/plans/future_observability.md)

## Must Keep

Invariants only — expanded rules in [`docs/agent_project_context.md`](docs/agent_project_context.md) § Current Caveat Shortlist.

- Smallest reversible change; Surgical diff: every changed line traces to request or required validation/doc update.
- Flutter/UI edits: hot reload when session active; runtime bugs → DTD — [`docs/agent_kb/tool_orchestration.md`](docs/agent_kb/tool_orchestration.md), [`docs/agent_kb/devtools_runtime_errors.md`](docs/agent_kb/devtools_runtime_errors.md).
- Flutter SDK/framework is read-only; do not patch `/Flutter_SDK/flutter/**` or Dart/Flutter toolchain sources to fix app issues.
- Pub APIs: MCP + pinned source — [`docs/agent_kb/package_docs_mcp.md`](docs/agent_kb/package_docs_mcp.md).
- Presentation Cubit/BLoC only; domain pure Dart; wire DI/routes/l10n/codegen when touched — [`docs/clean_architecture.md`](docs/clean_architecture.md).
- Platforms & UI: `flutter-cross-platform-modern`; [`DESIGN.md`](DESIGN.md) + [`docs/design_system.md`](docs/design_system.md) (reusable widgets, responsive layout, cross-platform form factors).
- Widget tests — [`docs/testing_overview.md`](docs/testing_overview.md), [`docs/testing/widget_test_playbook.md`](docs/testing/widget_test_playbook.md).
- Destructive/external side effects: confirm same turn; list affected items first.
- Coding reports: Files Changed + Follow-up Actions.
- Repeated failure ⇒ repo capability — [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md) § Missing Capability Loop.
- Host maintain: `agent-maintain preflight` / `agent-maintain closeout` — [`docs/agent_kb/host_maintenance_automation.md`](docs/agent_kb/host_maintenance_automation.md), [`docs/ai/harness_auto_maintenance.md`](docs/ai/harness_auto_maintenance.md).
- Verified reusable agent conclusion → owning doc / [`tasks/lessons.md`](tasks/lessons.md); never `## Learned *` here — [`docs/agent_kb/operator_preferences_durable.md`](docs/agent_kb/operator_preferences_durable.md).
