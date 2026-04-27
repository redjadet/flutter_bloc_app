# AGENTS - Flutter BLoC App

Map for Cursor/Codex/Gemini CLI/Claude Code/Copilot. TOC, not handbook. Repo
map + docs beat host guidance. Don’t mention this file or `GEMINI.md` in
user-facing docs/changelogs/comments.

## Authority

Priority: this map -> repo docs -> `.cursor/rules/*.mdc` -> synced host
adapters. Repo docs under `docs/` are system of record; host assets stay thin.
Done = Plan, Execute, Verify, Report (+ proof).

## Start Here

Read only task-relevant sources:

1. `AGENTS.md`
2. [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
3. [`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md)
4. [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md) for command lookup
5. task-specific docs from [`docs/README.md`](docs/README.md)

If quick reference missing, use
[`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
plus repo shell entrypoints.

Bootstrap: `bash tool/agent_session_bootstrap.sh`

## Repo Snapshot

Flutter 3.41.7 / Dart 3.11.5. Clean Architecture:
`Presentation -> Domain <- Data`. Cubit/BLoC state, `get_it` DI, GoRouter.
Offline-first sync: `lib/shared/sync/`. Entrypoints: `lib/main_dev.dart`,
`lib/main_staging.dart`, `lib/main_prod.dart`.

## Loop

Plan once, then execute end-to-end. Ask only on hard blockers: credentials/tooling,
unsafe ambiguity below 95% confidence, or user-owned product decision. Verify with
[`docs/ai_code_review_protocol.md`](docs/ai_code_review_protocol.md) + smallest
honest repo command. Report proof, blockers, residual risk. Non-trivial work
tracks plan/proof in `tasks/codex/todo.md` or `tasks/cursor/todo.md`.

## Knowledge Map

- Harness: [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md)
- Index: [`docs/README.md`](docs/README.md)
- Commands: [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md)
- Validation:
  [`docs/engineering/validation_routing_fast_vs_full.md`](docs/engineering/validation_routing_fast_vs_full.md)
- Architecture: [`docs/architecture_details.md`](docs/architecture_details.md),
  [`docs/clean_architecture.md`](docs/clean_architecture.md)
- Quality: [`docs/CODE_QUALITY.md`](docs/CODE_QUALITY.md),
  [`docs/testing_overview.md`](docs/testing_overview.md)
- Lifecycle/reliability: [`docs/REPOSITORY_LIFECYCLE.md`](docs/REPOSITORY_LIFECYCLE.md),
  [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md)
- Offline-first: [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md),
  [`docs/engineering/delayed_work_guide.md`](docs/engineering/delayed_work_guide.md)
- Plans/history: [`docs/plans/README.md`](docs/plans/README.md),
  [`docs/changes/README.md`](docs/changes/README.md),
  [`docs/audits/README.md`](docs/audits/README.md)

## Non-Negotiables

- Smallest reversible change that meets goal + reliability bar.
- Don’t edit until 95% confident in goal/scope/approach; ask until clear.
- Vague ask => state assumptions + success criteria before edits.
- Bug fix => reproduce or reason to root cause before changing code.
- Scale-think when touching routing/shared architecture/sync/lifecycle/security/validation/CI/ops load.
- Shared state in Cubit/BLoC; `setState` only ephemeral UI.
- `build()` pure. Domain pure Dart. Update DI/routes/l10n/codegen when touched.
- New user-visible feature needs app entrypoint unless doc says route-only intentional.
- Surgical diff: every changed line traces to request or required validation/doc update.
- Repeated failure => add missing repo capability: doc/fixture/test/script/UI proof/log helper/validation check.
- Widget-test viewport/pixel-ratio setup uses `WidgetTester.view`, not deprecated `tester.binding.window`.
- Use shared lifecycle helpers before custom subscription/timer tracking.
- Retry/replay GET/HEAD only unless call site opts in.
- `PendingSyncRepository.enqueue` dedupes by entity type, idempotency key, best-effort user scope.
- App resume sync stays debounced; rapid lifecycle events must not overlap flushes.

## Validation

Use repo entrypoints, not host-only wrappers.

- Broad/pre-ship/explicit full sweep: `./bin/checklist`
- Fast local docs/tooling sanity: `./bin/checklist-fast`
- Router/auth/gates: `./bin/router_feature_validate`
- Integration flows: `./bin/integration_tests`
- Agent/docs changes: markdown/link checks + `./tool/check_agent_knowledge_base.sh`
- Host-template changes: also `./tool/check_agent_asset_drift.sh` +
  `./tool/sync_agent_assets.sh --dry-run`

## Host Notes

- Codex: use `tasks/codex/todo.md`; don’t invoke `./tool/request_codex_feedback.sh`
  unless user asks for cross-host review.
- Cursor: use `tasks/cursor/todo.md`; slash commands stay thin wrappers over
  repo scripts.
- Subagents are draft-producing helpers only: bounded scope, disjoint writes,
  main agent owns review and verification.
