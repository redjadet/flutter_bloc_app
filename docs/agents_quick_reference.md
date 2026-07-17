# Agent Quick Reference

Commands and routing. Run tool router first; load only matching row. Map:
[`AGENTS.md`](../AGENTS.md). Detail: [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md), [`agent_kb/specialist_tool_routes.md`](agent_kb/specialist_tool_routes.md).

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
| Agent safety-contract drift | `bash tool/check_agent_safety_contracts.sh` |
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
| Start / scope change | Preflight/tool router; task-matched owner docs; non-trivial plan + proof in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or [`tasks/codex/todo.md`](../tasks/codex/todo.md) |
| Broad / high-risk work | [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub); delegate only when allowed |
| API, external state, Git, UI, runtime | Matching chooser row; inspect live state; authorize remote/destructive action |
| AI-authored change | [`review/code_review_playbook.md`](review/code_review_playbook.md) + [`ai_code_review_protocol.md`](ai_code_review_protocol.md) + routed validation |
| Repeated failure / agent-template change | Add evaluator/test/fixture/script; trim prose; source docs → templates → `after-host-edit` → drift check |

## Harness

Doctrine: [`agent_knowledge_base.md`](agent_knowledge_base.md). [Context navigation ladder](ai/context_loading.md); [Skill routing](ai/skill_routing.md); [Multi-Agent Hub](agent_knowledge_base.md#multi-agent-hub).

Mechanical anchors (do not drop): below 95%; execute end-to-end, verify, report proof; Behavior changes start in source docs; Reusable agent conclusion; semantic lint; Benefit: team; Benefit: single; `tasks/cursor/team/<run-id>/`.

## Host adapters

Both: `agents-quick-reference`, `agents-skill-routing`, `agents-bloc-standards`,
`agents-feature-delivery`, `agents-delivery-workflow`. Cursor-only planning:
`agents-meta-behavior`. Shared source:
[`../tool/agent_host_templates/shared/skills/`](../tool/agent_host_templates/shared/skills/). Cross-host review only when user asks: `/codex-feedback` or `./tool/request_codex_feedback.sh`.

## Melos workspace

Root is Pub/Melos root; app: `apps/mobile/`; shared UI: `package:design_system`;
backend: `backend/firebase/`. Use `dart run melos ...`; app run:
`cd apps/mobile && flutter run -t lib/main_dev.dart`. Package DAG check is in
`./bin/checklist`; workspace operations: [`agent_kb/specialist_tool_routes.md`](agent_kb/specialist_tool_routes.md).
