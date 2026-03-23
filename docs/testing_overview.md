# Testing Overview

This document summarizes test coverage, test types, testing patterns, and common commands.

## Coverage

- **Current Coverage**: Tracked in `coverage/coverage_summary.md`
- **Target**: 85%+ baseline
- **Exclusions**: Mocks, simple data classes, configs, debug utils, platform widgets, and part files

## Test Types

### Unit Tests

- Isolated function and class testing
- Pure logic, repositories, utilities
- No Flutter dependencies

### Bloc Tests

- State flow testing with `bloc_test` package
- State machine behavior verification
- Fast execution without widget pumps

### Widget Tests

- UI component and interaction testing
- Rendering and user interaction verification
- Platform-adaptive component testing

### Golden Tests

- Visual regression testing
- Deterministic layout verification
- Use `golden_toolkit` for consistent results

### Integration Tests

- End-to-end app flow verification under `integration_test/`
- Runs on a supported non-web device via `./bin/integration_tests` or `tool/run_integration_tests.sh`
- Use `CHECKLIST_INTEGRATION_DEVICE=<deviceId>` when multiple devices are attached
- On macOS, the script now prefers an iPhone simulator, attempts to boot a preferred iPhone simulator if Flutter has not listed one yet, and refuses to fall back to the `macos` desktop target unless `ALLOW_DESKTOP_INTEGRATION_DEVICE=1` is set explicitly
- `integration_test/pr_smoke_flows_test.dart` covers the smaller GitHub PR smoke suite; `integration_test/smoke_flows_test.dart` keeps a broader local smoke pass available without requiring the full suite
- `integration_test/extended_flows_test.dart` keeps heavier persistence, refresh, and filter scenarios available without blocking every PR run
- Running the full suite via `./bin/integration_tests` still targets `integration_test/all_flows_test.dart` and refreshes `coverage/coverage_summary.md`; when `coverage/lcov.base.info` exists, integration coverage is merged into that baseline first
- Use `INTEGRATION_TESTS_RUN_COVERAGE=0` or `INTEGRATION_TESTS_RUN_COVERAGE=false` to skip integration coverage collection and summary refresh when you only need flow validation (for example, CI simulator jobs)
- **Files**: `app_test.dart` (launch and counter), `counter_persistence_test.dart` (persisted count after restart), `settings_flow_test.dart` (settings, theme, locale), `navigation_flow_test.dart` (counter to example to library demo), `calculator_flow_test.dart` (calculator from home), `graphql_demo_flow_test.dart` (GraphQL demo from overflow menu), `todo_list_flow_test.dart` (todo list add and list), `chat_list_flow_test.dart` (chat list from example), `search_flow_test.dart` (search from example), `websocket_flow_test.dart` (WebSocket from example), `iot_demo_flow_test.dart` (IoT demo from overflow), `charts_flow_test.dart` (charts from overflow), `whiteboard_flow_test.dart` (whiteboard from overflow), `markdown_editor_flow_test.dart` (markdown editor from overflow), `genui_demo_flow_test.dart` (GenUI demo from overflow), `playlearn_flow_test.dart` (playlearn from overflow), `igaming_demo_flow_test.dart` (iGaming demo from overflow)

### Common Bugs Prevention Tests

- Regression tests for common pitfalls
- Located in `test/shared/common_bugs_prevention_test.dart`
- Covers context lifecycle, cubit disposal, stream cleanup, completer safety
- Automatically included in `./bin/checklist` test runs

## Testing Patterns

### Timer-Dependent Tests

- Inject `FakeTimerService` instead of using real timers
- Advance time with `tick(n)` for deterministic testing
- Example: Counter auto-decrement timer tests

### Network Image Tests

- Use `pump()` instead of `pumpAndSettle()` with `CachedNetworkImageWidget`
- Network requests never complete in test environments
- Use `await tester.pump()` followed by `await tester.pump(const Duration(milliseconds: 100))` if needed

### Hive Repository Tests

- Use temp directory in `setUpAll`
- Initialize `HiveService` with `HiveKeyManager` and `InMemorySecretStorage`
- Run `SharedPreferencesMigrationService.migrateIfNeeded()` before tests

### Mock/Fake Services

- `MockFirebaseAuth` + `mock_exceptions` for authentication flows
- `FakeTimerService().tick(n)` for time-dependent tests
- `FakeNetworkStatusService` for connectivity testing

### Firestore-Backed Repository Tests

- Mock `FirebaseFirestore`, `CollectionReference`, and `DocumentReference` (or use fakes) to verify writes and reads without hitting Firestore.
- Record `set()` / `get()` arguments to assert document IDs and payloads (e.g. auth linkage doc vs wallet profile doc).
- Example: `test/features/walletconnect_auth/data/walletconnect_auth_repository_impl_test.dart`.

### Offline-first / Supabase-backed feature tests

- **GraphQL demo:** cache (`graphql_demo_cache_repository_test.dart`), offline-first coordinator (`offline_first_graphql_demo_repository_test.dart`), auth-aware remote (`auth_aware_graphql_remote_repository_test.dart`), data source badge (`graphql_data_source_badge_test.dart`).
- **Chart demo:** cache (`chart_demo_cache_repository_test.dart`), offline-first coordinator (`offline_first_chart_repository_test.dart`), auth-aware remote (`auth_aware_chart_remote_repository_test.dart`), data source badge (`chart_data_source_badge_test.dart`).

## Common Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
./bin/integration_tests

# Run PR smoke flows only
./bin/integration_tests integration_test/pr_smoke_flows_test.dart

# Run broader local smoke flows
./bin/integration_tests integration_test/smoke_flows_test.dart

# Run extended/heavier flows only
./bin/integration_tests integration_test/extended_flows_test.dart

# Run integration tests directly
tool/run_integration_tests.sh

# Update coverage summary manually
dart run tool/update_coverage_summary.dart

# Use automated unit/widget/bloc coverage script
tool/test_coverage.sh

# Regenerate golden files (after Flutter upgrades)
flutter test --update-goldens

# Run specific test file
flutter test test/features/counter/presentation/counter_cubit_test.dart
```

## Golden Test Regeneration

After Flutter version updates, golden tests may fail due to minor rendering changes. Regenerate golden files:

```bash
# Regenerate all golden files
flutter test --update-goldens

# Regenerate specific golden test file
flutter test --update-goldens test/counter_page_golden_test.dart
```

**Note**: Always review the generated golden images to ensure they match expected visual changes before committing.

On pull requests, GitHub Actions skips the macOS integration job entirely when no relevant runtime files changed. Golden widget tests are skipped in GitHub Actions CI. If the macOS job runs but no suitable iPhone simulator is available, boot fails, or boot times out, the integration step is skipped instead of failing CI.

## Related Documentation

- Test utilities and helpers: `test/test_helpers.dart`
- Common bugs prevention: `test/shared/common_bugs_prevention_test.dart`
- Coverage report: `coverage/coverage_summary.md`
- Developer guide: `docs/new_developer_guide.md`
