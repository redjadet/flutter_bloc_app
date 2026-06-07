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
- Loading, success, error, empty, retry, offline, and pending states are explicit
  when visible to users.
- State exposes domain models or view data, not data DTOs.
- Derived getters remove duplicated UI branching.
- Error state uses existing localized/domain error patterns.

## Async And Lifecycle

- Async calls use existing exception handling patterns.
- No emit after `close()`.
- Stale request completions cannot overwrite newer state.
- Streams/timers/controllers/listeners are disposed in `close()`.
- `Future.delayed` and raw `Timer` are replaced with repo timer abstractions
  when cancellation or test control matters.

## UI Access

- Type-safe BLoC helpers are used where available.
- Selectors are used for narrow rebuilds and expensive widgets.
- Builders stay pure; no side effects in `build()`.
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
