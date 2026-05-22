# AGENTS - Flutter BLoC App Map

Map only. Repo docs under `docs/` are system of record; host assets stay thin.

## Authority

Priority: this map -> repo docs -> `.cursor/rules/*.mdc` -> synced host adapters.
Done = Plan, Execute, Verify, Report proof.
Template source: `tool/agent_host_templates/codex/AGENTS.md` -> ~/.codex/AGENTS.md.

## Start

1. `AGENTS.md`
2. [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
3. [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
4. [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
5. task docs from [`docs/README.md`](docs/README.md)

## Snapshot

Flutter 3.44.0 / Dart 3.12.0. Clean Architecture:
`Presentation -> Domain <- Data`; Cubit/BLoC, `get_it`, GoRouter.
Offline-first sync: `lib/shared/sync/`.

## Loop

Plan once -> execute end-to-end -> verify -> Report proof. Ask only blockers
(credentials/tooling, unsafe ambiguity below 95% confident, user-owned choice).
Non-trivial work: [`tasks/codex/todo.md`](../../../tasks/codex/todo.md) + context ladder + one observe/revise loop.
Vague/risky details: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md).

- Outcome: Goal / Context / Boundaries / Verification; exact steps only when path matters.
- Self-check final response vs request, diff, proof, blockers, risk.
- Prove result before calling work done.
- Long session health: compact evidence, watch context drift, reset plan when state corrupts.
- File verified reusable conclusions into owning source doc (`docs/changes/`, `docs/plans/`, or [`tasks/lessons.md`](../../../tasks/lessons.md)).

## Communication

Inside `flutter_bloc_app`, default every Codex session to full caveman mode:
drop articles, filler, pleasantries, and hedging; fragments OK; keep technical
terms exact. Write code, commits, PR text, security warnings,
destructive-action confirmations, and external messages in normal precise
prose. "stop caveman" or "normal mode" disables this.

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
- Host notes: [`docs/agent_host_notes.md`](docs/agent_host_notes.md)

## Must Keep

- Smallest reversible change; Surgical diff: every changed line traces to request or required validation/doc update.
- Shared state in Cubit/BLoC; domain pure Dart; update DI/routes/l10n/codegen when touched.
- UI/design: read `DESIGN.md` + `docs/design_system.md`; use `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`; prove responsive/no-overlap states.
- Widget tests: [`docs/testing_overview.md`](docs/testing_overview.md) § Feature-defined testing; layout-sensitive sizing in [`docs/testing/widget_test_playbook.md`](docs/testing/widget_test_playbook.md).
- Repeated failure => add repo capability, not longer prompt.
