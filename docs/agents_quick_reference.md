# Agent Quick Reference

Compact cheat sheet for all hosts. **[`AGENTS.md`](../AGENTS.md) is authoritative**
when this index drifts or omits detail.

## Read first

1. [`AGENTS.md`](../AGENTS.md) for policy, invariants, and “what wins” rules.
1. This page for validation commands, host adapter names, and task routing.
1. [`ai_code_review_protocol.md`](ai_code_review_protocol.md)
1. [`new_developer_guide.md`](new_developer_guide.md)
1. [`validation_scripts.md`](validation_scripts.md)
1. [`testing_overview.md`](testing_overview.md)

## Repo Profile

- Flutter 3.41.6 / Dart 3.11.4
- Feature shape: `Presentation -> Domain <- Data`
- State: Cubit/BLoC
- DI: `get_it`
- Routing: `GoRouter`
- Offline-first sync: `lib/shared/sync/`
- Entrypoints:
  - `lib/main_dev.dart`
  - `lib/main_staging.dart`
  - `lib/main_prod.dart`

## Host Adapter Map

| Need | Cursor | Codex |
| --- | --- | --- |
| Fast orientation | `agents-quick-reference` | `flutter-bloc-app-quick-reference` |
| Non-trivial delivery flow | `agents-delivery-workflow` | `flutter-bloc-app-delivery-workflow` |
| Completion / review bar | `agents-completion-gate`, `agents-meta-behavior` | `flutter-bloc-app-delivery-workflow` + [`ai_code_review_protocol.md`](ai_code_review_protocol.md) |
| Delegation / subagents | `agents-subagent-policy` | `flutter-bloc-app-subagent-policy` |
| Cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` only when the reviewer is a different host | `flutter-bloc-app-cross-host-review` or `./tool/request_codex_feedback.sh` only when the reviewer is a different host |
| Approved command routing | `agents-workflow-commands` | repo shell entrypoints directly |

## AI Review Gate

Treat AI-generated code as draft output. Before accepting it, check:

1. draft-first
2. problem-fit
3. simplification
4. security
5. performance
6. edge cases
7. dependency skepticism
8. focused tests or explicit coverage reason

Operational detail lives in [`ai_code_review_protocol.md`](ai_code_review_protocol.md).

## Validation Matrix

| Scope | Command |
| --- | --- |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship | `./bin/checklist` |
| Integration journey | `./bin/integration_tests` |
| SDK/tooling maintenance | `./bin/upgrade_validate_all` |
| Cross-host diff review only when reviewer is different host | `./tool/request_codex_feedback.sh` |

Small/local work still needs scope-matched format, analyze, and targeted tests.
Docs-only changes are not exempt when they touch repo docs: `./bin/checklist`
runs markdown link normalization and doc consistency checks.

## Fastlane (Release Commands)

Prefer `./tool/fastlane.sh` over raw `fastlane` or `bundle exec fastlane`.

- List lanes: `./tool/fastlane.sh lanes`
- Android Play upload (internal): `./tool/fastlane.sh android play_upload_track track:internal`
- Android Play promote: `./tool/fastlane.sh android play_promote_track`
- iOS upload to TestFlight: `./tool/fastlane.sh ios upload_testflight`
- iOS deploy (alternative): `./tool/fastlane.sh ios deploy`

## Workflow Defaults

- For non-trivial work, keep task spec, checkable plan, and verification in
  [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or [`tasks/codex/todo.md`](../tasks/codex/todo.md) (under `tasks/`, usually
  gitignored—create locally).
- Re-plan when the task, evidence, or scope changes materially.
- For subscription/timer ownership and app-wide memory trimming, route through:
  - [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md)
  - [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Prefer repo scripts over ad hoc command chains.

## Task Trackers

- [`tasks/cursor/todo.md`](../tasks/cursor/todo.md): Cursor plan, progress, verification, review
- [`tasks/codex/todo.md`](../tasks/codex/todo.md): Codex plan, progress, verification, review
- [`tasks/lessons.md`](../tasks/lessons.md): user corrections, repeated patterns, prevention rules

## Route by Task

- Cold start: [`AGENTS.md`](../AGENTS.md) -> this file -> feature docs as needed
- Feature implementation: [`clean_architecture.md`](clean_architecture.md), [`architecture_details.md`](architecture_details.md), [`feature_overview.md`](feature_overview.md)
- Lifecycle ownership / memory pressure: [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Offline-first behavior: [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md)
- gstack workflow: [`gstack_integration.md`](gstack_integration.md)

## High-signal Reminders

- In `lib/**/presentation/**`, do not use `Isolate.run(() => ...)`; use `compute`
  with a top-level/static callback (see `./bin/checklist` guard
  `check_no_isolate_run_in_presentation.sh`).
- Search `lib/shared/`, `lib/core/`, and adjacent features before adding code.
- Update DI, routes, l10n, and codegen when touched.
- Keep offline-first queueing and conflict resolution in the data layer unless
  you are intentionally changing architecture.
- For bug fixes, prefer a focused regression guard when practical.
- For non-trivial fixes, challenge the solution for elegance before finalizing.
