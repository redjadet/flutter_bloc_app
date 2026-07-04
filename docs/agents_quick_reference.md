# Agent Quick Reference

Commands + routing. Map [`AGENTS.md`](../AGENTS.md); context
[`agent_project_context.md`](agent_project_context.md); harness
[`agent_knowledge_base.md`](agent_knowledge_base.md); review
[`ai_code_review_protocol.md`](ai_code_review_protocol.md); validation detail
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).
Toolchain: Flutter 3.44.4 / Dart 3.12.2

## Validation Chooser

| Situation | Command |
| --- | --- |
| Cold start map | `bash tool/agent_session_bootstrap.sh` |
| Non-trivial task preflight | [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md) Pre-Flight + `agents-common-pitfalls`; `./bin/agent-maintain preflight` |
| Clean/narrow docs/tooling sanity | `./bin/checklist-fast` (`--explain` for mode debug) |
| Format Dart source | `./bin/format` or `./bin/format --changed` |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Router / `AppRoutes` / auth gates / auth UI | `./bin/router_feature_validate` |
| Integration journey / flow | `./bin/integration_tests` |
| Integration/bootstrap/browser guardrails | `./bin/integration_preflight` (`INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome` for browser-only lane) |
| Runtime error / red screen / active debug bug | DTD `get_runtime_errors` -> fix -> hot reload -> re-read errors; [`agent_kb/devtools_runtime_errors.md`](agent_kb/devtools_runtime_errors.md); shell: `bash tool/check_runtime_errors.sh` |
| Pub API / version-sensitive dependency | MCP package docs loop; [`agent_kb/package_docs_mcp.md`](agent_kb/package_docs_mcp.md); Context7 + `user-dart`; `/package-docs` |
| iOS simulator build / CocoaPods embed | `flutter build ios --simulator --debug` then `tool/check_ios_pod_framework_embed.sh --require-built-app` |
| Apple debug Keychain -34018 / `Recovering corrupted box.` | [`engineering/apple_debug_hive_storage.md`](engineering/apple_debug_hive_storage.md); `bash tool/check_apple_debug_hive_storage.sh`; cold restart simulator |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Existing-code exploration | `./tool/refresh_code_review_graph.sh --status-only` or `--if-needed` |
| Root [`DESIGN.md`](../DESIGN.md) brief | `./tool/check_design_md.sh` |
| UI/theme/Mix/AppStyles | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime source first (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`); `./tool/check_design_md.sh`; `./tool/run_mix_lint.sh`; `./tool/run_file_length_lint.sh` |
| Non-trivial `apps/mobile/lib/features/**` | Fill [`plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md) Tests; see [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md), [`testing_overview.md`](testing_overview.md) |
| New feature contract scaffold | `bash tool/scaffold_feature_contract.sh --name <feature>` preview; add `--apply` only when final |
| Feature folder / use-case / DTO / test routing | [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md), [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md), [`testing/matrix_required_by_change.md`](testing/matrix_required_by_change.md); `bash tool/check_clean_architecture_imports.sh`; skill `agents-feature-delivery` |
| Copy feature / external API / cubit state | [`architecture/reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md) + [`architecture/reference_features.md`](architecture/reference_features.md) semantic grades |
| Cubit/BLoC change | [`bloc_standards.md`](bloc_standards.md), [`review/bloc_checklist.md`](review/bloc_checklist.md); `agents-bloc-standards`; focused `flutter test <paths>` + `./tool/analyze.sh` |
| Agent docs / map drift | `./tool/check_agent_knowledge_base.sh` |
| AI failure-risk register | `bash tool/check_ai_failure_risk_register.sh` |
| Harness max-score claim | [`ai/harness_auto_maintenance.md`](ai/harness_auto_maintenance.md); `./bin/agent-maintain harness-maintain`; `./bin/agent-maintain closeout` |
| Agent-memory / memory-compounding drift | `./tool/check_agent_memory_compounding.sh`; `./tool/agent_memory_auto_maintain.sh --if-changed --verify` |
| Tracker contract | `bash tool/validate_task_trackers.sh` |
| Host-template drift | `./tool/check_agent_asset_drift.sh` |
| Host-template sync | `./tool/sync_agent_assets.sh --dry-run` / `--apply`; after template edits: `./bin/agent-maintain after-host-edit` |
| Agent host maintain | [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md); `./bin/agent-maintain help`; `/agent-maintain` |
| Cursor/Codex host setup | `./bin/agent-maintain setup --apply`; install/trim only on explicit request |
| Global vendor skills | `./bin/agent-maintain install` / `update` / `find QUERY` / `trim`; underlying `tool/install_global_agent_skills.sh` |
| Skill routing (which skill to invoke) | [`ai/skill_routing.md`](ai/skill_routing.md); shim `agents-skill-routing`; `bash tool/find_global_agent_skills.sh QUERY` |
| IDE-open local env preflight | `.vscode/tasks.json` -> `./tool/local_ide_open_preflight.sh` when automatic tasks are allowed |
| Security scans | `./tool/check_tracked_secret_literals.sh`; `./tool/check_ai_generated_code_smells.sh` |
| Cross-host review (explicit only) | `./tool/request_codex_feedback.sh`; plan review: `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |
| Transcript context budgets | `CURSOR_AGENT_TRANSCRIPTS_ROOT=... ./tool/check_transcript_budgets.sh` or `./bin/checklist-fast` |
| Hive shape changes | `dart run tool/generate_hive_schema_fingerprints.dart --check-generated`; `bash tool/check_hive_schema_fingerprints.sh`; strict input drift: `HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh` |
| Store release | Both: `./tool/release_both_stores.sh preflight` then `deploy`; Android: `./tool/release_android_play.sh preflight` / `upload_internal` |

Hive runtime: non-null `HiveRepositoryBase.schema` -> `getBox()` calls
`ensureSchema`; shape changes still need manifest/spec/fingerprint/migrator/tests.
Fastlane: prefer `./tool/fastlane.sh`.

## Automatic Workflow Triggers

| Trigger | Cursor | Codex |
| --- | --- | --- |
| Non-trivial existing-code work | Context ladder; plan + verification in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) | Same, but [`tasks/codex/todo.md`](../tasks/codex/todo.md) |
| Broad/high-risk work | Use [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub); team only if gate passes | Single-agent unless delegation helps and is allowed |
| API/version-sensitive change | MCP package docs + repo-pinned source before model memory | Same |
| External/live state | Use owning tool/MCP/connector/browser; summarize evidence | Same |
| AI-authored change before done | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) + validation routing | Same |
| UI/design/theme/Mix work | Validation chooser UI row + widget/responsive proof | Same |
| Flutter app-code/UI change with active debug run | Hot reload; hot restart if reload cannot apply; report unavailable session | Same |
| Runtime bug / crash with active debug run | Use runtime row | Same |
| Same failure repeats | Add repo capability; do not inflate prompts | Same |
| Prompt tweak repeats | Add evaluator/test/runtime check/fixture/feedback loop; trim prompt prose | Same |
| Agent behavior/host template changed | Source docs -> `tool/agent_host_templates/` -> dry-run -> apply -> dry-run clean -> drift check | Same |
| Implementation / tests / debug / validation | Invoke matching skill via [`ai/skill_routing.md`](ai/skill_routing.md); skill `agents-skill-routing` | Same |

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

Repo root is the Pub workspace + Melos root (`melos:` in root `pubspec.yaml`). The Flutter app lives at `apps/mobile/`. Scoped migration (PR-A–I) is complete on [#437](https://github.com/redjadet/flutter_bloc_app/pull/437); merge to `main` pending.

| Need | Command / path |
| --- | --- |
| Authoritative delivery gate | `./bin/checklist` from **repo root** (unchanged) |
| Pub get (workspace + Flutter codegen) | `bash tool/workspace_pub_get.sh` from repo root |
| Flutter app run | `cd apps/mobile && flutter run -t apps/mobile/lib/main_dev.dart`; root `flutter run -t apps/mobile/lib/main_dev.dart` only when `tool/direnv/bin` wrapper is first in `PATH` |
| Flutter app analyze / test | `./tool/analyze.sh` / `bash tool/test_coverage.sh` (or `cd apps/mobile && flutter test <paths>` for narrow scope) |
| Workspace package analyze | `dart run melos run analyze` from repo root; delegates to `tool/analyze_workspace_packages.sh` so package roots do not scan workspace `.dart_tool` metadata |
| Workspace Dart package tests | `dart run melos run test` from repo root; non-Flutter package tests only. Use `dart run melos run test:flutter` or `cd packages/design_system && flutter test` for Flutter packages |
| Workspace packages | `packages/core`, `packages/utilities`, `packages/design_system`, `packages/networking`, `packages/storage`, `packages/auth`, `packages/feature_flags`, `packages/ai` |
| Firebase backend | `backend/firebase/` (functions, rules, indexes) |
| Package DAG guard | `bash tool/check_package_dependency_dag.sh` (in `./bin/checklist`) |
| Path helper | `source tool/workspace_paths.sh` |
| Melos bootstrap | `dart run melos bootstrap` from repo root (optional after pub get) |
| Shared design tokens/widgets | `package:design_system` (+ `package:design_system/responsive.dart`); app keeps compatibility barrels under old `lib/` paths during migration |

Plan: [`plans/melos_monorepo_migration_plan.md`](plans/melos_monorepo_migration_plan.md).
