# Agent Quick Reference

Commands + routing lookup. Map: [`AGENTS.md`](../AGENTS.md). Knowledge: [`agent_knowledge_base.md`](agent_knowledge_base.md). Project context: [`agent_project_context.md`](agent_project_context.md). Review: [`ai_code_review_protocol.md`](ai_code_review_protocol.md). Validation detail: [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).

Pinned repo toolchain: Flutter 3.41.9 / Dart 3.11.5. CI: [`ci_automation.md`](ci_automation.md).

## Validation Chooser

| Situation | Command |
| --- | --- |
| Clean/narrow docs/tooling sanity | `./bin/checklist-fast` (`--explain` for mode debug) |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Integration journey / flow | `./bin/integration_tests` |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Existing-code exploration | `./tool/refresh_code_review_graph.sh --status-only` or `--if-needed` |
| Large refactor with graph installed | `./tool/refresh_code_review_graph.sh` |
| Cold start map | `bash tool/agent_session_bootstrap.sh` |
| Agent doc compression | `./tool/compress_agent_doc.sh PATH` only on explicit redundant targets; avoid anchor blocks until checks are updated |
| Root [`DESIGN.md`](../DESIGN.md) brief | `./tool/check_design_md.sh` |
| UI/theme/Mix/AppStyles | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime source first (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`); run `./tool/check_design_md.sh` if brief changed |
| Agent/map drift | `./tool/check_agent_knowledge_base.sh` |
| Memory-compounding drift | `./tool/check_agent_memory_compounding.sh` |
| Tracker contract | `bash tool/validate_task_trackers.sh` |
| Host-template drift | `./tool/check_agent_asset_drift.sh` |
| Host-template preview/apply | `./tool/sync_agent_assets.sh --dry-run` / `--apply` |
| Cursor host setup (sync + install/trim/inventory) | `bash tool/setup_cursor_agent_environment.sh` (`--apply`, `--install`) · Cursor command: `/setup-cursor-agent-environment` |
| Global vendor skills (Flutter/Dart/iOS/AI) | install: `bash tool/install_global_agent_skills.sh` · update: `bash tool/update_global_agent_skills.sh` · search: `bash tool/find_global_agent_skills.sh QUERY` · trim dupes: `bash tool/trim_duplicate_agent_skills.sh` (`--apply`, `--mode full`) |
| IDE-open local env preflight | `.vscode/tasks.json` runs `./tool/local_ide_open_preflight.sh` when automatic tasks are allowed |
| Tracked secret literals | `./tool/check_tracked_secret_literals.sh` |
| AI-generated-code smells | `./tool/check_ai_generated_code_smells.sh` |
| Cross-host review (explicit only) | `./tool/request_codex_feedback.sh` |
| Cross-host plan review | `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |
| Transcript context budgets (report-only) | `CURSOR_AGENT_TRANSCRIPTS_ROOT=... ./tool/check_transcript_budgets.sh` (or `./bin/checklist-fast`) |
| Hive fingerprints | `dart run tool/generate_hive_schema_fingerprints.dart --check-generated` + `bash tool/check_hive_schema_fingerprints.sh` |
| Strict Hive input drift | `HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh` |

Hive runtime: non-null `HiveRepositoryBase.schema` -> `getBox()` calls `ensureSchema` (per-box lock); kill switch `--dart-define=HIVE_SCHEMA_MIGRATIONS=false`. Shape changes still need manifest/spec/fingerprint/migrator/tests. Fastlane: prefer `./tool/fastlane.sh`.

## Automatic Workflow Triggers

Repo docs/scripts define behavior; external catalogs don't.

| Trigger | Cursor | Codex |
| --- | --- | --- |
| Non-trivial existing-code work | Context ladder; plan + verification in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) | Same, but [`tasks/codex/todo.md`](../tasks/codex/todo.md) |
| Broad/high-risk work | Run [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub); team only if gate passes | Single-agent unless delegation clearly helps and is allowed |
| API/version-sensitive change | Official/repo-pinned docs before model memory | Same |
| External/live state | Use owning tool/MCP/connector/browser where available; summarize evidence, not transcripts | Same |
| AI-authored change before done | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) + [`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) | Same |
| UI/design/theme/Mix work | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); prefer `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`; app-visible/widget proof where practical | Same |
| Same failure repeats | Add repo capability; do not inflate prompts | Same |
| Agent behavior/host template changed | Source docs -> [`tool/agent_host_templates/`](../tool/agent_host_templates/) -> dry-run -> apply -> dry-run clean -> drift check | Same |
| Cursor host setup / global skills install | `bash tool/setup_cursor_agent_environment.sh` (`--apply`, `--install`) or `/setup-cursor-agent-environment`; skill `agents-global-skills-setup` | `bash tool/sync_agent_assets.sh --apply` + install/trim scripts when using globals |

Docs-before-memory APIs: Flutter, Dart, Firebase, Supabase, GoRouter, and similar version-sensitive APIs need official/repo-grounded source before edits. If unavailable, say so and narrow scope.

Host-copy caveat: `tool/agent_host_templates/` is source. Synced `~/.codex` / `~/.cursor` copies can lag until `./tool/sync_agent_assets.sh --apply`; git cannot update other machines.

Cross-host caveat: `request_codex_feedback` / `run_codex_plan_review` need local Codex, `gh`, auth, network; cold-machine failures are environment blockers.

## Harness Reminders

- Closed-loop: plan once, execute end-to-end, verify, report proof.
- Ask only hard blockers: credentials/tooling, unsafe ambiguity **below 95%**, user-owned decision.
- Outcome: Goal / Context / Boundaries / Verification; exact steps only when path matters.
- Intent/spec/implementation stay separate: intent = why/constraints; spec = eval contract; implementation = repo-derived tactics.
- Context navigation ladder: map docs -> durable memory -> code-review-graph -> targeted raw files.
- Context audit before feature/refactor: related code/tests/docs, known bugs, workarounds, deprecated patterns, unusual helpers; record only real landmines.
- Proof-first: repo scripts/tests/runtime/MCP own truth; prompts alone not proof; empty tool output not proof.
- Scope discipline: smallest reversible diff; run narrowest honest validation lane.
- Reusable agent conclusion => durable repo memory; don’t leave chat-only.
- Repeated failure => add repo capability (doc/test/fixture/script/route proof/log helper).
- Behavior changes start in source docs, then host templates; don’t fork unless host capability differs.
- Agent/docs change => semantic lint stale plans, duplicate rules, source/template contradictions.
- UI/design: [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime source first; build real workflow first; verify states, responsive stability, no overlap.

## Multi-Agent Hub

Cursor records `Benefit: team - <reason>` or `Benefit: single - <reason>` in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md); trivial may use `trivial - gate skipped`. Default single; team when >=2 indicators. Team artifacts under `tasks/cursor/team/<run-id>/`. Doctrine: [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub).

## Host Adapters

| Need | Cursor | Codex |
| --- | --- | --- |
| Orientation + commands | `agents-quick-reference` | `flutter-bloc-app-quick-reference` |
| Non-trivial delivery | `agents-delivery-workflow` | `flutter-bloc-app-delivery-workflow` |
| Plan/delegation reminders | `agents-meta-behavior` | — |
| Cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` | `./tool/request_codex_feedback.sh` |

Repo-managed Cursor commands: `/local-agents-quick-reference`, `/upgrade-validate-all`, `/commit-push-pr`, `/codex-feedback`. **`/commit-push-pr` start:** `bash tool/commit_push_pr_rebase_on_main.sh` (then plan/execute/commit/push/PR). To land: `bash tool/commit_push_pr_watch_merge_cleanup.sh`; merge-only `bash tool/commit_push_pr_merge_and_cleanup.sh`; merged elsewhere `python3 tool/commit_push_pr_deploy.py post-merge` ([`validation_scripts.md`](validation_scripts.md) § Git).

## Read By Task

- Product/setup: [`../README.md`](../README.md), [`new_developer_guide.md`](new_developer_guide.md), [`tech_stack.md`](tech_stack.md)
- Agent harness: [`agent_knowledge_base.md`](agent_knowledge_base.md), [`agent_project_context.md`](agent_project_context.md), [`ai_code_review_protocol.md`](ai_code_review_protocol.md)
- Agent setup: [`agent_environment_setup.md`](agent_environment_setup.md)
- Feature work: [`clean_architecture.md`](clean_architecture.md), [`architecture_details.md`](architecture_details.md), [`feature_overview.md`](feature_overview.md)
- UI/design: [`../DESIGN.md`](../DESIGN.md), [`design_system.md`](design_system.md), [`mix_design_system_plan.md`](mix_design_system_plan.md)
- Validation: [`validation_scripts.md`](validation_scripts.md), [`testing_overview.md`](testing_overview.md)
- Lifecycle: [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- Offline-first: [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md), [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md)
- Supabase/chat proxy: [`../supabase/README.md`](../supabase/README.md)
- gstack: [`gstack_integration.md`](gstack_integration.md)
- Staff demo: [`staff_app_demo_walkthrough.md`](staff_app_demo_walkthrough.md)
