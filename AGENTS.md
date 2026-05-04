# AGENTS - Flutter BLoC App Map

Map only. Repo docs under `docs/` are system of record; host assets stay thin.

## Authority

Priority: this map -> repo docs -> `.cursor/rules/*.mdc` -> synced host adapters.
Done = Plan, Execute, Verify, Report proof.
This root file is repo-local source map; `tool/agent_host_templates/codex/AGENTS.md`
is Codex host bootstrap template synced to ~/.codex/AGENTS.md.

## Start

1. `AGENTS.md`
2. [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
3. [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
4. [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
5. task docs from [`docs/README.md`](docs/README.md)

## Snapshot

Flutter 3.41.9 / Dart 3.11.5. Clean Architecture:
`Presentation -> Domain <- Data`; Cubit/BLoC, `get_it`, GoRouter.
Offline-first sync: `lib/shared/sync/`. Entrypoints: `lib/main_dev.dart`,
`lib/main_staging.dart`, `lib/main_prod.dart`.

## Loop

Plan once. Execute end-to-end. Verify. Report proof.
Ask only on blockers: credentials/tooling, unsafe ambiguity below 95% confident,
or user-owned decision. Non-trivial work tracks plan/proof in
`tasks/codex/todo.md` or `tasks/cursor/todo.md`.

## Map

- Harness: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
- Review: [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
- Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
- Docs index: [`docs/README.md`](docs/README.md)
- Validation: [`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
- Architecture: [`docs/architecture_details.md`](docs/architecture_details.md),
  [`docs/clean_architecture.md`](docs/clean_architecture.md)
- Quality: [`docs/CODE_QUALITY.md`](docs/CODE_QUALITY.md),
  [`docs/testing_overview.md`](docs/testing_overview.md)
- Lifecycle: [`docs/REPOSITORY_LIFECYCLE.md`](docs/REPOSITORY_LIFECYCLE.md),
  [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md)
- Offline-first: [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md),
  [`docs/offline_first/hive_schema_migrations.md`](docs/offline_first/hive_schema_migrations.md)
  (runtime `getBox()` → `ensureSchema`; manifest when shape changes),
  [`docs/engineering/delayed_work_guide.md`](docs/engineering/delayed_work_guide.md)
- Plans/history: [`docs/plans/README.md`](docs/plans/README.md),
  [`docs/changes/README.md`](docs/changes/README.md),
  [`docs/audits/README.md`](docs/audits/README.md)
- Host notes: [`docs/agent_host_notes.md`](docs/agent_host_notes.md)

## Must Keep

- Smallest reversible change meeting goal + reliability bar.
- Surgical diff: every changed line traces to request or required validation/doc update.
- Shared state in Cubit/BLoC; domain pure Dart; update DI/routes/l10n/codegen when touched.
- Widget-test viewport/pixel-ratio setup uses `WidgetTester.view`.
- Repeated failure => add repo capability, not longer prompt.
- Verified reusable agent conclusion => owning source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`.

## Commands

- Bootstrap: `bash tool/agent_session_bootstrap.sh`
- Full/pre-ship: `./bin/checklist`
- Fast docs/tooling: `./bin/checklist-fast`
- Router/auth/gates: `./bin/router_feature_validate`
- Integration flows: `./bin/integration_tests`
- Agent/docs: `./tool/check_agent_knowledge_base.sh`
- Host templates: `./tool/check_agent_asset_drift.sh` + `./tool/sync_agent_assets.sh --dry-run`
