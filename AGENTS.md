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
2. Canonical ladder: [`docs/ai/context_loading.md`](docs/ai/context_loading.md)
3. Review/commands when needed:
   [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md),
   [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)

## Snapshot

Flutter 3.44.1 / Dart 3.12.1. Clean Architecture:
`Presentation -> Domain <- Data`; Cubit/BLoC, `get_it`, GoRouter.
Offline-first sync: `lib/shared/sync/`.

## Loop

Plan once -> execute end-to-end -> verify -> Report proof. Ask only blockers
(credentials/tooling, unsafe ambiguity below 95% confident, user-owned choice).
Non-trivial work: [`tasks/codex/todo.md`](tasks/codex/todo.md) or
[`tasks/cursor/todo.md`](tasks/cursor/todo.md) + context ladder + one
observe/revise loop.
Outcome: Goal / Context / Boundaries / Verification. Finish gate:
[`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md).
Long session health: compact evidence, watch context drift, reset plan when state corrupts.

## Map

- Harness: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
- Project context: [`docs/agent_project_context.md`](docs/agent_project_context.md)
- Environment setup: [`docs/agent_environment_setup.md`](docs/agent_environment_setup.md)
- Review: [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
- Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
- Docs index: [`docs/README.md`](docs/README.md)
- Design/UI: [`DESIGN.md`](DESIGN.md), [`docs/design_system.md`](docs/design_system.md)
- Validation: [`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
- Architecture: [`docs/architecture_details.md`](docs/architecture_details.md), [`docs/clean_architecture.md`](docs/clean_architecture.md)
- Quality: [`docs/CODE_QUALITY.md`](docs/CODE_QUALITY.md), [`docs/testing_overview.md`](docs/testing_overview.md)
- Lifecycle: [`docs/REPOSITORY_LIFECYCLE.md`](docs/REPOSITORY_LIFECYCLE.md), [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md)
- Offline-first: [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md), [`docs/offline_first/hive_schema_migrations.md`](docs/offline_first/hive_schema_migrations.md)
- Plans/history: [`docs/plans/README.md`](docs/plans/README.md), [`docs/changes/README.md`](docs/changes/README.md), [`docs/audits/README.md`](docs/audits/README.md)
- AI engineering: [`PLAN.md`](PLAN.md), [`CODEMAP.md`](CODEMAP.md), [`docs/ai/governance.md`](docs/ai/governance.md), [`ai/reports/README.md`](ai/reports/README.md)
- Host/env notes: [`docs/agent_host_notes.md`](docs/agent_host_notes.md), [`docs/agent_environment_setup.md`](docs/agent_environment_setup.md)
- Operator prefs/learning: [`docs/agent_knowledge_base.md#operator-preferences-durable`](docs/agent_knowledge_base.md#operator-preferences-durable)
- Interview/portfolio walk: [`docs/interview_showcase.md`](docs/interview_showcase.md), [`docs/adr/0005-interview-showcase-scope.md`](docs/adr/0005-interview-showcase-scope.md)
- Observability (Crashlytics when Firebase on; analytics doc-only): [`docs/observability.md`](docs/observability.md), [`docs/plans/future_observability.md`](docs/plans/future_observability.md)

## Must Keep

- Smallest reversible change; Surgical diff: every changed line traces to request or required validation/doc update.
- Flutter app-code/UI edits: hot reload active controllable debug session; hot restart when needed; see [`docs/agent_kb/tool_orchestration.md`](docs/agent_kb/tool_orchestration.md).
- Shared state in Cubit/BLoC; domain pure Dart; update DI/routes/l10n/codegen when touched.
- UI/design: read `DESIGN.md` + `docs/design_system.md`; use `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`; prove responsive/no-overlap states.
- Widget tests: [`docs/testing_overview.md`](docs/testing_overview.md) § Feature-defined testing; layout-sensitive sizing in [`docs/testing/widget_test_playbook.md`](docs/testing/widget_test_playbook.md).
- Destructive/external side effects need current-turn confirmation: list affected items first.
- Reports after coding tasks include Files Changed and Follow-up Actions.
- Repeated failure => add repo capability, not longer prompt.
- Verified reusable agent conclusion => owning source doc, `docs/changes/`, `docs/plans/`, or [`tasks/lessons.md`](tasks/lessons.md); never add `## Learned *` sections here—land durable prefs/facts in [`docs/agent_kb/operator_preferences_durable.md`](docs/agent_kb/operator_preferences_durable.md) (linked from [`docs/agent_knowledge_base.md#operator-preferences-durable`](docs/agent_knowledge_base.md#operator-preferences-durable)).
