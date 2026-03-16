# Anchor features

- Anchor A: `settings` (path: `lib/features/settings/`)
- Anchor B: `todo_list` (path: `lib/features/todo_list/`)

## settings — architecture map

- Entry page: `lib/features/settings/presentation/pages/settings_page.dart`
- State class(es):
  - `ThemeCubit` (`lib/features/settings/presentation/cubits/theme_cubit.dart`)
  - `LocaleCubit` (`lib/features/settings/presentation/cubits/locale_cubit.dart`)
  - `AppInfoCubit` (`lib/features/settings/presentation/cubits/app_info_cubit.dart`)
- Use cases/services: `AppInfoRepository`, `ThemeRepository`, `LocaleRepository`
- Repositories: implemented in `lib/features/settings/data/**` (Hive/SharedPreferences/package_info based)
- Data sources/clients: local storage (Hive, SharedPreferences), package info APIs
- DI registrations: _TBD (list concrete `core/di/...` files/lines)_

## settings — state & UI

- Cubits/Blocs:
  - `ThemeCubit` (state: `ThemeMode`)
  - `LocaleCubit` (state: `Locale?`)
  - `AppInfoCubit` (state: `AppInfoState` with `ViewStatus`, `AppInfo?`, `errorMessage`)
- BLoC access patterns:
  - `SettingsPage` owns an `AppInfoCubit` instance and exposes it via `BlocProvider.value`
  - Other settings sections likely consume cubits via `BlocBuilder`/`context` extensions (details TBD)

## settings — tests & scripts

- Unit tests: _TBD_
- Widget tests: _TBD_
- Integration tests:
  - `integration_test/settings_flow_test.dart` (opens settings, changes theme + locale)
  - `registerSettingsIntegrationFlow` and `registerSettingsThemePersistenceIntegrationFlow` in `integration_test/flow_scenarios_secondary.dart`
- Standard scripts: `./bin/checklist` (if present), `dart analyze`, `flutter test`

---

## todo_list — architecture map

- Entry page: `lib/features/todo_list/presentation/pages/todo_list_page.dart`
- State class(es):
  - `TodoListState` (`lib/features/todo_list/presentation/cubit/todo_list_state.dart`)
- Use cases/services: `TodoRepository` (contract in `lib/features/todo_list/domain/todo_repository.dart`)
- Repositories: implementations in `lib/features/todo_list/data/**` (Hive/Realtime/offline-first repositories)
- Data sources/clients: Hive, realtime database/client wrappers (see `data/` implementations)
- DI registrations: _TBD (list concrete `core/di/...` files/lines)_

## todo_list — state & UI

- Cubits/Blocs:
  - `TodoListCubit` (`lib/features/todo_list/presentation/cubit/todo_list_cubit.dart`) with mixins for CRUD, helpers, logging
  - State: `TodoListState` (fields: `status`, `items`, `filter`, `searchQuery`, `sortOrder`, `manualOrder`, `selectedItemIds`, `errorMessage`)
- BLoC access patterns:
  - `TodoListPage` uses `TypeSafeBlocSelector<TodoListCubit, TodoListState, _TodoAppBarData>` to derive app bar state
  - Body/content widgets access cubit/state via type-safe extensions and shared selectors (details in `todo_list_page_body.dart` and helpers)

## todo_list — tests & scripts

- Unit tests: _TBD_ (add coverage around `TodoListCubit` and `TodoListState.filteredItems/_applySorting`)
- Widget tests: _TBD_ (main list page/state rendering)
- Integration tests:
  - `integration_test/todo_list_flow_test.dart` (opens todo list, adds todo and verifies it appears)
  - `registerTodoListIntegrationFlow` and `registerTodoListFilterIntegrationFlow` in `integration_test/flow_scenarios_secondary.dart`
- Standard scripts: `./bin/checklist` (if present), `dart analyze`, `flutter test`
