---
ai_snapshot:
  generated_at: "2026-07-17T19:17:24Z"
  git_head: "8cdadd5d5bad3f9b3d78fe1c4f9133b9cc45524b"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---

# Context map — minimal file sets

Load these paths **before** editing a feature. Expand only when tests or DI require it. Full map: [feature_map.md](reports/feature_map.md).

## Pilots (Phase 3 target: ≤8 files each)

### counter

1. `apps/mobile/lib/features/counter/counter.dart`
2. `apps/mobile/lib/features/counter/domain/` (repository contract)
3. `apps/mobile/lib/features/counter/data/hive_counter_repository.dart`
4. `apps/mobile/lib/features/counter/presentation/cubit/counter_cubit_base.dart`
5. `apps/mobile/lib/features/counter/presentation/pages/counter_page.dart`
6. `apps/mobile/lib/app/composition/features/` (feature registrar) or `apps/mobile/lib/app/composition/injector_registrations.dart`
7. `apps/mobile/test/features/counter/` (nearest test)
8. `docs/feature_overview.md` (counter row)

### chat

1. `apps/mobile/lib/features/chat/chat.dart`
2. `apps/mobile/lib/features/chat/domain/` (repository + models)
3. `apps/mobile/lib/features/chat/data/` (one primary repository impl)
4. `apps/mobile/lib/features/chat/presentation/cubit/chat_cubit.dart` (or list cubit if list-only change)
5. `apps/mobile/lib/app/sync/` and/or `packages/storage/` (if sync behavior)
6. `docs/offline_first/adoption_guide.md`
7. `docs/integrations/ai_integration.md`
8. `apps/mobile/test/features/chat/`

### auth

1. `apps/mobile/lib/features/auth/auth.dart`
2. `apps/mobile/lib/features/auth/domain/auth_repository.dart`
3. `apps/mobile/lib/features/auth/data/firebase_auth_repository.dart`
4. `apps/mobile/lib/features/auth/presentation/cubit/` (relevant cubit)
5. `apps/mobile/lib/app/router/` (auth redirect if needed)
6. `docs/authentication.md`
7. `apps/mobile/test/features/auth/`

### settings

1. `apps/mobile/lib/features/settings/settings.dart`
2. `apps/mobile/lib/features/settings/presentation/` (page + cubits)
3. `apps/mobile/lib/app/composition/` (settings registration)
4. [`DESIGN.md`](../DESIGN.md) / [`docs/design_system.md`](../docs/design_system.md) (if UI)
5. `apps/mobile/test/features/settings/`

### todo_list

1. `apps/mobile/lib/features/todo_list/todo_list.dart`
2. `apps/mobile/lib/features/todo_list/domain/`
3. `apps/mobile/lib/features/todo_list/data/offline_first_todo_repository_impl.part.dart`
4. `apps/mobile/lib/features/todo_list/presentation/pages/todo_list_page_body.dart`
5. `apps/mobile/lib/app/sync/` (pending sync infrastructure)
6. `docs/offline_first/adoption_guide.md`
7. `apps/mobile/test/features/todo_list/`

## Global add-ons

| Situation | Also load |
| --- | --- |
| New route | `apps/mobile/lib/app/router/app_routes.dart`, owning `apps/mobile/lib/app/router/routes_*.dart` |
| DI change | `apps/mobile/lib/app/composition/injector.dart`, `apps/mobile/lib/app/composition/features/register_*` |
| UI shared widget | `packages/design_system/`, `docs/design_system.md` |
| Architecture refactor | [`architecture_review_2026-06.md`](../docs/audits/architecture_review_2026-06.md), Feature Brief |

## Validation

After edits, run narrowest lane from [`docs/agents_quick_reference.md`](../docs/agents_quick_reference.md).
