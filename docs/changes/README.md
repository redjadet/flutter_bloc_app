# Changes (historical notes)

This directory contains point-in-time notes that explain **why** a change was
made (or what a specific refactor intended to achieve). These are not intended
to be the “current how-to”; prefer the source-of-truth docs under `docs/` for
that.

## Index

- [`2026-07-22_agent_worktree_automation.md`](2026-07-22_agent_worktree_automation.md): Dry-run-first isolated worktree creation with validated base, branch, path, CLI routing, and fixture proof.
- [`2026-07-22_bump_ilkersevim_relative_time_0.1.1.md`](2026-07-22_bump_ilkersevim_relative_time_0.1.1.md): Bump hosted `ilkersevim_relative_time` caret to `^0.1.1` after OIDC proof.
- [`2026-07-22_bump_ilkersevim_disposables_0.1.1.md`](2026-07-22_bump_ilkersevim_disposables_0.1.1.md): Bump hosted `ilkersevim_disposables` caret to `^0.1.1` after OIDC proof.
- [`2026-07-22_agent_engineering_judgment.md`](2026-07-22_agent_engineering_judgment.md): Lean AI coding guidance for problem definition, simple resilient design, understood reuse, maintainable communication, and proof.
- [`2026-07-22_disposables_public_package.md`](2026-07-22_disposables_public_package.md): Extract DisposableBag / managers / TimerDisposable to public `ilkersevim_disposables` on Pub.dev (`^0.1.0`).
- [`2026-07-22_relative_time_public_package.md`](2026-07-22_relative_time_public_package.md): Extract short relative-time labels to public `ilkersevim_relative_time` on Pub.dev (`^0.1.0`).
- [`2026-07-22_retire_json_isolate_shim.md`](2026-07-22_retire_json_isolate_shim.md): Retire app `isolate_json` shim; import hosted `ilkersevim_json_isolate` only.
- [`2026-07-22_json_isolate_public_package.md`](2026-07-22_json_isolate_public_package.md): Extract Flutter compute JSON helpers to public `ilkersevim_json_isolate` on Pub.dev (`^0.1.0`).
- [`2026-07-22_async_lifecycle_public_package.md`](2026-07-22_async_lifecycle_public_package.md): Extract completer + stream lifecycle helpers to public `ilkersevim_async_lifecycle` on Pub.dev (`^0.1.0`).
- [`2026-07-22_retire_type_safe_bloc_shims.md`](2026-07-22_retire_type_safe_bloc_shims.md): Retire app type_safe_bloc shims; import hosted `ilkersevim_type_safe_bloc` directly.
- [`2026-07-21_type_safe_bloc_public_package.md`](2026-07-21_type_safe_bloc_public_package.md): Extract type-safe BLoC helpers to public `ilkersevim_type_safe_bloc` on Pub.dev (`^0.1.0`).
- [`2026-07-20_hybrid_async_utils_public_package.md`](2026-07-20_hybrid_async_utils_public_package.md): Extract async coalescers + request-id guard to public `ilkersevim_async_utils` on Pub.dev (`^0.1.0`).
- [`2026-07-20_low_risk_package_extraction_tasks_2_4.md`](2026-07-20_low_risk_package_extraction_tasks_2_4.md): Tasks 2–4 — feature_flags token port + app_shared_flutter BLoC/date/JSON helpers with shims.
- [`2026-07-20_low_risk_package_extraction_task1.md`](2026-07-20_low_risk_package_extraction_task1.md): Move diagnostics sync-time helper + GraphQL cache clear port into `packages/utilities` (import-only feature touch; behavior unchanged).
- [`2026-07-17_memory_quality_deferred.md`](2026-07-17_memory_quality_deferred.md): Deferred backlog for memory quality program leftovers after B1.
- [`2026-07-17_memory_quality_wave_b1.md`](2026-07-17_memory_quality_wave_b1.md): Tag stable leak journeys (auth, app-shell `go`, realtime/BLE teardown); no global ignore flip.
- [`2026-07-17_memory_quality_wave_b0.md`](2026-07-17_memory_quality_wave_b0.md): Report-only leak tracking dry-run tooling + baseline audit; no global ignore flip.
- [`2026-07-17_memory_quality_wave_a.md`](2026-07-17_memory_quality_wave_a.md): Progressive memory gate — `memory_lint` plugin, tagged `leak_tracker` suite, checklist enforcement; no global ignore flip.
- [`2026-07-17_safe_agent_autonomy.md`](2026-07-17_safe_agent_autonomy.md): Routine reversible repo-local work is autonomous; dangerous, external, secret/production, and Git mutations retain explicit approval gates.
- [`2026-07-17_docs_aggressive_prune.md`](2026-07-17_docs_aggressive_prune.md): Delete completed plans/migrations; shorten large how-tos to current contracts; preserve owner-index pointers.
- [`2026-07-17_domain_purity_remaining_demos.md`](2026-07-17_domain_purity_remaining_demos.md): case_study → chart → iGaming → IoT → search → staff flags; domain wire leaks 31→0; deferred leftovers were later retired.
- [`2026-07-17_domain_purity_chat_counter_todo.md`](2026-07-17_domain_purity_chat_counter_todo.md): Wave B — move chat/counter/todo wire JSON into data DTOs; domain wire leaks 45→31.
- [`2026-07-17_di_composition_simplify.md`](2026-07-17_di_composition_simplify.md): Wave A — thin DI groups into `register_*` modules; move auth/staff/remote-config fallbacks into feature `data/`; preserve order/dispose/policy.
- [`2026-07-16_mobile_backend_integration_hardening.md`](2026-07-16_mobile_backend_integration_hardening.md): Mobile/backend contract safety — defensive DTOs, required Dio injection, ad-hoc Dio CI guard, canonical contract docs; deferred list [`backend/MOBILE_BACKEND_DEFERRED_WORK.md`](../backend/MOBILE_BACKEND_DEFERRED_WORK.md).
- [`2026-07-15_native_security_showcase.md`](2026-07-15_native_security_showcase.md): Native security cards on `/native-platform-showcase` (MethodChannel crypto/storage/biometric, App Check probe, TLS pin summary) with zero secrets in UI/state.
- [`2026-07-15_agent-safety-contracts.md`](2026-07-15_agent-safety-contracts.md): Canonical agent safety contracts (`SAFETY-01..06`, `SAFETY-REPORT`) with drift gate, risk-register wiring, and AI snapshot `git_head` refresh.
- [`2026-07-13_web_first_load_splash.md`](2026-07-13_web_first_load_splash.md): Web HTML + Flutter splash during first launch; parallel bootstrap steps; blank-screen fix.
- [`2026-07-12_agent_tool_auto_routing.md`](2026-07-12_agent_tool_auto_routing.md): Intent/path tool router integrated into preflight; MCP naming de-drifted; hot-reload rule scoped to current workspace paths.
- [`2026-07-12_agent_docs_and_host_sync_conflict_repair.md`](2026-07-12_agent_docs_and_host_sync_conflict_repair.md): Current package/app ownership restored in AI maps; project-only Cursor execution rule added to sync and drift enforcement.
- [`2026-07-10_adr_quality_hardening.md`](2026-07-10_adr_quality_hardening.md): Current-path ADR repair plus deterministic metadata, consequence, section, and stale-ownership guard with negative fixture.
- [`2026-07-10_long_agent_docs_compression.md`](2026-07-10_long_agent_docs_compression.md): State-management and responsive-review essays compressed into short decision, review, and proof contracts without removing owner gates.
- [`2026-07-10_architecture_docs_dedup.md`](2026-07-10_architecture_docs_dedup.md): Architecture canon deduplicated around package ownership, feature references, app composition, and enforceable review owners.
- [`2026-07-10_agent_context_loading_dedup.md`](2026-07-10_agent_context_loading_dedup.md): Cold-start context reduced to three core docs plus guarded conditional owner routes.
- [`2026-07-10_maintainability_followup_wave_closeout.md`](2026-07-10_maintainability_followup_wave_closeout.md): Follow-up wave closeout — program complete; soft-scan 0; audit re-grade; `staff_app_demo` deferred.
- [`2026-07-10_maintainability_followup_h_counter_sealed_state.md`](2026-07-10_maintainability_followup_h_counter_sealed_state.md): Follow-up H — sealed CounterState + CounterViewData.
- [`2026-07-10_maintainability_followup_g_ai_decision_typed_maps.md`](2026-07-10_maintainability_followup_g_ai_decision_typed_maps.md): Follow-up G — type ai_decision domain Map bags.
- [`2026-07-10_maintainability_followup_f_chat_conversation_history.md`](2026-07-10_maintainability_followup_f_chat_conversation_history.md): Follow-up F — chat conversation history pure domain helpers.
- [`2026-07-10_maintainability_followup_e_chat_failure.md`](2026-07-10_maintainability_followup_e_chat_failure.md): Follow-up E — `ChatFailure` on ChatState + ChatListState.error.
- [`2026-07-10_maintainability_followup_d_scapes_sealed_state.md`](2026-07-10_maintainability_followup_d_scapes_sealed_state.md): Follow-up D — sealed ScapesState (initial/loading/ready/error).
- [`2026-07-10_maintainability_followup_c_ai_decision_failure.md`](2026-07-10_maintainability_followup_c_ai_decision_failure.md): Follow-up C — `AiDecisionFailure` replaces string errorMessage.
- [`2026-07-10_maintainability_followup_b_scapes_toggle_favorite.md`](2026-07-10_maintainability_followup_b_scapes_toggle_favorite.md): Follow-up B — extract scapes `toggleFavorite` into domain pure function.
- [`2026-07-10_maintainability_followup_a_backend_banner_bool.md`](2026-07-10_maintainability_followup_a_backend_banner_bool.md): Follow-up A — replace `BackendAvailability` type params with `bool showBackendDisabledBanner` in chat + IoT demo presentation; router computes visibility via new `BackendAvailability` getters.
- [`2026-07-10_maintainability_followups_router_validate_diagnostics.md`](2026-07-10_maintainability_followups_router_validate_diagnostics.md): Follow-ups — fix `router_feature_validate` paths after core→app move; drop GetIt from chat render orchestration diagnostics (composition-only callback).
- [`2026-07-10_maintainability_slice2_secret_config_injection.md`](2026-07-10_maintainability_slice2_secret_config_injection.md): Slice 2 — inject SecretConfig chat flags into chat presentation; router resolves once.
- [`2026-07-10_maintainability_slice1_backend_availability_injection.md`](2026-07-10_maintainability_slice1_backend_availability_injection.md): Slice 1 — inject `BackendAvailability` into chat + IoT cloud UI; GetIt stays in router/composition only.
- [`2026-07-10_native_platform_showcase_native_integration_demos.md`](2026-07-10_native_platform_showcase_native_integration_demos.md): Native showcase live PlatformView banner, haptic, and system-share MethodChannel demos on iOS/Android.
- [`2026-07-06_folder-structure-codex-followups.md`](2026-07-06_folder-structure-codex-followups.md): Codex folder-structure follow-ups — `core/di/features/`, `package:auth`, shared shim removal, feature layout drift fixes, `check_features_barrel.sh`.
- [`2026-07-02_token-repository-memory-auth-state.md`](2026-07-02_token-repository-memory-auth-state.md): Dedicated `TokenRepository` for in-memory auth token reads; secure storage / SDK persistence limited to startup, login/session hydration, refresh, and logout cleanup.
- [`2026-07-02_auth-session-lifecycle-regression-guards.md`](2026-07-02_auth-session-lifecycle-regression-guards.md): Auth session lifecycle focused guard routing for session-expired UX races and cross-provider invalidation drops.
- [`2026-06-28_auth-security-hardening-pr-c.md`](2026-06-28_auth-security-hardening-pr-c.md): Auth security PR C — `AppAuthCubit` session-expired UX, l10n, full [`authentication.md`](../authentication.md) pass; deferred plan later retired.
- [`2026-06-28_auth-security-hardening-pr-b.md`](2026-06-28_auth-security-hardening-pr-b.md): Auth security PR B — `SupabaseSessionManager`, `JwtClaimsReader`, Supabase repo consolidation, `sessionExpired` on Supabase cubit.
- [`2026-06-28_auth-security-hardening-pr-a.md`](2026-06-28_auth-security-hardening-pr-a.md): Auth security PR A — `SessionLifecycleCoordinator`, decorated `AuthRepository`, DI singleton `AuthTokenManager`, classified interceptor invalidation, logging redaction.
- [`2026-06-25_agent_operating_manual.md`](2026-06-25_agent_operating_manual.md): Project AI Operating Manual — thin router, finish-gate response tiers, context ladder 2b, check-script and host-template needles.
- [`2026-06-25_flutter-sdk-mutation-guard.md`](2026-06-25_flutter-sdk-mutation-guard.md): AI agents must not patch core Flutter/Dart SDK or framework sources; add read-only rule across agent map, project caveats, risk register, and common-pitfalls skill.
- [`2026-06-24_agents-regression-capture-skill.md`](2026-06-24_agents-regression-capture-skill.md): Post-fix hardening skill — regression tests, static guards, checklist wiring, lessons; delivery finish gate + harness needles.
- [`2026-06-27_iot-setvalue-enqueue-flush-guard.md`](2026-06-27_iot-setvalue-enqueue-flush-guard.md): IoT demo debounced `setValue` enqueue flush guard — prevents stale remote pulls while sync enqueue is still in progress.
- [`2026-06-25_iot-debounced-setvalue-pull-guard.md`](2026-06-25_iot-debounced-setvalue-pull-guard.md): IoT demo debounced `setValue` pull guard — prevents stale remote pulls from overwriting in-flight slider changes.
- [`2026-06-23_business-logic-ui-separation.md`](2026-06-23_business-logic-ui-separation.md): Business logic / UI separation — derived state getters, staff shift assignment cubit/domain defaults, chat relative-time helper, agent guidance.
- [`2026-06-23_chat-persist-epoch.md`](2026-06-23_chat-persist-epoch.md): Chat persist epoch — late unawaited assistant saves cannot restore history after clear/delete; regression tests cover destructive history races.
- [`2026-06-22_bug-hunt-inventory.md`](2026-06-22_bug-hunt-inventory.md): Full-repo bug hunt — mechanical inventory, 34-feature audit worksheet, disposition table (B–D fixes + deferred B6–B10/D4/D7).
- [`2026-06-22_batch-b-stream-error-hardening.md`](2026-06-22_batch-b-stream-error-hardening.md): Stream error hardening — supabase `cancelOnError: false`, IAP/websocket/IoT purchase or watch paths.
- [`2026-06-22_batch-c-therapy-initstate-call-guard.md`](2026-06-22_batch-c-therapy-initstate-call-guard.md): Therapy `CallCubit` `RequestIdGuard`, initState → postFrameCallback (10 files), initState guard regex for `context.cubit<`.
- [`2026-06-22_batch-d-data-chat-profile-graphql.md`](2026-06-22_batch-d-data-chat-profile-graphql.md): Chat reset persist-first, profile `pullRemote` failure propagation, GraphQL refresh await.
- [`2026-06-22_batch-e-feature-audit-closeout.md`](2026-06-22_batch-e-feature-audit-closeout.md): 34-feature audit closeout — repro-first deferrals (B7–B10, D4, D7), staff `pullRemote` documented + test.
- [`2026-06-22_batch-f-ship-proof.md`](2026-06-22_batch-f-ship-proof.md): Full checklist + iOS integration proof; review follow-ups (IAP terminal/unknown product, profile cache rethrow).
- [`2026-06-22_todo-remote-merge-toctou.md`](2026-06-22_todo-remote-merge-toctou.md): Todo list-entity remote merge TOCTOU — re-read before save/delete, full counter/todo regression parity (pullRemote + watch, static stale-remote + TOCTOU), `dont_overwrite_guide` + remote-merge guard inventory.
- [`2026-06-19_senior-patterns-reduce-surprise.md`](2026-06-19_senior-patterns-reduce-surprise.md): Reduce-surprise program — DTO boundaries, sealed states, domain policies, typed errors; agent guide + AP-11…17; scorecard closeout.
- [`2026-06-16_staff-demo-plugin-hardening.md`](2026-06-16_staff-demo-plugin-hardening.md): Staff demo plugin audit — `Result`/`Failure` at location/media seams, proof photo picker port + DI, camera_gallery failure mapper, regression tests, storage/plugin-failure docs.
- [`2026-06-16_widget-list-stable-keys.md`](2026-06-16_widget-list-stable-keys.md): Widget identity in dynamic lists — stable `ValueKey`s (websocket `sequence`, chat `clientMessageId`, case-study `CaseStudyQuestionId`, order-book side+price); monotonic websocket sequence across disconnect; `check_widget_identity` `ObjectKey` advisory.
- [`2026-06-16_chat-send-supersession-loading.md`](2026-06-16_chat-send-supersession-loading.md): Chat — `sendMessage` clears stuck `isLoading` and persists assistant reply when `RequestIdGuard` superseded by history actions.
- [`2026-06-15_web-parity-staff-case-study.md`](2026-06-15_web-parity-staff-case-study.md): Web parity for staff proof + case-study clip playback — removed web DI/route shims, io/web file stores, video blob lifecycle, MIME on Supabase upload, transient submit errors.
- [`2026-06-15_staff-production-review.md`](2026-06-15_staff-production-review.md): Staff+ production review — R1–R7 remediation, judgement docs, doc hubs; audit [`staff_production_review_2026-06-15.md`](../audits/staff_production_review_2026-06-15.md).
- [`2026-06-15_mutation-success-guard.md`](2026-06-15_mutation-success-guard.md): Static guard + regression routing for mutation success after `RequestIdGuard` supersession (therapy booking bug class).
- [`2026-06-15_agent_harness_structure.md`](2026-06-15_agent_harness_structure.md): AI-agent harness structure — prompts, evaluators, tests, runtime checks, and feedback loops over repeated prompt tweaks.
- [`2026-06-15_therapy-booking-reload-supersession.md`](2026-06-15_therapy-booking-reload-supersession.md): Therapy demo — `createAppointmentFromSlot` returns success when `RequestIdGuard` superseded during post-create reload (complements 2026-06-12 write-phase fix).
- [`2026-06-08_native_platform_showcase_feature_brief.md`](2026-06-08_native_platform_showcase_feature_brief.md): Native platform showcase from Example; layered architecture (use case → repository → platform services → MethodChannel/FFI), live interop, route/deeplink, smoke integration + web preflight.
- [`2026-06-08_ca_mvvm_runtime_package_docs_harness.md`](2026-06-08_ca_mvvm_runtime_package_docs_harness.md): CA skeleton + presentation-only MVVM; runtime-errors and package-docs MCP harness.
- [`2026-06-08_file_length_lint_qg-d02.md`](2026-06-08_file_length_lint_qg-d02.md): QG-D02 promoted — `file_too_long` at error (225 lines), `run_file_length_lint.sh`, checklist hook.
- [`2026-06-08_agent_doc_dedup.md`](2026-06-08_agent_doc_dedup.md): Agent-facing doc dedup — canonical owners, thinned echoes, fixed `agent-maintain` command link.
- [`2026-06-08_harness_auto_maintenance.md`](2026-06-08_harness_auto_maintenance.md): Scope-driven `harness-maintain` / closeout wiring for max-score preservation.
- [`2026-06-08_ai_failure_risk_minimization.md`](2026-06-08_ai_failure_risk_minimization.md): AI failure risk register, Pre-Flight routing, static gate needles.
- [`2026-06-08_harness_fill_gaps.md`](2026-06-08_harness_fill_gaps.md): [`reference_features.md`](../architecture/reference_features.md), folder-contract and import gates wired through skills and routing.
- [`2026-06-08_harness_quick_wins.md`](2026-06-08_harness_quick_wins.md): Security/performance review checklists, BLoC standards, feature-delivery skills, architecture scripts.
- [`2026-06-08_cursor_codex_harness_max_score.md`](2026-06-08_cursor_codex_harness_max_score.md): Cursor/Codex harness max-score contract and proof gate.
- [`2026-06-07_layering-optimization.md`](2026-06-07_layering-optimization.md): Clean Architecture layering pass (domain shims, cubit-owned sync counts, composition roots, modularity guardrail).
- [`2026-06-07_todo-sync-banner-not-on-page.md`](2026-06-07_todo-sync-banner-not-on-page.md): Product decision — `TodoSyncBanner` not mounted on live todo list page; widget/tests retained.
- [`2026-06-06_guest-sign-in-ios-simulator.md`](2026-06-06_guest-sign-in-ios-simulator.md): iOS simulator guest sign-in (App Check skip, keychain local guest, router redirect, RTDB remote omit, regression tests + integration journey).
- [`2026-06-06_common-page-layout-appbar-widening.md`](2026-06-06_common-page-layout-appbar-widening.md): `CommonPageLayout` optional custom `appBar`, scaffold `backgroundColor`, and migrations for search/counter/chat list/calculator shells.
- [`2026-06-06_auth-repository-presentation-seams.md`](2026-06-06_auth-repository-presentation-seams.md): `AccountSection` + `ChatCubit` use injected `AuthRepository` (and chat Supabase/HF deps) instead of direct Firebase SDK in presentation; tests and auth docs updated.
- [`2026-06-05_skill_routing.md`](2026-06-05_skill_routing.md): Canonical [`ai/skill_routing.md`](../ai/skill_routing.md) + `agents-skill-routing` shim for automatic skill discovery (repo-first over vendor Dart/Flutter skills).
- [`2026-06-04_event-bus-demo-from-example.md`](2026-06-04_event-bus-demo-from-example.md): Event Bus pattern demo from Example page; route, deeplink, demo-scoped DI, l10n, unit/widget/integration tests.
- [`2026-06-04_agent_host_maintain_automation.md`](2026-06-04_agent_host_maintain_automation.md): `./bin/agent-maintain` scope-based `closeout`, `docs-sync`, `after-host-edit`; PLAN_ONLY contract tests; policy shard and validation-doc auto-fix wiring.
- [`2026-06-02_agent_doc_line_budget.md`](2026-06-02_agent_doc_line_budget.md): Frequent AI-agent docs and active trackers capped at 200 lines; self-improvement details split to a shard and tracker history archived.
- [`2026-06-02_agent_self_improvement_stack.md`](2026-06-02_agent_self_improvement_stack.md): Safe self-improvement stack for repo agents: reflection, verified memory, reversible scaffold evolution; model/population evolution non-default.
- [`2026-05-22_agent-memory-auto-maintain.md`](2026-05-22_agent-memory-auto-maintain.md): [`agent_memory_auto_maintain.sh`](../../tool/agent_memory_auto_maintain.sh) wired into KB check (local) and sync `--apply` (verify); CI-safe.
- [`2026-05-22_agent-memory-ladder-dedupe.md`](2026-05-22_agent-memory-ladder-dedupe.md): One cold-start ladder ([`context_loading.md`](../ai/context_loading.md)); file-discovery layers de-numbered in [`memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md).
- [`2026-05-22_agent-context-optimization.md`](2026-05-22_agent-context-optimization.md): Agent context/token pass — repo + host template dedupe, sync, balanced global trim; before/after inventory.
- [`2026-05-22_agent-context-baseline.md`](2026-05-22_agent-context-baseline.md): Pre-pass skill inventory snapshot (`repoTemplates` 10411 tokens).
- [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md): Dedup theme matrix (canonical owners vs echoes).
- [`2026-05-22_tests-as-feature-definition.md`](2026-05-22_tests-as-feature-definition.md): FEATURE_TEMPLATE executable **Tests** contract; feature-defined testing policy; widget test playbook; delivery/review routers.
- [`2026-05-21_agent_automated_delivery_loop.md`](2026-05-21_agent_automated_delivery_loop.md): `/commit-push-pr` canon; checklist + integration proof; post-merge `main` sync.
- **2026-05-21 (doc):** Agent doc dedup — ladder canon [`ai/context_loading.md`](../ai/context_loading.md); [`PLAN.md`](../../PLAN.md)/`quick_reference`/`KB`/`review_protocol` trimmed; harness/commands single-owner.
- [`2026-05-21_arch_001_002_case_study_decouple.md`](2026-05-21_arch_001_002_case_study_decouple.md): ARCH-001 shared media/auth ports; ARCH-002 cubit mixin split; merged PR #240.
- [`2026-05-21_firebase_secret_history_scrub.md`](2026-05-21_firebase_secret_history_scrub.md): Firebase secret-scanning remediation, `.envrc` + placeholder Dart workflow, `git filter-repo` history scrub, doc updates.
- [`2026-05-20_checklist_quality_gates.md`](2026-05-20_checklist_quality_gates.md): four quality-theme checklist gates (MVP), `CHECK_SCRIPT_THEMES`, path-triggered router validate; deferred backlog later retired.
- [`2026-05-17_global_agent_skills_install_trim.md`](2026-05-17_global_agent_skills_install_trim.md): repo scripts to install/update/dedupe global vendor skills (`~/.agents/skills` vs synced `~/.cursor/skills`); skill inventory/budget includes `agentsSkills`.
- [`2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md`](2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md): UTF-8 bytes JSON helpers (`decodeJsonMapFromBytes` / fused `utf8`+`json` converter), Hugging Face client `ResponseType.bytes`, tests; pointers to future Retrofit-bytes and optional FFI/SIMD JSON evaluation.
- [`2026-05-12_modular_architecture_plan_implementation.md`](2026-05-12_modular_architecture_plan_implementation.md): modular metrics script, generalized modularity gate, shared↔feature decoupling (`AppMemoryService`), DI group `part` split, tests + feasibility docs.
- [`2026-05-12_senior_quality_hotspots_audit.md`](2026-05-12_senior_quality_hotspots_audit.md): hotspot churn audit outcome, SAFE vs backlog split, and where the full write-up lives (`docs/audits/`).
- [`2026-05-05_codex_context_navigation_ladder.md`](2026-05-05_codex_context_navigation_ladder.md): Codex context-navigation ladder for
  durable memory, structural graph use, and targeted raw-file reads.
- [`2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md`](2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md): manifest-driven
  Hive schema migrations; full migrate for todo + counter; pending-sync section
  is historical-only (superseded by shipped May 5 pending-sync migration docs).
- [`2026-04-01_dentist_case_study_demo_plan.md`](2026-04-01_dentist_case_study_demo_plan.md): **Case Study Demo** feature scope, routes, auth,
  Hive persistence, and tests (implements [`docs/case_studies/dentists.md`](../case_studies/dentists.md); Supabase storage plan removed 2026-07-17 — see dentists brief).
- [`2026-03-24_agent_output_optimization_purpose.md`](2026-03-24_agent_output_optimization_purpose.md): motivation/constraints for
  agent-output optimization work.
- [`2026-02-23_code_quality_plan.md`](2026-02-23_code_quality_plan.md): historical plan document (superseded by
  current docs + implemented changes).
- [`2026-02-23_code_improvements.md`](2026-02-23_code_improvements.md): summary of improvements landed in that
  timeframe.
