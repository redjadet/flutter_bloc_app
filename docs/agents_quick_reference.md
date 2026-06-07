# Agent Quick Reference

Commands + routing. Map [`AGENTS.md`](../AGENTS.md); harness [`agent_knowledge_base.md`](agent_knowledge_base.md); context [`agent_project_context.md`](agent_project_context.md); review [`ai_code_review_protocol.md`](ai_code_review_protocol.md); validation [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md). Toolchain: Flutter 3.44.1 / Dart 3.12.1 · CI [`ci_automation.md`](ci_automation.md).

## Validation Chooser

| Situation | Command |
| --- | --- |
| Clean/narrow docs/tooling sanity | `./bin/checklist-fast` (`--explain` for mode debug) |
| Format Dart source | `./bin/format` or `./bin/format --changed` (respects `.gitignore`; avoids generated `build/` and `.dart_tool/`) |
| Router / `AppRoutes` / gates / auth UI | `./bin/router_feature_validate` |
| Broad / pre-ship / explicit full sweep | `./tool/delivery_checklist.sh` / `./bin/checklist` |
| Checklist script → theme mapping | `CHECKLIST_EXPLAIN_THEMES=1 ./bin/checklist` — see [`validation_scripts/catalog.md`](validation_scripts/catalog.md#quality-theme-gates-checklist-mvp-may-2026) |
| Integration journey / flow | `./bin/integration_tests` |
| Early integration/bootstrap guardrails | `./bin/integration_preflight` |
| iOS simulator build / CocoaPods embed | `flutter build ios --simulator --debug` then `tool/check_ios_pod_framework_embed.sh --require-built-app` |
| iOS/macOS debug Keychain -34018 / `Recovering corrupted box.` | [`engineering/apple_debug_hive_storage.md`](engineering/apple_debug_hive_storage.md) · `bash tool/check_apple_debug_hive_storage.sh` · cold restart on simulator |
| Browser integration (Chrome/web; not `integration_test/` on device) | `./bin/integration_preflight` with `INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome` (default) |
| SDK / tooling maintenance | `./bin/upgrade_validate_all` |
| Existing-code exploration | `./tool/refresh_code_review_graph.sh --status-only` or `--if-needed` |
| Large refactor with graph installed | `./tool/refresh_code_review_graph.sh` |
| Non-trivial task preflight | [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md) Pre-Flight + `agents-common-pitfalls`; `./bin/agent-maintain preflight` |
| Cold start map | `bash tool/agent_session_bootstrap.sh` |
| Agent doc compression | `./tool/compress_agent_doc.sh PATH` only on explicit redundant targets; avoid anchor blocks until checks are updated |
| Root [`DESIGN.md`](../DESIGN.md) brief | `./tool/check_design_md.sh` |
| UI/theme/Mix/AppStyles | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime source first (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`); run `./tool/check_design_md.sh` if brief changed |
| Non-trivial `lib/features/**` | Fill [`plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md) **Tests** before broad impl; widget patterns [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md); policy [`testing_overview.md`](testing_overview.md) § Feature-defined testing |
| New feature contract scaffold | `bash tool/scaffold_feature_contract.sh --name <feature>` previews folders + feature brief; add `--apply` only when the name is final |
| Feature folder/use-case/DTO/test routing | [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md) + [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md) + [`testing/matrix_required_by_change.md`](testing/matrix_required_by_change.md); `bash tool/check_clean_architecture_imports.sh`; skill `agents-feature-delivery` |
| Cubit/BLoC change | [`bloc_standards.md`](bloc_standards.md) + [`review/bloc_checklist.md`](review/bloc_checklist.md); skill `agents-bloc-standards`; focused `flutter test <paths>` + `./tool/analyze.sh` |
| Agent/map drift | `./tool/check_agent_knowledge_base.sh` |
| AI failure-risk register | `bash tool/check_ai_failure_risk_register.sh` |
| Memory-compounding drift | `./tool/check_agent_memory_compounding.sh` |
| Agent-memory auto upkeep (local) | `./tool/agent_memory_auto_maintain.sh` (`--if-changed`, `--verify`, `--codex-memory-health`; wired into KB check + sync `--apply`; Codex memory health is report-only) |
| Tracker contract | `bash tool/validate_task_trackers.sh` |
| Host-template drift | `./tool/check_agent_asset_drift.sh` |
| Host-template preview/apply | `./tool/sync_agent_assets.sh --dry-run` / `--apply` |
| Agent host maintain (sync, globals, workflows) | When-table: [`host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) · `./bin/agent-maintain help` · `/agent-maintain` |
| Harness max-score claim | [`ai/harness_auto_maintenance.md`](ai/harness_auto_maintenance.md) · `./bin/agent-maintain harness-maintain` updates README badge · `closeout` when scoped |
| Cursor host setup (sync + install/trim/inventory) | `./bin/agent-maintain setup` (`--apply`, `--install`) or `bash tool/setup_cursor_agent_environment.sh` · `/setup-cursor-agent-environment` |
| Global vendor skills (Flutter/Dart/iOS/AI) | `./bin/agent-maintain install` · `update` · `find QUERY` · `trim` (`--apply`, `--mode full`) or underlying `tool/install_global_agent_skills.sh` etc. |
| Skill routing (which skill to invoke) | [`ai/skill_routing.md`](ai/skill_routing.md) · shim `agents-skill-routing` · `bash tool/find_global_agent_skills.sh QUERY` |
| IDE-open local env preflight | `.vscode/tasks.json` runs `./tool/local_ide_open_preflight.sh` when automatic tasks are allowed |
| Tracked secret literals | `./tool/check_tracked_secret_literals.sh` |
| AI-generated-code smells | `./tool/check_ai_generated_code_smells.sh` |
| Cross-host review (explicit only) | `./tool/request_codex_feedback.sh` |
| Cross-host plan review | `./tool/run_codex_plan_review.sh PATH/TO/plan.md` |
| Transcript context budgets (report-only) | `CURSOR_AGENT_TRANSCRIPTS_ROOT=... ./tool/check_transcript_budgets.sh` (or `./bin/checklist-fast`) |
| Hive fingerprints | `dart run tool/generate_hive_schema_fingerprints.dart --check-generated` + `bash tool/check_hive_schema_fingerprints.sh` |
| Strict Hive input drift | `HIVE_SCHEMA_ENFORCE_INPUTS=true bash tool/check_hive_schema_fingerprints.sh` |
| Store release (both platforms) | `./tool/release_both_stores.sh preflight` then `deploy` after checklist/integration gates ([`deployment.md`](deployment.md)) |
| Store release (Android only) | `./tool/release_android_play.sh preflight` / `upload_internal` ([`android_play_store_release_sop.md`](android_play_store_release_sop.md)) |

Hive runtime: non-null `HiveRepositoryBase.schema` -> `getBox()` calls `ensureSchema` (per-box lock); kill switch `--dart-define=HIVE_SCHEMA_MIGRATIONS=false`. Shape changes still need manifest/spec/fingerprint/migrator/tests. Fastlane: prefer `./tool/fastlane.sh`; both stores `./tool/release_both_stores.sh deploy` (see [`deployment.md`](deployment.md)).

## Automatic Workflow Triggers

Repo docs/scripts define behavior; external catalogs don't.

| Trigger | Cursor | Codex |
| --- | --- | --- |
| Non-trivial existing-code work | Context ladder; plan + verification in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) | Same, but [`tasks/codex/todo.md`](../tasks/codex/todo.md) |
| Broad/high-risk work | Run [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub); team only if gate passes | Single-agent unless delegation clearly helps and is allowed |
| API/version-sensitive change | Official/repo-pinned docs before model memory | Same |
| External/live state | Use owning tool/MCP/connector/browser where available; summarize evidence, not transcripts | Same |
| AI-authored change before done | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) + [`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) | Same |
| UI/design/theme/Mix work | Validation chooser **UI/theme/Mix** row + widget/responsive proof | Same |
| Flutter app-code/UI change with active debug run | Trigger hot reload; hot restart if reload cannot apply; report unavailable session | Same |
| Same failure repeats | Add repo capability; do not inflate prompts | Same |
| Agent behavior/host template changed | Source docs -> [`tool/agent_host_templates/`](../tool/agent_host_templates/) -> dry-run -> apply -> dry-run clean -> drift check | Same |
| Cursor host setup / global skills install | `./bin/agent-maintain` (`routine`, `setup`, `host-full`) or `/agent-maintain` / `/setup-cursor-agent-environment`; skill `agents-global-skills-setup` | Host-template row above for sync; install/trim via `agent-maintain` subcommands |
| Implementation / tests / debug / validation (pick skill) | [`ai/skill_routing.md`](ai/skill_routing.md); invoke matching skill before edits; skill `agents-skill-routing` | Same |

Version-sensitive APIs: repo/official docs before model memory. Host parity: [`agent_knowledge_base.md`](agent_knowledge_base.md) · [`agent_environment_setup.md`](agent_environment_setup.md).

## Harness (pointers only)

Doctrine: [`agent_knowledge_base.md`](agent_knowledge_base.md). **Context navigation ladder:** [`ai/context_loading.md`](ai/context_loading.md). **Skill routing:** [`ai/skill_routing.md`](ai/skill_routing.md). **Multi-Agent Hub:** [`agent_knowledge_base.md#multi-agent-hub`](agent_knowledge_base.md#multi-agent-hub).

Mechanical anchors (do not drop from this file): below 95%; execute end-to-end, verify, report proof; Behavior changes start in source docs; Reusable agent conclusion; semantic lint; Benefit: team; Benefit: single; `tasks/cursor/team/<run-id>/`.

## Host Adapters

| Need | Cursor | Codex |
| --- | --- | --- |
| Orientation + commands | `agents-quick-reference` | `agents-quick-reference` |
| Skill discovery / routing | `agents-skill-routing` | `agents-skill-routing` |
| Cubit/BLoC standards | `agents-bloc-standards` | `agents-bloc-standards` |
| Feature delivery contract | `agents-feature-delivery` | `agents-feature-delivery` |
| Non-trivial delivery | `agents-delivery-workflow` | `agents-delivery-workflow` |
| Plan/delegation reminders | `agents-meta-behavior` | — |
| Explicit cross-host second opinion | `/codex-feedback` or `./tool/request_codex_feedback.sh` | `./tool/request_codex_feedback.sh` only when user asks |

Shared host-neutral skill source: [`../tool/agent_host_templates/shared/skills/`](../tool/agent_host_templates/shared/skills/).

Repo-managed Cursor commands: `/local-agents-quick-reference`, `/upgrade-validate-all`, `/commit-push-pr`, `/codex-feedback`. **`/commit-push-pr`:** playbook [`changes/2026-05-21_agent_automated_delivery_loop.md`](changes/2026-05-21_agent_automated_delivery_loop.md); script reference [`validation_scripts/operations_running.md`](validation_scripts/operations_running.md#git--local-branch-cleanup).

## Task doc routing

Full map: [`AGENTS.md`](../AGENTS.md) § Map and [`README.md`](README.md). AI engineering index: [`PLAN.md`](../PLAN.md).
