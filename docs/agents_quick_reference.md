# Agent Quick Reference

Commands + routing lookup. Convenience only. Map: [`AGENTS.md`](../AGENTS.md).
Knowledge: [`agent_knowledge_base.md`](agent_knowledge_base.md). Review:
[`ai_code_review_protocol.md`](ai_code_review_protocol.md).
If [`AGENTS.md`](../AGENTS.md) unavailable, combine this with
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).

Pinned repo toolchain: Flutter 3.41.7 / Dart 3.11.5.

## Validation Chooser

Decision guide: [`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)

| Situation | Command |
| --- | --- |
| Clean-tree local sanity or narrow local docs/tooling sweep | `./bin/checklist-fast` |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Integration journey / flow verification | `./bin/integration_tests` |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Large refactor with code-review-graph installed | `./tool/refresh_code_review_graph.sh` |
| Cold start (print map + validation pointers) | `bash tool/agent_session_bootstrap.sh` |
| New shared agent-facing markdown doc | `./tool/compress_agent_doc.sh PATH`; rerun with `--overwrite-backups` to replace backup |
| Cursor shared-doc compression | `caveman-compress` skill or `./tool/compress_agent_doc.sh PATH` |
| Agent knowledge-base/map drift | `./tool/check_agent_knowledge_base.sh` |
| Tracker contract check | `bash tool/validate_task_trackers.sh` |
| Repo-managed host-template drift check | `./tool/check_agent_asset_drift.sh` |
| Host-template preview sync | `./tool/sync_agent_assets.sh --dry-run` |
| Scan for AI-generated-code smells (high-signal helper) | `./tool/check_ai_generated_code_smells.sh` |
| Cross-host diff review, explicit request only | `./tool/request_codex_feedback.sh` |
| Cross-host **plan** review (markdown plan + Codex) | `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |

Fastlane: prefer `./tool/fastlane.sh` over raw `fastlane`.

## Flutter Test Reminder

Widget tests: set screen size/pixel ratio with `WidgetTester.view`
(`physicalSize`, `devicePixelRatio`, reset methods). Avoid deprecated
`tester.binding.window` / `TestWidgetsFlutterBinding.window`.

## Async List Builder Reminder

Builder indexing Cubit/BLoC list: snapshot at build start, derive `itemCount`
from snapshot, guard stale indexes. Header-row lists (`items.length + 1` with
`items[index - 1]`) are `RangeError`-prone during async refresh.

## Host Trackers

Cursor: [`tasks/cursor/todo.md`](../tasks/cursor/todo.md). Codex:
[`tasks/codex/todo.md`](../tasks/codex/todo.md).

## Harness Reminders

- Classify complexity/risk/scope/uncertainty before scaling plan/validation/delegation.
- Vague ask -> assumptions + success criteria + smallest verifiable slice before edits.
- Bug fix -> reproduce/reason to root cause before code change.
- Repeated failure => add repo capability: doc/test/fixture/script/route proof/log helper/validation check.
- Non-trivial: compare approaches, pick lowest-regret, stop when extra work stops reducing real risk.
- UI/app work: prefer app-visible proof over logs-only claims.
- Enforce invariants mechanically; keep host assets thin and synced from `tool/agent_host_templates/`.
- Behavior changes start in source docs, then host templates; don’t fork unless host capability differs.

## Host Adapters

| Need | Cursor | Codex |
| --- | --- | --- |
| Fast orientation + command entrypoints | `agents-quick-reference` | `flutter-bloc-app-quick-reference` |
| Non-trivial delivery through completion | `agents-delivery-workflow` | `flutter-bloc-app-delivery-workflow` |
| Plan depth / delegation reminders | `agents-meta-behavior` | — |
| Cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` with a different host | `./tool/request_codex_feedback.sh` with a different host |

Repo-managed Cursor slash prompts (synced by `./tool/sync_agent_assets.sh`):
`/local-agents-quick-reference`, `/upgrade-validate-all`, `/commit-push-pr`,
`/codex-feedback`.

Cold-start fit:

- Codex: bootstrap -> [`AGENTS.md`](../AGENTS.md), knowledge base, review protocol, quick reference, README
- Cursor: global rule + skills point back to same canon; don’t duplicate policy
- Cursor compression: `caveman-compress` or `./tool/compress_agent_doc.sh`, not Anthropic auth.

## Read By Task

- Product/setup context:
  [`README.md`](../README.md),
  [`new_developer_guide.md`](new_developer_guide.md)
- Agent harness / knowledge base:
  [`agent_knowledge_base.md`](agent_knowledge_base.md),
  [`ai_code_review_protocol.md`](ai_code_review_protocol.md)
- Feature work:
  [`clean_architecture.md`](clean_architecture.md),
  [`architecture_details.md`](architecture_details.md),
  [`feature_overview.md`](feature_overview.md)
- Validation detail:
  [`validation_scripts.md`](validation_scripts.md),
  [`testing_overview.md`](testing_overview.md)
- Lifecycle:
  [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md),
  [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Offline-first:
  [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md),
  [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md)
- Supabase Edge / chat proxy:
  [`../supabase/README.md`](../supabase/README.md)
- gstack:
  [`gstack_integration.md`](gstack_integration.md)
- Staff app demo:
  [`staff_app_demo_walkthrough.md`](staff_app_demo_walkthrough.md)
