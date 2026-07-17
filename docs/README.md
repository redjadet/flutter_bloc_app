# Documentation index

Source-of-truth docs for Flutter BLoC app.

## Start here

- **Thin entry hubs** (link-only; do not duplicate): [`architecture.md`](architecture.md),
  [`testing.md`](testing.md), [`engineering-decisions.md`](engineering-decisions.md),
  [`ai-workflow.md`](ai-workflow.md)
- **Interview showcase** (30-minute portfolio walk): [`interview_showcase.md`](interview_showcase.md)
- **Toolchain pins** (Flutter/Dart): [`toolchain_versions.env`](toolchain_versions.env) (machine),
  [`tech_stack.md`](tech_stack.md) (human display + synced CI/README sinks)
- **Onboarding / first run**: [`new_developer_guide.md`](new_developer_guide.md)
- **Validation + testing**: [`validation_scripts.md`](validation_scripts.md), [`testing_overview.md`](testing_overview.md),
  integration policy [`engineering/integration_test_policy.md`](engineering/integration_test_policy.md),
  runner contract [`engineering/integration_runner_contract.md`](engineering/integration_runner_contract.md)
- **Logging**: [`logging.md`](logging.md), [`observability.md`](observability.md)
- **Architecture**: [`feature_overview.md`](feature_overview.md), [`clean_architecture.md`](clean_architecture.md),
  [`architecture_details.md`](architecture_details.md), [`bloc_standards.md`](bloc_standards.md),
  [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md),
  [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md),
  [`architecture/MOBILE_BACKEND_BOUNDARIES.md`](architecture/MOBILE_BACKEND_BOUNDARIES.md),
  [`backend/API_CONTRACT_GUIDE.md`](backend/API_CONTRACT_GUIDE.md),
  [`backend/MOBILE_BACKEND_DEFERRED_WORK.md`](backend/MOBILE_BACKEND_DEFERRED_WORK.md)
- **Design / UI**: [`../DESIGN.md`](../DESIGN.md),
  [`design_system.md`](design_system.md)
