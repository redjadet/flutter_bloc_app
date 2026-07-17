# Plans (historical and in-flight)

This directory contains design notes and execution plans.

## How to use these documents

- Prefer the **current source-of-truth docs** under `docs/` for day-to-day work
  (onboarding, architecture, validation, testing, security, deployment).
- Treat plans as **working documents**: they can be superseded by implemented
  code, ADRs, or newer docs.
- When a plan results in a repo-wide decision, record it as an ADR under
  `docs/adr/` or update the owning source-of-truth doc.

## Index

- [`2026-07-17_memory_quality_deferred.md`](2026-07-17_memory_quality_deferred.md): **Deferred** — memory quality A→B1 leftovers (merge ops, B2/B3, non-goals, B0 evidence, lint exclusions).
- [`2026-07-17_maintainability_simplify_deferred.md`](2026-07-17_maintainability_simplify_deferred.md): **Deferred** — Wave C presentation splits (MS-D01); staff clock-out partial `flags` wire (MS-D02) after 2026-07-17 DI/domain purity series.
- [`2026-07-10_maintainability_program.md`](2026-07-10_maintainability_program.md): **Complete** — soft-seam program + follow-up wave A–H; soft presentation scan empty; `staff_app_demo` Firestore maps deferred.
- [`2026-05-21_ai_first_engineering_plan.md`](2026-05-21_ai_first_engineering_plan.md): **Agent runtime** — status, backlog, gates (~45 lines).
- [`ai_first_engineering_plan_changelog.md`](ai_first_engineering_plan_changelog.md): Classification of prior AI/operability ideas vs this repo.
- [`ai_first_engineering_executive_summary.md`](ai_first_engineering_executive_summary.md): Metrics and outcomes snapshot (2026-05-21).
- [`FEATURE_TEMPLATE.md`](FEATURE_TEMPLATE.md): Feature Brief + executable **Tests** contract (behaviour, state, unit, integration, proof); enforced by `tool/check_feature_brief_linked.sh` for feature Dart diffs.
- [`iot_ble_feature_brief.md`](iot_ble_feature_brief.md): **Shipped** — BLE showcase tab on `/iot-demo` (mock + mobile real BLE).
- [`checklist_quality_gates_baseline.md`](checklist_quality_gates_baseline.md): MVP wiring for fourteen quality-theme checklist gates (May 2026).
- [`checklist_quality_gates_deferred.md`](checklist_quality_gates_deferred.md): post-MVP deferred/rejected checklist gates (IDs, unblock criteria).
- [`code_quality_baseline_and_gate_promotion_2026-06.md`](code_quality_baseline_and_gate_promotion_2026-06.md): **Ready to execute** — Phase 0a baseline audit, gate spikes (0b), one vertical slice per cadence; complements future architecture plan.
- [`senior_patterns_optimization_2026-06.md`](senior_patterns_optimization_2026-06.md): **Complete (June 2026)** — reduce-surprise program index (DTO boundaries, sealed state, AppError); canonical guide [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md).
- [`dependency_validator_feasibility.md`](dependency_validator_feasibility.md): spike outcome — defer `dependency_validator` in CI (noisy on this repo layout).
- [`feature_scoped_di_feasibility.md`](feature_scoped_di_feasibility.md): `get_it` push/pop scope spike — defer; risks vs sync/IoT.
- [`melos_package_split_feasibility.md`](melos_package_split_feasibility.md): stay single-package until trigger conditions; costs/benefits matrix.
- [`2026-04-27_ai_agent_code_quality_hardening_plan.md`](2026-04-27_ai_agent_code_quality_hardening_plan.md): Cursor-ready plan for hardening AI-agent guidance,
  validation helpers, and confirmed AI-generated-code risk patterns.
- [`future_architecture_code_quality_improvement_plan.md`](future_architecture_code_quality_improvement_plan.md): staged roadmap and
  decision gates for ongoing quality/architecture work.
- [`settings_diagnostics_decouple_plan.md`](settings_diagnostics_decouple_plan.md): completed slice (kept for context).
- [`2026-03-13-structured-error-taxonomy-design.md`](2026-03-13-structured-error-taxonomy-design.md): design notes for typed error
  taxonomy work.
- [`dio_retrofit_integration_plan.md`](dio_retrofit_integration_plan.md): Dio/Retrofit **current contract** (pilots done).
- [`supabase_proxy_huggingface_chat_plan.md`](supabase_proxy_huggingface_chat_plan.md): Supabase Edge → Hugging Face chat **transport contract** (offline-first shell: [`offline_first/chat.md`](../offline_first/chat.md)).
- [`../integrations/render_fastapi_chat_demo.md`](../integrations/render_fastapi_chat_demo.md): FastAPI chat orchestration demo freezes. **Deferred auth hook:** [AUTH-D01](auth_security_hardening_deferred.md#auth-d01-render-fastapi-coordinator-hook).
- [`auth_security_hardening_deferred.md`](auth_security_hardening_deferred.md): Post–PR A–C deferred auth/security items (Render coordinator, RegisterPage backend, role/claims ADR, `auth_injection_failed` extra).
- [`future_observability.md`](future_observability.md): doc-only seams for Mixpanel/Sentry/Patrol (not in `pubspec.yaml`); interview appendix.
- [`patrol_e2e_pilot.md`](patrol_e2e_pilot.md): Patrol E2E pilot plan (native sync diagnostics, settings theme); not shipped.
