# Plans (local working docs)

`docs/plans/**` (except this README) is **gitignored**. Working plans stay on
the local machine; they are not part of the shared repo contract.

## Policy

- Prefer tracked owners under `docs/` for day-to-day guidance.
- Keep in-flight design notes in local `docs/plans/` when useful.
- When a plan becomes a durable decision, land it in an ADR, change note, or
  topic owner — do not rely on a gitignored path from living docs.

## Tracked owners (promoted / redirected)

| Former / local plan basename | Tracked owner |
| --- | --- |
| FEATURE_TEMPLATE | [`engineering/FEATURE_TEMPLATE.md`](../engineering/FEATURE_TEMPLATE.md) |
| checklist_quality_gates_baseline | [`engineering/checklist_quality_gates_baseline.md`](../engineering/checklist_quality_gates_baseline.md) |
| checklist_quality_gates_deferred | [`engineering/checklist_quality_gates_deferred.md`](../engineering/checklist_quality_gates_deferred.md) |
| 2026-05-21_ai_first_engineering_plan (+ exec summary / changelog) | [`PLAN.md`](../../PLAN.md) |
| future_observability | [`observability.md`](../observability.md) |
| auth_security_hardening_deferred | [`authentication.md`](../authentication.md) § What remains |
| supabase_proxy_huggingface_chat_plan | [`offline_first/chat.md`](../offline_first/chat.md), [`integrations/ai_integration.md`](../integrations/ai_integration.md) |
| 2026-07-20_hybrid_shared_package_distribution | [`engineering/SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md) |
| 2026-07-17_memory_quality_deferred | [`changes/2026-07-17_memory_quality_deferred.md`](../changes/2026-07-17_memory_quality_deferred.md) |
| iot_ble_feature_brief | [`features/iot_ble.md`](../features/iot_ble.md) |
| 2026-08-20_social_feed_senior_signal_demo | [`features/social_feed_demo.md`](../features/social_feed_demo.md) |
| senior_patterns_optimization_2026-06 | [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) |
| future_architecture_code_quality_improvement_plan | [`architecture/tradeoffs_and_future.md`](../architecture/tradeoffs_and_future.md) |
| code_quality_baseline_and_gate_promotion_2026-06 | [`audits/code_quality_baseline_2026-06-03.md`](../audits/code_quality_baseline_2026-06-03.md) |
| Feasibility spikes (Melos / DI / dependency_validator / settings) | [`modularity.md`](../modularity.md) |
| patrol_e2e_pilot | [`interview_showcase.md`](../interview_showcase.md) |

Shipped history: [`changes/README.md`](../changes/README.md). Evidence audits:
[`audits/README.md`](../audits/README.md).
