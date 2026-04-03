# Agent Quick Reference

Compact cheat sheet for all hosts. **[`AGENTS.md`](../AGENTS.md) is
authoritative** when this page drifts or omits detail.

## Repo snapshot

- Flutter 3.41.6 / Dart 3.11.4

## Read First

1. [`AGENTS.md`](../AGENTS.md)
1. This page for commands, adapter names, and doc routes
1. [`ai_code_review_protocol.md`](ai_code_review_protocol.md)

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

## Read By Task

- Cold start: [`AGENTS.md`](../AGENTS.md), [`new_developer_guide.md`](new_developer_guide.md)
- Feature work: [`clean_architecture.md`](clean_architecture.md), [`architecture_details.md`](architecture_details.md), [`feature_overview.md`](feature_overview.md)
- Validation: [`validation_scripts.md`](validation_scripts.md), [`testing_overview.md`](testing_overview.md)
- Lifecycle: [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Offline-first: [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md)
- gstack: [`gstack_integration.md`](gstack_integration.md)

## High-Signal Reminders

- For non-trivial work, keep task spec, plan, and verification in
  [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or
  [`tasks/codex/todo.md`](../tasks/codex/todo.md).
- Reuse `lib/shared/`, `lib/core/`, and adjacent feature patterns before adding
  abstractions.
- Keep `build()` pure and keep expensive transforms off the UI isolate.
- In `lib/**/presentation/**`, do not use `Isolate.run(() => ...)`; use
  `compute` with a top-level/static callback.
- Update DI, routes, l10n, and codegen when touched.
- For async flows, verify loading, empty, and error states or record why
  existing coverage already covers them.
- For bug fixes, prefer a focused regression guard.
- Prefer targeted validation first; reserve `./bin/checklist` for broad or
  pre-ship sweeps, or when explicitly requested.
