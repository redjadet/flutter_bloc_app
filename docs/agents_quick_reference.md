# Agent Quick Reference

Commands and routing. Run tool router first; read only matching row. Specialist
operations: [`agent_kb/specialist_tool_routes.md`](agent_kb/specialist_tool_routes.md).
Map: [`AGENTS.md`](../AGENTS.md). Validation detail:
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).

## Validation Chooser

| Situation | Command |
| --- | --- |
| Cold start map | `bash tool/agent_session_bootstrap.sh --intent "<task goal>"` (prints automatic tool routes) |
| Non-trivial task preflight | [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md) Pre-Flight + `agents-common-pitfalls`; `./bin/agent-maintain preflight --intent "<task goal>"` |
| Tool choice / scope changed | `./bin/agent-maintain tools --intent "<goal>" --paths <files>`; [`agent_kb/tool_orchestration.md`](agent_kb/tool_orchestration.md) |
| Git branch / PR / merge / worktree | [`git_and_branching_strategy.md`](git_and_branching_strategy.md); inspect `git status --short --branch` and upstream state before action |
| Watch PR CI → merge when green | Skill `gh-watch-merge-pr` / `/watch-merge-pr`; `bash tool/commit_push_pr_watch_merge_cleanup.sh <pr>` |
| Clean/narrow docs/tooling sanity | `./bin/checklist-fast` (`--explain` for mode debug) |
| Format Dart source | `./bin/format` or `./bin/format --changed` (**required before finish** when any `.dart` changed) |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Router / `AppRoutes` / auth gates / auth UI | `./bin/router_feature_validate` |
| Integration journey / flow | `./bin/integration_tests` |
| Integration/bootstrap/browser guardrails | `./bin/integration_preflight` (`INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome` for browser-only lane) |
| Runtime error / red screen / active debug bug | DTD `get_runtime_errors` -> fix -> hot reload -> re-read errors; [`agent_kb/devtools_runtime_errors.md`](agent_kb/devtools_runtime_errors.md); shell: `bash tool/check_runtime_errors.sh` |
| Pub API / version-sensitive dependency | MCP package docs loop; [`agent_kb/package_docs_mcp.md`](agent_kb/package_docs_mcp.md); Dart MCP + current official docs; `/package-docs` |
| UI/theme/Mix/AppStyles | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime source first (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`); `./tool/check_design_md.sh`; `./tool/run_mix_lint.sh`; `./tool/run_file_length_lint.sh` |
| Non-trivial `apps/mobile/lib/features/**` | Fill [`plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md) Tests; see [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md), [`testing_overview.md`](testing_overview.md) |
| New feature contract scaffold | `bash tool/scaffold_feature_contract.sh --name <feature>` preview; add `--apply` only when final |
| Feature folder / use-case / DTO / test routing | [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md), [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md), [`testing/matrix_required_by_change.md`](testing/matrix_required_by_change.md); `bash tool/check_clean_architecture_imports.sh`; skill `agents-feature-delivery` |
| Copy feature / external API / cubit state | [`architecture/reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md) + [`architecture/reference_features.md`](architecture/reference_features.md) semantic grades |
| Cubit/BLoC change | [`bloc_standards.md`](bloc_standards.md), [`review/bloc_checklist.md`](review/bloc_checklist.md); `agents-bloc-standards`; focused `flutter test <paths>` + `./tool/analyze.sh` |
| Agent docs / map drift | `./tool/check_agent_knowledge_base.sh` |
| AI failure-risk register | `bash tool/check_ai_failure_risk_register.sh` |
| Harness max-score claim | [`ai/harness_auto_maintenance.md`](ai/harness_auto_maintenance.md); `./bin/agent-maintain harness-maintain`; `./bin/agent-maintain closeout` |
| Engineering max-score claim | [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md); `bash tool/check_engineering_quality_scorecard_gate.sh`; `bash tool/update_engineering_quality_badge.sh --check`; `./bin/agent-maintain closeout` |
| Agent-memory / memory-compounding drift | `./tool/check_agent_memory_compounding.sh`; `./tool/agent_memory_auto_maintain.sh --if-changed --verify` |
| Tracker contract | `bash tool/validate_task_trackers.sh` |
| Host-template drift | `./tool/check_agent_asset_drift.sh` |
| Host-template sync | `./tool/sync_agent_assets.sh --dry-run` / `--apply`; after template edits: `./bin/agent-maintain after-host-edit` |
| Agent host maintain | [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md); `./bin/agent-maintain help`; `/agent-maintain` |
| Cursor/Codex host setup | `./bin/agent-maintain setup --apply`; install/trim only on explicit request |
| Global vendor skills | `./bin/agent-maintain install` / `update` / `find QUERY` / `trim`; underlying `tool/install_global_agent_skills.sh` |
| Skill routing (which skill to invoke) | [`ai/skill_routing.md`](ai/skill_routing.md); shim `agents-skill-routing`; `./bin/agent-maintain find QUERY` |
| Security scans | `./tool/check_tracked_secret_literals.sh`; `./tool/check_ai_generated_code_smells.sh`; pinning policy [`docs/security/certificate_pinning.md`](security/certificate_pinning.md) |

## Automatic Workflow Triggers

| Trigger | Action |
| --- | --- |
| Task start / scope change | `preflight` / tool router, then task-matched owner docs |
| Non-trivial existing-code work | Context ladder; plan + proof in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or [`tasks/codex/todo.md`](../tasks/codex/todo.md) |
| Broad / high-risk work | [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub); delegate only when allowed |
| API, external state, Git, UI, runtime | Matching chooser row; inspect live state; require authorization for remote/destructive action |
| AI-authored change before done | [`review/code_review_playbook.md`](review/code_review_playbook.md) + [`ai_code_review_protocol.md`](ai_code_review_protocol.md) + routed validation |
| Repeated failure / prompt tweak | Add evaluator, test, fixture, or script; trim prompt prose |
| Agent behavior / template changed | Source docs → templates → `after-host-edit` → drift check |
| Implementation / test / debug / validation | Matching skill from [`ai/skill_routing.md`](ai/skill_routing.md) |

## Harness

Doctrine: [`agent_knowledge_base.md`](agent_knowledge_base.md). **Context navigation ladder:**
[`ai/context_loading.md`](ai/context_loading.md). **Skill routing:**
[`ai/skill_routing.md`](ai/skill_routing.md). **Multi-Agent Hub:**
[`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub).

Mechanical anchors (do not drop): below 95%; execute end-to-end, verify, report proof; Behavior changes start in source docs; Reusable agent conclusion; semantic lint; Benefit: team; Benefit: single; `tasks/cursor/team/<run-id>/`.

## Host Adapters

| Need | Cursor | Codex |
| --- | --- | --- |
| Orientation + commands | `agents-quick-reference` | `agents-quick-reference` |
| Skill discovery / routing | `agents-skill-routing` | `agents-skill-routing` |
| Cubit/BLoC standards | `agents-bloc-standards` | `agents-bloc-standards` |
| Feature delivery contract | `agents-feature-delivery` | `agents-feature-delivery` |
| Non-trivial delivery | `agents-delivery-workflow` | `agents-delivery-workflow` |
| Plan/delegation reminders | `agents-meta-behavior` | - |
| Explicit cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` | `./tool/request_codex_feedback.sh` only when user asks |

Shared host-neutral skill source:
[`../tool/agent_host_templates/shared/skills/`](../tool/agent_host_templates/shared/skills/).
Repo-managed Cursor commands: `/local-agents-quick-reference`,
`/upgrade-validate-all`, `/commit-push-pr`, `/codex-feedback`.

## Task Doc Routing

Full map: [`AGENTS.md`](../AGENTS.md) § Map and [`README.md`](README.md). AI engineering index: [`PLAN.md`](../PLAN.md).

## Melos workspace

Repo root is Pub/Melos root; app lives in `apps/mobile/`. Run repo commands from
root; use `dart run melos ...` (global `melos` not needed). Workspace operation:
[`agent_kb/specialist_tool_routes.md`](agent_kb/specialist_tool_routes.md).

| Need | Command / path |
| --- | --- |
| Delivery | `./bin/checklist` |
| App source / run | `apps/mobile/**`; `cd apps/mobile && flutter run -t lib/main_dev.dart` |
| Shared UI | `package:design_system` / `package:design_system/responsive.dart` |
| Backend | `backend/firebase/` |
| Package DAG | `bash tool/check_package_dependency_dag.sh` (included in checklist) |

Plan: [`plans/melos_monorepo_migration_plan.md`](plans/melos_monorepo_migration_plan.md).
