# AGENTS - Flutter BLoC App

Map for Cursor/Codex/Gemini CLI/Claude Code/Copilot. TOC, not handbook.
Repo docs under `docs/` are system of record; host assets stay thin.

## Authority

Priority: this map -> repo docs -> `.cursor/rules/*.mdc` -> synced host
adapters. Done = Plan, Execute, Verify, Report proof.

## Start

Read only task-relevant sources:

1. `AGENTS.md`
2. [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
3. [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
4. [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
5. task docs from [`docs/README.md`](docs/README.md)

Bootstrap: `bash tool/agent_session_bootstrap.sh`

## Snapshot

Flutter 3.41.8 / Dart 3.11.5. Clean Architecture:
`Presentation -> Domain <- Data`; Cubit/BLoC, `get_it`, GoRouter.
Offline-first sync: `lib/shared/sync/`. Entrypoints: `lib/main_dev.dart`,
`lib/main_staging.dart`, `lib/main_prod.dart`.

## Loop

Plan once, execute end-to-end, verify, report proof. Ask only on blockers:
credentials/tooling, unsafe ambiguity below 95% confident, user-owned decision.
Non-trivial work: track plan/proof in `tasks/codex/todo.md` or
`tasks/cursor/todo.md`.

## Map

- Harness: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
- Review: [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
- Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
- Index: [`docs/README.md`](docs/README.md)
- Validation: [`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
- Architecture: [`docs/architecture_details.md`](docs/architecture_details.md),
  [`docs/clean_architecture.md`](docs/clean_architecture.md)
- Quality: [`docs/CODE_QUALITY.md`](docs/CODE_QUALITY.md),
  [`docs/testing_overview.md`](docs/testing_overview.md)
- Lifecycle: [`docs/REPOSITORY_LIFECYCLE.md`](docs/REPOSITORY_LIFECYCLE.md),
  [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md)
- Offline-first: [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md),
  [`docs/engineering/delayed_work_guide.md`](docs/engineering/delayed_work_guide.md)
- Plans/history: [`docs/plans/README.md`](docs/plans/README.md),
  [`docs/changes/README.md`](docs/changes/README.md),
  [`docs/audits/README.md`](docs/audits/README.md)
- Host notes: [`docs/agent_host_notes.md`](docs/agent_host_notes.md)

## Non-Negotiables

- Smallest reversible change meeting goal + reliability bar.
- Don’t edit until 95% confident in goal/scope/approach.
- Surgical diff: every changed line traces to request or required
  validation/doc update.
- Shared state in Cubit/BLoC; `setState` only ephemeral UI. `build()` pure.
- Domain pure Dart. Update DI/routes/l10n/codegen when touched.
- New user-visible feature needs app entrypoint unless doc says route-only.
- Widget-test viewport/pixel-ratio setup uses `WidgetTester.view`.
- Use shared lifecycle helpers before custom subscription/timer tracking.
- Retry/replay GET/HEAD only unless call site opts in.
- `PendingSyncRepository.enqueue` dedupes by entity type, idempotency key,
  best-effort user scope.
- App resume sync stays debounced; rapid lifecycle events must not overlap flushes.
- Repeated failure => add missing repo capability, not longer prompt.
- Verified reusable agent conclusion => owning source doc, `docs/changes/`,
  `docs/plans/`, or `tasks/lessons.md`.

## Validation

Use repo entrypoints. Pick smallest honest check.

- Full/pre-ship: `./bin/checklist`
- Fast docs/tooling: `./bin/checklist-fast`
- Router/auth/gates: `./bin/router_feature_validate`
- Integration flows: `./bin/integration_tests`
- Agent/docs: markdown/link checks + `./tool/check_agent_knowledge_base.sh`
- Host templates: `./tool/check_agent_asset_drift.sh` +
  `./tool/sync_agent_assets.sh --dry-run`
