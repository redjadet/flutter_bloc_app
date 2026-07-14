---
ai_snapshot:
  generated_at: "2026-07-14T15:38:12Z"
  git_head: "a6c2c6d134a5baba099175ac25860b1635d4fc6e"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---




# Context hotspots

Largest non-generated Dart files under `apps/mobile/lib/features/`. Use to scope Phase 4 refactors and agent context budgets. Regenerate with the find command below after large refactors.

| Rank | LOC | File | Feature | Phase 4 candidate |
| ---: | ---: | --- | --- | --- |
| 1 | 159 | `case_study_demo/.../case_study_session_cubit_submit.part.dart` | case_study_demo | done (ARCH-002); monitor submit flow |
| 2 | 336 | `walletconnect_auth/.../walletconnect_auth_page_impl.part.dart` | walletconnect_auth | yes |
| 3 | 322 | `todo_list/.../offline_first_todo_repository_impl.part.dart` | todo_list | maybe — sync-critical |
| 4 | 322 | `example/.../example_page_body_content.part.dart` | example | low — demo hub |
| 5 | 321 | `iot_demo/.../supabase_iot_demo_repository_impl.part.dart` | iot_demo | yes |
| 6 | 319 | `case_study_demo/.../case_study_history_detail_page_impl.part.dart` | case_study_demo | yes |
| 7 | 314 | `online_therapy_demo/.../online_therapy_demo_shell_messaging_call.part.dart` | online_therapy_demo | yes |
| 8 | 307 | `walletconnect_auth/.../walletconnect_auth_repository_impl_body.part.dart` | walletconnect_auth | yes |
| 9 | 307 | `online_therapy_demo/.../online_therapy_fake_api_impl.part.dart` | online_therapy_demo | yes |
| 10 | 298 | `realtime_market/.../realtime_market_page_body.dart` | realtime_market | stub map only |
| 11 | 298 | `igaming_demo/.../game_page.dart` | igaming_demo | stub |
| 12 | 297 | `iot_demo/.../iot_demo_page_body.dart` | iot_demo | yes |
| 13 | 297 | `chart/.../firebase_chart_repository_impl.part.dart` | chart | yes |
| 14 | 296 | `todo_list/.../todo_list_page_body.dart` | todo_list | maybe |
| 15 | 296 | `counter/.../counter_page.dart` | counter | maybe |
| 16 | 296 | `camera_gallery/.../camera_gallery_page.dart` | camera_gallery | stub |
| 17 | 294 | `iot_demo/.../iot_demo_add_device_dialog.dart` | iot_demo | yes |
| 18 | 293 | `graphql_demo/.../supabase_graphql_demo_repository.dart` | graphql_demo | yes |
| 19 | 288 | `online_therapy_demo/.../online_therapy_demo_shell_page.dart` | online_therapy_demo | yes |
| 20 | 282 | `counter/.../counter_page_app_bar.dart` | counter | low |

**Total feature Dart (non-generated):** ~61,848 LOC across `apps/mobile/lib/features/`.

**Regenerate:**

```bash
find apps/mobile/lib/features -name '*.dart' ! -name '*.freezed.dart' ! -name '*.g.dart' \
  -exec wc -l {} + | sort -nr | head -25
```
