# Agent Quick Reference

Compact command and routing cheat sheet for repo-aware AI hosts.
[`AGENTS.md`](../AGENTS.md) is authoritative. This page is convenience only and
must stay thinner than canon.

Fallback only: if [`AGENTS.md`](../AGENTS.md) is unavailable in current
host context, combine this page with
[`ai_code_review_protocol.md`](ai_code_review_protocol.md) and
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
for command routing (this page is lookup only, not policy).

Pinned repo toolchain: Flutter 3.41.7 / Dart 3.11.5.

## 30-Second Path

1. Read [`AGENTS.md`](../AGENTS.md).
2. Read [`ai_code_review_protocol.md`](ai_code_review_protocol.md).
3. If suitable Superpowers workflow skills are installed, use them early as the
   default process layer, but keep [`AGENTS.md`](../AGENTS.md) and direct user
   instructions authoritative.
4. If local `code-review-graph` is installed and the task is non-trivial
   existing-code work, use it first to narrow files and symbols before broad
   repo scans.
5. For routine low-risk communication, default to caveman-lite brevity when it
   reduces tokens without reducing clarity.
6. Before reporting back, self-verify the final response against the user
   request, changed files, validation evidence, blockers, and residual risk.
7. Use this page for command lookup, adapter names, and doc routing only.
8. For non-trivial work, keep active plan in host tracker.

## Validation Chooser

Decision guide:
[`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)

| Situation | Command |
| --- | --- |
| Clean-tree local sanity or narrow local docs/tooling sweep | `./bin/checklist-fast` |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Integration journey / flow verification | `./bin/integration_tests` |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Large refactor with code-review-graph installed | `./tool/refresh_code_review_graph.sh` |
| New shared agent-facing markdown doc | `./tool/compress_agent_doc.sh PATH` |
| Repo-managed host-template drift check | `./tool/check_agent_asset_drift.sh` |
| Host-template preview sync | `./tool/sync_agent_assets.sh --dry-run` |
| Cross-host diff review, explicit request only | `./tool/request_codex_feedback.sh` |
| Cross-host **plan** review (markdown plan + Codex) | `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |

Fastlane note: prefer `./tool/fastlane.sh` over raw `fastlane`.

## Default Loop

1. Read canon.
2. Use suitable Superpowers workflow skills early when they fit the task;
   repo canon and user instructions still win.
3. Understand business goal before narrowing to local code path.
4. For non-trivial existing-code work, use local `code-review-graph` first
   when available to narrow reads and reduce token use.
5. Use caveman-lite communication by default for routine updates/summaries
   unless the message needs fuller precision.
6. For non-trivial work, record plan + verification in active host tracker.
7. Reuse existing repo seams before adding abstractions.
8. Apply AI review gate.
9. Run smallest matching validation command.
10. Self-verify the final output against request, diff, and validation evidence.
11. Prove result with scope-matched evidence.

## Work Shapes

Commands for each lane live in **Validation Chooser** above and in
[`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).

| Work shape | Default action |
| --- | --- |
| Small/local change | Reuse existing seams, run targeted validation, prove the changed behavior. |
| Non-trivial existing-code task with local Codex graph installed | Use graph queries first to find likely files/symbols/impact before broad `rg` or many-file reads. |
| Shared architecture / sync / routing / reliability | Treat as non-trivial, document tradeoffs, bias `./tool/delivery_checklist.sh` / `./bin/checklist` when the blast radius is broad. |
| Broad multi-file refactor with local Codex graph installed | After implementation, refresh the graph best-effort with `./tool/refresh_code_review_graph.sh`; do not block on missing local tooling. |
| Docs-only repo guidance | Validate touched docs and links; if host templates changed, run drift and dry-run sync (see **Validation Routes**); self-check final wording against repo canon before reporting. |
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

Cold-start fit:

- Codex: bootstrap -> [`AGENTS.md`](../AGENTS.md), review protocol, quick reference, README
- Cursor: global rule + skills should point back to same canon instead of
  duplicating policy

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
- Host adapters are accelerators only; they don't replace repo policy.
- When installed and suitable, Superpowers workflow skills are the default
  process helpers for how to work, but they remain subordinate to repo canon
  and explicit user instructions.
- `code-review-graph` is the preferred low-token exploration path for Codex on
  non-trivial existing-code tasks when installed. Skip it for trivial edits or
  when exact file targets are already known.
- Installation/build only makes the graph available through MCP. The token win
  happens when the agent actually begins non-trivial repo exploration with
  graph queries instead of broad file reads.
- Default to caveman-lite brevity for routine agent communication. Switch back
  to normal concise prose for warnings, destructive actions, security/privacy
  notes, ambiguous multi-step instructions, external messages, or any text
  where extra compression could be misread.
- Self-verification is mandatory before final user reports. Check the response
  against the request, changed files, validation output, blockers, and residual
  risk; do not use cross-host review helpers as self-review.
- Goals, scale, edge cases, judgment, and ownership live in
  [`AGENTS.md`](../AGENTS.md) (**Shared Operating Model**); keep this page for
  commands and routing.
- Docs-only or host-template edits: validate docs, links, and drift paths (see
  **Validation Routes** and validation routing doc).
- `./bin/checklist-fast` is local-only and conservative: use it for clean-tree sanity or narrow docs/tooling change sets, never as a substitute for the full delivery gate on app/runtime work.
- New shared AI-agent markdown docs, including repo-managed host-template
  markdown under `tool/agent_host_templates/`: compress final tracked file with
  `./tool/compress_agent_doc.sh PATH`, keep `.original.md` human backup.
  `README*.md` files are excluded.
- Codex: durable plan in tracker; short, decision-oriented commentary.
- Cursor: copy-paste-ready repo commands over long canon repeats.
