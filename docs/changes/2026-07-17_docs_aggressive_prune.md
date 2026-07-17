# Docs aggressive prune (large/completed plans)

## Why

`docs/` held ~405 markdown files / ~48k lines. Largest files were completed
implementation plans and finished migration essays, not live contracts.
Goal: delete or compress without losing owner routing.

## Policy applied

| Bucket | Action |
| --- | --- |
| Completed plans / finished migrations / orphans | Deleted |
| Still-useful how-tos | Shortened to current contracts only (no execution history) |
| Live ops / agent harness owners | Kept |

## Deleted (Tier A)

Removed paths (no longer in tree) → current owners:

| Removed (historical path) | Current owner |
| --- | --- |
| plans/melos monorepo migration plan | Melos closeout [`2026-07-03_melos-monorepo-migration-closeout.md`](2026-07-03_melos-monorepo-migration-closeout.md); `tool/check_package_dependency_dag.sh` |
| plans/2026-07-14 AI-native hardening plan | [`ai_snapshot_freshness.md`](../validation_scripts/ai_snapshot_freshness.md) |
| plans/render FastAPI chat demo plan | [`render_fastapi_chat_demo.md`](../integrations/render_fastapi_chat_demo.md) |
| plans/2026-05-21 AI-first build spec | [`PLAN.md`](../../PLAN.md); slim [`2026-05-21_ai_first_engineering_plan.md`](../plans/2026-05-21_ai_first_engineering_plan.md) |
| plans/native communication architecture | Feature `native_platform_showcase` + related change notes |
| plans/supabase proxy HF chat Codex review | Shortened [`supabase_proxy_huggingface_chat_plan.md`](../plans/supabase_proxy_huggingface_chat_plan.md) + [`chat.md`](../offline_first/chat.md) |
| ai decision system plan | [`ai_decision_workbench.md`](../ai_decision_workbench.md) |
| genui SDK demo implementation plan | [`genui_demo_user_guide.md`](../genui_demo_user_guide.md) |
| camera gallery integration plan | Feature `camera_gallery` + [`feature_overview.md`](../feature_overview.md) |
| changes/2026-04-02 case study Supabase storage plan | [`dentists.md`](../case_studies/dentists.md) |
| todo list offline-first considerations | [`adoption_guide.md`](../offline_first/adoption_guide.md) |
| todo list Firebase RTDB plan | [`todo_list_firebase_security_rules.md`](../todo_list_firebase_security_rules.md) |
| sealed classes migration essay | [`compile_time_safety.md`](../compile_time_safety.md), [`bloc_standards.md`](../bloc_standards.md) |
| migration to type-safe BLoC essay | [`compile_time_safety.md`](../compile_time_safety.md) |
| equatable to freezed conversion essay | [`freezed_usage_analysis.md`](../freezed_usage_analysis.md) |
| cupertino widget migration essay | [`design_system.md`](../design_system.md) |
| figma inspect UI implementation plan | Figma skills / agents-figma |
| ios launch log analysis | [`apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md) |
| migration/isar vs hive comparison | Hive SoT; [`tradeoffs_and_future.md`](../tradeoffs_and_future.md) |
| migration/shared preferences to isar | Not adopted; Hive path |
| offline_first progress plan | [`adoption_guide.md`](../offline_first/adoption_guide.md) |
| offline_first implementation complete summary | Per-feature offline_first contracts |
| remaining tasks plan (archive stub) | [`compile_time_safety.md`](../compile_time_safety.md) |
| mix design system plan | Mix contract in [`design_system.md`](../design_system.md) |

## Shortened (Tier B)

Contracts only — see the files:

- [`custom_painter_and_render_object.md`](../architecture/custom_painter_and_render_object.md)
- [`todo_list_feature_guide.md`](../features/todo_list_feature_guide.md)
- [`walletconnect_auth_status.md`](../walletconnect_auth_status.md)
- [`staff_app_demo_walkthrough.md`](../staff_app_demo_walkthrough.md)
- [`ide_plugins_guide.md`](../ide_plugins_guide.md)
- [`compute_isolate_review.md`](../performance/compute_isolate_review.md)
- [`code_generation_guide.md`](../code_generation_guide.md)
- [`supabase_proxy_huggingface_chat_plan.md`](../plans/supabase_proxy_huggingface_chat_plan.md)
- [`dio_retrofit_integration_plan.md`](../plans/dio_retrofit_integration_plan.md)
- [`future_architecture_code_quality_improvement_plan.md`](../plans/future_architecture_code_quality_improvement_plan.md)
- [`2026-07-10_maintainability_program.md`](../plans/2026-07-10_maintainability_program.md)
- [`offline_first_flutter_architecture_with_conflict_resolution.md`](../engineering/offline_first_flutter_architecture_with_conflict_resolution.md)

## Proof

```bash
bash tool/check_docs_gardening.sh
bash tool/check_agent_knowledge_base.sh
```
