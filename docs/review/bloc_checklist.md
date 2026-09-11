# BLoC Review Checklist

Use with [BLoC Standards](../bloc_standards.md) for Cursor/Codex reviews.

## Ownership

- Cubit/Bloc owns flow state, validation orchestration, and request freshness.
- Widgets render state and invoke callbacks only.
- Data/repositories own DTO parsing, storage, network, and offline sync.
- Navigation, dialogs, snackbars, and one-shot UI effects live in listeners or
  route/presentation seams.

## State Model

- State is immutable and preferably Freezed.
- Choose simple status record vs sealed union using
  [`bloc_standards.md`](../bloc_standards.md) § State Shape: demand a sealed
  union when a single record can still express invalid combinations (different
  required fields / mutually exclusive payloads). Do not require sealed unions
  for taste alone. Copy-from:
  [`bloc/cubit_file_template.md`](../bloc/cubit_file_template.md);
  spine: [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md)
  § P4.
- Loading, success, error, empty, retry, offline, and pending states are explicit
  when visible to users.
- State exposes domain models or view data, not data DTOs.
- Derived getters remove duplicated UI branching.
- Useful failures: typed domain failure or `AppError` → visible state → l10n in
  presentation; no `Object?` or raw `e.toString()` in state (P6).

## Async And Lifecycle

- Async calls use existing exception handling patterns.
- No emit after `close()`.
- Stale request completions cannot overwrite newer state.
- After a successful mutation, inactive `RequestIdGuard` must not yield
  `false` / failure—return success (`true` or bare `return`). See
  `tool/check_mutation_success_after_guard.sh` and therapy demo cubits.
- Streams/timers/controllers/listeners are disposed in `close()`.
- `Future.delayed` and raw `Timer` are replaced with repo timer abstractions
  when cancellation or test control matters.
- Lifecycle ownership: [`../performance/memory_checklist.md`](../performance/memory_checklist.md).

## UI Access

- Type-safe BLoC helpers are used where available.
- Selectors are used for narrow rebuilds and expensive widgets.
- Builders stay pure; no side effects in `build()`.
- Modal sheets/dialogs that need a Cubit wrap `BlocProvider.value` (overlay
  routes drop page providers). Guard: `tool/check_modal_bloc_provider.sh`.
- Widget tests do not rely on unbounded `pumpAndSettle()` for heavy async UI.

## Tests

- Cubit/Bloc tests cover initial, success, error, retry, and stale async paths
  relevant to the change.
- Widget tests cover visible state contracts from the feature brief.
- Time-dependent logic uses `FakeTimerService`.
- Data mapper/failure tests stay in data-layer tests, not widget tests.

## Proof

Run focused `flutter test <paths>` plus `./tool/analyze.sh` for BLoC-only
changes. Use `./bin/router_feature_validate` when routes/auth gates are touched,
and `./bin/checklist` when lifecycle, DI, offline-first, or shared code changes.
