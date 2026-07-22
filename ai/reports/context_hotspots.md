---
ai_snapshot:
  generated_at: "2026-07-22T21:07:00Z"
  git_head: "4946d984b89f9328ba2cd3e93fb6eefec21fa061"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---

# Context hotspots

Largest non-generated Dart files under `apps/mobile/lib/features/`. Use to scope refactors and agent context budgets. The ranking is generated; any refactor decision remains human-reviewed.

<!-- refresh_ai_reports:hotspots:start -->
| Rank | LOC | File | Feature |
| ---: | ---: | --- | --- |
| 1 | 483 | `walletconnect_auth/presentation/pages/walletconnect_auth_page_impl.part.dart` | walletconnect_auth |
| 2 | 398 | `ai_decision_demo/presentation/pages/ai_decision_demo_page.part.dart` | ai_decision_demo |
| 3 | 364 | `online_therapy_demo/presentation/pages/online_therapy_demo_shell_messaging_call.part.dart` | online_therapy_demo |
| 4 | 364 | `camera_gallery/presentation/pages/camera_gallery_page.part.dart` | camera_gallery |
| 5 | 358 | `todo_list/data/offline_first_todo_repository_impl.part.dart` | todo_list |
| 6 | 352 | `example/presentation/widgets/example_page_body_content.part.dart` | example |
| 7 | 321 | `iot_demo/data/supabase_iot_demo_repository_impl.part.dart` | iot_demo |
| 8 | 320 | `igaming_demo/presentation/pages/game_page_sections.part.dart` | igaming_demo |
| 9 | 308 | `online_therapy_demo/data/fake/online_therapy_fake_api_impl.part.dart` | online_therapy_demo |
| 10 | 307 | `walletconnect_auth/data/walletconnect_auth_repository_impl_body.part.dart` | walletconnect_auth |
| 11 | 297 | `chart/data/firebase_chart_repository_impl.part.dart` | chart |
| 12 | 286 | `in_app_purchase_demo/presentation/pages/in_app_purchase_demo_page_cards.part.dart` | in_app_purchase_demo |
| 13 | 244 | `counter/presentation/widgets/counter_page_app_bar_overflow.part.dart` | counter |
| 14 | 241 | `staff_app_demo/presentation/pages/staff_app_demo_proof_page_widgets.part.dart` | staff_app_demo |
| 15 | 225 | `graphql_demo/data/countries_graphql_repository_queries.part.dart` | graphql_demo |
| 16 | 224 | `todo_list/presentation/cubit/todo_list_cubit.dart` | todo_list |
| 17 | 223 | `online_therapy_demo/presentation/cubit/messaging_cubit.dart` | online_therapy_demo |
| 18 | 223 | `library_demo/presentation/widgets/library_demo_body.dart` | library_demo |
| 19 | 223 | `camera_gallery/data/image_picker_camera_gallery_repository.dart` | camera_gallery |
| 20 | 222 | `counter/data/offline_first_counter_repository.dart` | counter |

**Total feature Dart (non-generated):** ~76169 LOC across `apps/mobile/lib/features`.
<!-- refresh_ai_reports:hotspots:end -->

**Regenerate:**

```bash
bash tool/refresh_ai_reports.sh
```
