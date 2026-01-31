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

## Common Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Update coverage summary
dart run tool/update_coverage_summary.dart

# Use automated coverage script
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

## Related Documentation

- Test utilities and helpers: `test/test_helpers.dart`
- Common bugs prevention: `test/shared/common_bugs_prevention_test.dart`
- Coverage report: `coverage/coverage_summary.md`
- Developer guide: `docs/new_developer_guide.md`
