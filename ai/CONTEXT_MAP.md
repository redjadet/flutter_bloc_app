# Context map — minimal file sets

Load these paths **before** editing a feature. Expand only when tests or DI require it. Full map: [feature_map.md](reports/feature_map.md).

## Pilots (Phase 3 target: ≤8 files each)

### counter

1. `lib/features/counter/counter.dart`
2. `lib/features/counter/domain/` (repository contract)
3. `lib/features/counter/data/hive_counter_repository.dart`
4. `lib/features/counter/presentation/counter_cubit_base.dart`
5. `lib/features/counter/presentation/pages/counter_page.dart`
6. `lib/core/di/register_counter_services.dart` (if exists) or `injector_registrations.dart`
7. `test/features/counter/` (nearest test)
8. `docs/feature_overview.md` (counter row)

### chat

1. `lib/features/chat/chat.dart`
2. `lib/features/chat/domain/` (repository + models)
3. `lib/features/chat/data/` (one primary repository impl)
4. `lib/features/chat/presentation/cubit/chat_cubit.dart` (or list cubit if list-only change)
5. `lib/shared/sync/` (if sync behavior)
6. `docs/offline_first/adoption_guide.md`
7. `docs/ai_integration.md`
8. `test/features/chat/`

### auth

1. `lib/features/auth/auth.dart`
2. `lib/features/auth/domain/auth_repository.dart`
3. `lib/features/auth/data/firebase_auth_repository.dart`
4. `lib/features/auth/presentation/cubit/` (relevant cubit)
5. `lib/core/router/` (auth redirect if needed)
6. `docs/authentication.md`
7. `test/features/auth/`

### settings

1. `lib/features/settings/settings.dart`
2. `lib/features/settings/presentation/` (page + cubits)
3. `lib/core/di/` (settings registration)
4. `DESIGN.md` / `docs/design_system.md` (if UI)
5. `test/features/settings/`

### todo_list

1. `lib/features/todo_list/todo_list.dart`
2. `lib/features/todo_list/domain/`
3. `lib/features/todo_list/data/offline_first_todo_repository_impl.part.dart`
4. `lib/features/todo_list/presentation/pages/todo_list_page_body.dart`
5. `lib/shared/sync/pending_sync_repository.dart`
6. `docs/offline_first/adoption_guide.md`
7. `test/features/todo_list/`

## Global add-ons

| Situation | Also load |
| --- | --- |
| New route | `lib/core/router/app_routes.dart`, owning `lib/app/router/routes_*.dart` |
| DI change | `lib/core/di/injector.dart`, feature `register_*` |
| UI shared widget | `lib/shared/widgets/`, `docs/design_system.md` |
| Architecture refactor | `docs/audits/ai_architecture_audit.md`, Feature Brief |

## Validation

After edits, run narrowest lane from [`docs/agents_quick_reference.md`](../docs/agents_quick_reference.md).
