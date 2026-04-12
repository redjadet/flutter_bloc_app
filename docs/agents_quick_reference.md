# Agent Quick Reference

Compact command and routing cheat sheet for repo-aware AI hosts.
[`AGENTS.md`](../AGENTS.md) is authoritative. This page is convenience only and
must stay thinner than the canon.

Fallback only: if [`AGENTS.md`](../AGENTS.md) is unavailable in the current
host context, combine this page with
[`ai_code_review_protocol.md`](ai_code_review_protocol.md).

Pinned repo toolchain: Flutter 3.41.6 / Dart 3.11.4.

## Start Here

1. Read [`AGENTS.md`](../AGENTS.md).
2. Read [`ai_code_review_protocol.md`](ai_code_review_protocol.md).
3. Use this page for command lookup, adapter names, and doc routing.

## Validation Routes

Decision guide:
[`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)

| Situation | Command |
| --- | --- |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship / explicit full sweep | `./bin/checklist` |
| Integration journey / flow verification | `./bin/integration_tests` |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Repo-managed host-template drift check | `./tool/check_agent_asset_drift.sh` |
| Host-template preview sync | `./tool/sync_agent_assets.sh --dry-run` |
| Cross-host diff review, explicit request only | `./tool/request_codex_feedback.sh` |
| Cross-host **plan** review (markdown plan + Codex) | `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |

Fastlane note: prefer `./tool/fastlane.sh` over raw `fastlane`.

## Common Flow

1. Read the canon.
2. Understand the business goal and intended user outcome before narrowing to
   implementation.
3. For non-trivial work, write plan + verification notes in the active host
   tracker.
4. Reuse existing repo seams before adding abstractions.
5. Apply the AI review gate.
6. Run the smallest matching validation command.
7. Prove the result with scope-matched evidence.

## Work Shapes

Commands for each lane live in **Validation Routes** above and in
[`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).

| Work shape | Default action |
| --- | --- |
| Small/local change | Reuse existing seams, run targeted validation, prove the changed behavior. |
| Shared architecture / sync / routing / reliability | Treat as non-trivial, document tradeoffs, bias `./bin/checklist` when the blast radius is broad. |
| Docs-only repo guidance | Validate touched docs and links; if host templates changed, run drift and dry-run sync (see **Validation Routes**). |
| Production failure / hotfix | Narrow proof first, then widen gates to match blast radius (see **Production-Failure Path** in validation routing). |
| Explicit second opinion | Use a different host via `./tool/request_codex_feedback.sh`; do not self-delegate. |

## Host Trackers

- Cursor: [`tasks/cursor/todo.md`](../tasks/cursor/todo.md)
- Codex: [`tasks/codex/todo.md`](../tasks/codex/todo.md)

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

## Read By Task

- Product/setup context:
  [`README.md`](../README.md),
  [`new_developer_guide.md`](new_developer_guide.md)
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

## Reminders

- Repo scripts and repo docs beat host-local wrappers.
- Host adapters are accelerators only; they do not replace repo policy.
- Goals, scale, edge cases, judgment, and ownership live in
  [`AGENTS.md`](../AGENTS.md) (**Shared Operating Model**); keep this page for
  commands and routing.
- Docs-only or host-template edits: validate docs, links, and drift paths (see
  **Validation Routes** and validation routing doc).
- Codex: durable plan in the tracker; short, decision-oriented commentary.
- Cursor: copy-paste-ready repo commands over long canon repeats.
