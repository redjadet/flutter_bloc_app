# Agent Quick Reference

Compact cheat sheet for all hosts. **[`AGENTS.md`](../AGENTS.md) is
authoritative** when this page drifts or omits detail.

If [`AGENTS.md`](../AGENTS.md) is unavailable in the current host context, use this page plus
[`ai_code_review_protocol.md`](ai_code_review_protocol.md) as the repo-visible
fallback.

## Repo snapshot

- Flutter 3.41.6 / Dart 3.11.4

## Read First

1. [`AGENTS.md`](../AGENTS.md)
1. This page for commands, adapter names, and doc routes
1. [`ai_code_review_protocol.md`](ai_code_review_protocol.md)
1. Then open only the task-specific docs you need

## Core Commands

| Scope | Command |
| --- | --- |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship or explicit full sweep | `./bin/checklist` |
| Integration journey | `./bin/integration_tests` |
| SDK/tooling maintenance | `./bin/upgrade_validate_all` |
| Cross-host diff review with a different host | `./tool/request_codex_feedback.sh` |

Fastlane:

- `./tool/fastlane.sh lanes`
- `./tool/fastlane.sh android play_upload_track track:internal`
- `./tool/fastlane.sh android play_promote_track`
- `./tool/fastlane.sh ios upload_testflight`
- `./tool/fastlane.sh ios deploy`

## Host Adapters

| Need | Cursor | Codex |
| --- | --- | --- |
| Fast orientation | `agents-quick-reference` | `flutter-bloc-app-quick-reference` |
| Non-trivial delivery flow | `agents-delivery-workflow` | `flutter-bloc-app-delivery-workflow` |
| Completion / review bar | `agents-completion-gate`, `agents-meta-behavior` | `flutter-bloc-app-delivery-workflow` + [`ai_code_review_protocol.md`](ai_code_review_protocol.md) |
| Delegation / subagents | `agents-subagent-policy` | `flutter-bloc-app-subagent-policy` |
| Cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` with a different host | `flutter-bloc-app-cross-host-review` or `./tool/request_codex_feedback.sh` with a different host |
| Approved command routing | `agents-workflow-commands` | repo shell entrypoints directly |

## Common Flow

1. Read [`AGENTS.md`](../AGENTS.md), this page, and the review protocol.
2. For non-trivial work, write plan + verification notes in the active host
   tracker:
   [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) for Cursor,
   [`tasks/codex/todo.md`](../tasks/codex/todo.md) for Codex.
3. Reuse existing repo seams before adding abstractions.
4. Apply the AI review gate before trusting the change.
5. Run the smallest matching validation command.
6. Prove the result with scope-matched evidence.

## Triage

| Work shape | Default path |
| --- | --- |
| Small/local code change | Read the canon, reuse existing seams, run targeted validation, prove behavior. |
| Docs-only agent guidance or workflow change | Update the docs, validate links/docs, run host-asset drift checks if templates changed, use `./bin/checklist` only for broader sweeps. |
| Non-trivial multi-file or architecture work | Record plan + verification in the active host tracker before editing, then follow the common flow. |
| Explicit second-opinion request | Use a different host via `./tool/request_codex_feedback.sh`; do not self-delegate. |

## Validation Routing

| Change shape | Command |
| --- | --- |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad, pre-ship, or explicit full sweep | `./bin/checklist` |
| Integration journey / flow verification | `./bin/integration_tests` |
| SDK/tooling maintenance | `./bin/upgrade_validate_all` |
| Repo-managed host-template drift check | `./tool/check_agent_asset_drift.sh` |
| Host-template preview sync | `./tool/sync_agent_assets.sh --dry-run` |
| Cross-host second opinion with a different host | `./tool/request_codex_feedback.sh` |

## Read By Task

- Product/setup context: [`new_developer_guide.md`](new_developer_guide.md)
- Feature work: [`clean_architecture.md`](clean_architecture.md), [`architecture_details.md`](architecture_details.md), [`feature_overview.md`](feature_overview.md)
- Validation: [`validation_scripts.md`](validation_scripts.md), [`testing_overview.md`](testing_overview.md)
- Lifecycle: [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Offline-first: [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md)
- Supabase Edge / chat proxy: [`../supabase/README.md`](../supabase/README.md)
- gstack: [`gstack_integration.md`](gstack_integration.md)
- Staff app demo (routes, Firestore, walkthrough):
  [`staff_app_demo_walkthrough.md`](staff_app_demo_walkthrough.md)

## High-Signal Reminders

- Host adapters are accelerators only. If a Cursor rule/command or Codex skill
  drifts from repo canon, follow [`AGENTS.md`](../AGENTS.md).
- For non-trivial work, keep task spec, plan, and verification in the active
  host tracker.
- Prefer repo-visible docs and repo shell entrypoints over host-local
  assumptions or wrappers.
- Reuse `lib/shared/`, `lib/core/`, and adjacent feature patterns before adding
  abstractions.
- Keep `build()` pure and keep expensive transforms off the UI isolate.
- In `lib/**/presentation/**`, do not use `Isolate.run(() => ...)`; use
  `compute` with a top-level/static callback.
- Dialogs/overlays: inherited providers may not reach `showDialog` builders;
  use `BlocProvider.value` (or explicit parameters) when the dialog needs a
  cubit from the route shell.
- Update DI, routes, l10n, and codegen when touched.
- For async flows, verify loading, empty, and error states or record why
  existing coverage already covers them.
- For bug fixes, prefer a focused regression guard.
- Prefer targeted validation first; reserve `./bin/checklist` for broad or
  pre-ship sweeps, or when explicitly requested.
- For docs-only agent-guidance or host-template changes, still validate docs,
  links, and host-asset drift rather than treating the work as no-op prose.
- For `supabase/functions/chat-complete`, keep `verify_jwt = true` and verify
  Dashboard `Verify JWT with legacy secret` stays disabled unless the project
  intentionally uses legacy JWT secrets.
- For chat transport changes, preserve direct-vs-Edge error-code alignment:
  `401 auth_required`, `403 forbidden`, `429 rate_limited`, timeout
  `upstream_timeout`, generic transport/5xx `upstream_unavailable`, and
  model/request `4xx` such as `404` -> `invalid_request`.
