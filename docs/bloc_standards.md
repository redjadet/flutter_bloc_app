# BLoC Standards

Canonical state-management rules for Cursor and Codex agents building or
reviewing feature code. **Cubit/BLoC is presentation-layer state management
only** — under `lib/features/*/presentation/cubit/` or app-scope presentation
(`AppScope`); never in `domain/` or `data/`. This complements [Clean Architecture](clean_architecture.md),
[Feature Structure Contract](architecture/feature_structure_contract.md), and
[State Management Choice](state_management_choice.md).

## Decision Rules

| Need | Use |
| --- | --- |
| Commands directly call methods and no event queue policy is needed | `Cubit` |
| Event ordering, throttling, debouncing, retries, or multiple event sources are central | `Bloc` |
| App-wide cross-cutting state such as theme, locale, sync, or remote config | App-scope `Cubit`/`Bloc` in `AppScope` |
| Feature screen or flow state | Route-scoped `Cubit`/`Bloc` |
| UI-only ephemeral toggles | Local widget state, if no business rule or shared state is involved |

Default to `Cubit` in this repo unless a row above proves `Bloc` is the better
fit. Do not introduce Riverpod, Provider, or ad hoc service-locator state for
new feature state.

## State Shape

- New state/domain models use Freezed unless an owning doc explicitly allows
  otherwise.
- Prefer one immutable state object with `status`, data, and error fields for
  simple flows.
- Use Freezed unions for workflows with materially different states, such as
  idle/loading/loaded/error with different required fields.
- Keep derived booleans/getters on the state model when they remove repeated UI
  branching.
- State fields expose domain models or presentation view data, not data-layer
  DTOs.
- Loading, empty, success, error, retry, and offline/pending states must be
  explicit when the UI can show them.

## Cubit And Bloc Responsibilities

- Depend on domain/core contracts, not data implementations.
- Own user-flow rules, validation orchestration, request freshness, and state
  transitions.
- Use `CubitExceptionHandler` for async work where it matches the existing
  pattern.
- Guard stale async completions and emissions with `isClosed` or request-id /
  `isAlive` checks.
- Cancel streams, timers, controllers, and lifecycle observers in `close()`.
- Keep navigation policy in presentation/router surfaces; reusable widgets
  receive callbacks or view data.
- Keep storage, SDK calls, HTTP, DTO parsing, and offline sync queue logic in
  data/shared infrastructure.

## Naming

| Type | Pattern |
| --- | --- |
| Cubit | `<Feature><Flow>Cubit` |
| Bloc | `<Feature><Flow>Bloc` |
| State | `<Feature><Flow>State` |
| Event | Verb phrase past command intent, e.g. `FetchRequested`, `RetryTapped` |
| Status enum | `<Feature><Flow>Status` with `initial/loading/success/error` where simple |
| View data | `<Widget>ViewData` or private `_...Data` near the widget |

Cubit methods should be imperative verbs (`loadInitial`, `refresh`, `submit`,
`clearCache`). Avoid vague verbs such as `handle`, `process`, or `doAction`
unless the domain concept uses that term.

## UI Access

- Use repo type-safe helpers (`context.cubit<T>()`, `TypeSafeBlocBuilder`,
  `TypeSafeBlocSelector`, `TypeSafeBlocConsumer`) where available.
- Prefer selectors for small UI slices and expensive widgets.
- Use listeners for one-time side effects such as snackbars, dialogs, and
  navigation.
- Widgets render state and invoke callbacks; they do not call repositories,
  SDKs, or storage directly.

## Tests

- New transitions need cubit/bloc tests with initial, success, error, and stale
  async cases when relevant.
- Widget tests cover visible loading, empty, success, error, and retry states for
  P0/P1 surfaces.
- Repository/mapper tests prove DTO-to-domain mapping and failure mapping in the
  data layer.
- Use `FakeTimerService` and bounded pumps for timer/async behavior.

## Review Checklist

- Cubit/Bloc depends only on domain/core contracts.
- State is immutable and complete enough for all visible UI states.
- Async work cannot emit after close or after a newer request wins.
- Side effects are in listeners/router/presentation seams, not `build()`.
- Widgets use type-safe access/selectors and do not construct repositories.
- Tests cover state transitions and visible states named in the feature brief.

## Validation

Run the narrowest proof from
[Validation Routing](engineering/validation_routing_fast_vs_full.md). For
BLoC-heavy changes, usually run focused `flutter test <paths>` plus
`./tool/analyze.sh`; escalate to `./bin/checklist` for shared lifecycle,
offline-first, routing, or DI changes.