- **AI / chat**: [`ai_integration.md`](ai_integration.md), [`integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md)
- **AI decision workbench**:
  [`ai_decision_workbench.md`](ai_decision_workbench.md) - FastAPI-backed
  decision demo: risk score, rationale, proof trail, action history.
- **Security**: [`SECURITY.md`](SECURITY.md), [`security_and_secrets.md`](security_and_secrets.md), [`security/certificate_pinning.md`](security/certificate_pinning.md)
- **Deployment**: [`deployment.md`](deployment.md)
- **Case studies (product briefs + demo feature)**: [`case_studies/README.md`](case_studies/README.md)
- **Feature walkthroughs**: [`staff_app_demo_walkthrough.md`](staff_app_demo_walkthrough.md),
  [`online_therapy_demo/README.md`](online_therapy_demo/README.md),
  [`features/realtime_market.md`](features/realtime_market.md),
  [`features/iot_ble.md`](features/iot_ble.md),
  [`features/counter_outcome_brief.md`](features/counter_outcome_brief.md)
- **AI agent harness**: [`agent_knowledge_base.md`](agent_knowledge_base.md),
  [`agent_project_context.md`](agent_project_context.md),
  [`ai/skill_routing.md`](ai/skill_routing.md),
  [`ai/agent_operating_manual.md`](ai/agent_operating_manual.md),
  [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md),
  [`ai/harness_scorecard.md`](ai/harness_scorecard.md),
  [`ai_code_review_protocol.md`](ai_code_review_protocol.md),
  [`agents_quick_reference.md`](agents_quick_reference.md),
  [`agent_knowledge_base_details.md`](agent_knowledge_base_details.md),
  [`agent_environment_setup.md`](agent_environment_setup.md),
  [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md),
  [`agent_host_notes.md`](agent_host_notes.md),
  [`code_review_graph.md`](code_review_graph.md)
  - Cold-start map printer: `bash ../tool/agent_session_bootstrap.sh`
  - Tracker contract: [`engineering/task_tracker_template.md`](engineering/task_tracker_template.md)

## Core docs (by concern)

### Case studies

- [`case_studies/README.md`](case_studies/README.md) — index of product briefs
- [`case_studies/dentists.md`](case_studies/dentists.md) — dentist video case-study requirements
- Implementation and Supabase extension plans live under [`changes/`](changes/README.md) (see index there)

### Architecture and design

- [`tech_stack.md`](tech_stack.md) — toolchain pins display; machine SoT [`toolchain_versions.env`](toolchain_versions.env)
- [`../DESIGN.md`](../DESIGN.md) — agent-readable visual brief and DesignMD tokens
- [`clean_architecture.md`](clean_architecture.md)
- [`architecture_details.md`](architecture_details.md)
- [`bloc_standards.md`](bloc_standards.md) — deterministic Cubit/BLoC rules for Cursor and Codex
- [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md) — feature folder and placement contract
- [`architecture/use_case_dto_policy.md`](architecture/use_case_dto_policy.md) — use-case, DTO, mapper, and error-boundary policy
- [`architecture/reduce_surprise_patterns.md`](architecture/reduce_surprise_patterns.md) — semantic patterns (DTO, sealed state, errors)
- [`architecture/reference_features.md`](architecture/reference_features.md) — gold layouts + semantic grades
- [`feature_overview.md`](feature_overview.md)
- [`modularity.md`](modularity.md)
- [`design_system.md`](design_system.md)
- [`universal_links/README.md`](universal_links/README.md)
- [`adr/README.md`](adr/README.md) - accepted architecture decision records and ADR lifecycle guidance

### Workflow and quality

- [`new_developer_guide.md`](new_developer_guide.md)
- [`git_and_branching_strategy.md`](git_and_branching_strategy.md) — human and AI Git, branch, PR, and worktree workflow
- [`agent_knowledge_base.md`](agent_knowledge_base.md)
- [`agent_project_context.md`](agent_project_context.md)
- [`agent_environment_setup.md`](agent_environment_setup.md)
- [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) — when agents run `preflight` / `closeout` / `after-host-edit`
- [`ai/ai_failure_risks.md`](ai/ai_failure_risks.md) — AI failure risk register and prevention/detection/recovery map
- [`ai/harness_scorecard.md`](ai/harness_scorecard.md) — Cursor/Codex max-score proof gate
- [`ai/harness_auto_maintenance.md`](ai/harness_auto_maintenance.md) — Agent loop to preserve max harness score
- [`validation_scripts.md`](validation_scripts.md)
- [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
- [`testing_overview.md`](testing_overview.md)
- [`testing/matrix_required_by_change.md`](testing/matrix_required_by_change.md)
- [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md) — BLoC widget test how-to
- [`logging.md`](logging.md)
- [`code_review_graph.md`](code_review_graph.md)
- [`review/code_review_playbook.md`](review/code_review_playbook.md) — shared
  AI/human review workflow, finding format, and decision record
- [`contributing/PR_REVIEW_CHECKLIST.md`](contributing/PR_REVIEW_CHECKLIST.md) —
  networking / pagination / Bloc / contract-test questions
- [`ai_code_review_protocol.md`](ai_code_review_protocol.md) — AI-specific risk
  matrix and Flutter review special cases
- [`CODE_QUALITY.md`](CODE_QUALITY.md)
- [`review/architecture_checklist.md`](review/architecture_checklist.md)
- [`review/bloc_checklist.md`](review/bloc_checklist.md)
- [`review/security_checklist.md`](review/security_checklist.md)
- [`review/performance_checklist.md`](review/performance_checklist.md)
- [`bloc/cubit_file_template.md`](bloc/cubit_file_template.md)
- [`architecture/feature_brief_scaffold_example.md`](architecture/feature_brief_scaffold_example.md)
- [`architecture/reference_features.md`](architecture/reference_features.md)
- [`plans/checklist_quality_gates_baseline.md`](plans/checklist_quality_gates_baseline.md) — checklist quality-theme gates (MVP, May 2026)
- [`plans/checklist_quality_gates_deferred.md`](plans/checklist_quality_gates_deferred.md) — deferred/rejected checklist gates backlog
- [`feature_implementation_guide.md`](feature_implementation_guide.md)
- [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md)
- [`ci_automation.md`](ci_automation.md)

#### Performance / lifecycle

- [`performance/memory_management.md`](performance/memory_management.md) — ownership principles
- [`performance/memory_testing.md`](performance/memory_testing.md) — leak_tracker tagged suite
- [`performance/memory_lints.md`](performance/memory_lints.md) — `memory_lint` rule IDs
- [`performance/memory_ci.md`](performance/memory_ci.md) — checklist / CI gates
- [`performance/memory_checklist.md`](performance/memory_checklist.md) — reviewer checklist

#### Engineering (`docs/engineering/`)

- [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) — fast vs full validation lanes
- [`engineering/integration_test_policy.md`](engineering/integration_test_policy.md) — where to add tests; failure ownership
- [`engineering/integration_journey_map.md`](engineering/integration_journey_map.md) — journeys → integration targets and tiers
- [`engineering/integration_runner_contract.md`](engineering/integration_runner_contract.md) — `./bin/integration_tests` env, tiers, artifacts
- [`engineering/integration_metrics_baseline.md`](engineering/integration_metrics_baseline.md) — rollout metrics and baseline commands
- [`engineering/agent_output_scorecard_v1.md`](engineering/agent_output_scorecard_v1.md) — agent scorecard event contract
- [`engineering/task_tracker_template.md`](engineering/task_tracker_template.md) — Cursor/Codex task tracker shape
- [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md) — deferred work and scheduling patterns
- [`engineering/apple_debug_hive_storage.md`](engineering/apple_debug_hive_storage.md) — iOS/macOS debug Hive + Keychain triage and regression guard
- [`testing_integration_flows.md`](testing_integration_flows.md) — authoring integration flows (companion to policy/contract)

### Offline-first and local storage

- [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md)
- [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md)
- [`offline_first/dont_overwrite_guide.md`](offline_first/dont_overwrite_guide.md)

### Setup, secrets, and integrations

- [`firebase_setup.md`](firebase_setup.md)
- [`authentication.md`](authentication.md)
- [`ai_integration.md`](ai_integration.md)
- [`integrations/render_fastapi_chat_demo.md`](integrations/render_fastapi_chat_demo.md)
- [`SECURITY.md`](SECURITY.md)
- [`security_and_secrets.md`](security_and_secrets.md)
- [`security/certificate_pinning.md`](security/certificate_pinning.md)
- [`features/certificate_pinning_demo.md`](features/certificate_pinning_demo.md)
- [`localization.md`](localization.md)
- [`universal_links/README.md`](universal_links/README.md)

### Feature walkthroughs and demos

- [`ai_decision_workbench.md`](ai_decision_workbench.md)
- [`staff_app_demo_walkthrough.md`](staff_app_demo_walkthrough.md)
- [`online_therapy_demo/README.md`](online_therapy_demo/README.md)
- [`features/in_app_purchase_demo.md`](features/in_app_purchase_demo.md)
- [`features/iot_ble.md`](features/iot_ble.md)
- [`fcm_demo_integration.md`](fcm_demo_integration.md)
- [`case_studies/README.md`](case_studies/README.md)
- [`genui_demo_user_guide.md`](genui_demo_user_guide.md)

### Release and distribution

- [`deployment.md`](deployment.md) — iOS, Android, dual-store Fastlane (`release_both_stores.sh`), web Pages
- [`firebase_app_distribution.md`](firebase_app_distribution.md) — pre-release testers
- [`android_play_store_release_sop.md`](android_play_store_release_sop.md) — Play validation gates and promotion
- [`../fastlane/README.md`](../fastlane/README.md) — Fastlane lane index (`deploy_all`, platform lanes)
- Env templates: [`.env.ios.release.example`](../.env.ios.release.example), [`.env.android.release.example`](../.env.android.release.example)

## Historical context (not source of truth)

- [`plans/README.md`](plans/README.md)
- [`audits/README.md`](audits/README.md)
- [`changes/README.md`](changes/README.md)
