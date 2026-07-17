# DI composition simplify (Wave A) — 2026-07-17

## Scope

Behavior-preserving DI maintainability refactor:

1. Extracted 12 inline group registrations into dedicated
   `register_*_services.dart` modules under `app/composition/features/`.
2. Moved auth guest/unavailable repositories into
   `features/auth/data/guest_auth_fallback_repositories.dart`.
3. Moved staff offline fallback repositories into
   `features/staff_app_demo/data/fallback_staff_demo_repositories.dart`.
4. Moved `FakeRemoteConfigRemoteDataSource` into
   `features/remote_config/data/fake_remote_config_remote_data_source.dart`.

## Preserved contracts

- Registration call order in feature/demo groups unchanged.
- Lazy-singleton lifetimes and dispose callbacks unchanged.
- Auth Firebase / web-local-guest / macOS / iOS-simulator selection remains in
  `register_auth_services.dart`.
- Staff Firestore availability helpers remain private composition policy.
- Remote-config factory selection remains in `injector_factories.dart`.

## Validation evidence

- `./bin/format --changed`
- Focused: `flutter test` composition auth/demo/remaining/factories (**30 passed**)
- `bash tool/check_clean_architecture_imports.sh` — pass
- `bash tool/check_feature_folder_contract.sh` — pass
- `bash tool/check_feature_modularity_leaks.sh` — pass
- `./tool/analyze.sh` — pass
- `./bin/router_feature_validate` — pass (168 tests)
- `./bin/checklist` — **passed** (2750 tests; coverage 85.23%; app-shell 75.73%)
- `./bin/agent-maintain closeout` — pass

## Intentionally deferred after this series

Wave C presentation splits and staff clock-out partial `flags` wire shape:
[`../plans/2026-07-17_maintainability_simplify_deferred.md`](../plans/2026-07-17_maintainability_simplify_deferred.md).
