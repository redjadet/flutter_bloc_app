# Validation Scripts Documentation

Catalog of validation scripts in `tool/`. Run scripts directly for targeted
proof, `./bin/checklist` for full sweep, and `./bin/checklist-fast` only for
clean-tree or narrow docs/tooling sanity.

For complete docs index, see [docs index](README.md).

## Overview

Scripts guard architecture, UI/UX, async, perf, and memory hygiene. Prefer
targeted scripts for local changes; use `./bin/checklist` for broad/pre-ship
validation.

Checklist includes guards:

- **Architecture compliance** - Ensures clean architecture boundaries and dependency injection patterns
- **UI/UX best practices** - Enforces platform-adaptive widgets, proper image caching, and responsive design
- **Async safety** - Detects missing lifecycle guards and context usage after async operations
- **Performance** - Flags performance anti-patterns like unnecessary rebuilds and missing repaint boundaries
- **Dynamic list safety** - Prevents builder callbacks from indexing live Cubit/BLoC state lists after async shrink/rebuild races
- **Memory hygiene** - Prevents leaks and ensures proper cleanup of resources

Full documentation and suppression guidance is provided in sections below.

## CI (GitHub Actions)

On pushes and pull requests, [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs **`./bin/checklist`** on `ubuntu-latest` (same delivery pipeline as local pre-merge validation). Golden widget tests are skipped in GitHub Actions CI.

**Integration tests not run on push/PR.** Run only via manual workflow (**Actions → CI → Run workflow**) with **`run_integration`** on (default off). macOS job tries preferred iPhone simulator; if none/boot fail/boot timeout, integration step skips (no job fail).

For broader local or pre-ship validation, `./bin/integration_tests` still runs aggregated suite in `integration_test/all_flows_test.dart`.

## Existing Validation Scripts

### Architecture & Dependency Injection

- **`check_flutter_domain_imports.sh`**: Ensures domain layer is Flutter-agnostic (no `package:flutter` imports)
- **`check_direct_getit.sh`**: Prevents direct `GetIt` access in presentation widgets (should inject via constructors/cubits)
- **`check_no_hive_openbox.sh`**: Prevents direct `Hive.openBox` usage (should use `HiveService`/`HiveRepositoryBase`)
- **`check_unvalidated_base_url_parse.sh`**: Prevents `Uri.parse(...)` directly on dynamic `baseUrl`-like values without validation helper
- **`check_auth_refresh_single_flight.sh`**: Detects auth retry anti-patterns that can cause 401 refresh races (e.g. `refreshToken()` followed by retry `forceRefresh: true`) and ensures serialized refresh gate exists in `AuthTokenManager`
- **`check_solid_presentation_data_imports.sh`**: Prevents presentation importing data-layer types (DIP)
- **`check_solid_data_presentation_imports.sh`**: Prevents data layer importing presentation (layering)
- **`check_feature_modularity_leaks.sh`**: Fails on known cross-feature `package:` imports: `library_demo` must not import `scapes`; `settings` must not import `graphql_demo`, `profile`, or `remote_config`; **`remote_config` must not import `settings`** (use `shared` widgets like `SettingsSection` instead). Extend script when new boundary rules land in [modularity.md](modularity.md). Included in `./bin/checklist`.
- **`check_macos_debug_web_guard.sh`**: Ensures macOS debug-only fallbacks that check `defaultTargetPlatform == TargetPlatform.macOS` also include `!kIsWeb`, so Safari/Chrome on macOS do not inherit desktop-only debug behavior.
- **`check_agent_knowledge_base.sh`**: Keeps AI-agent map/source-doc/host-template pointers indexed; fails if [`AGENTS.md`](../AGENTS.md) grows past limit or required progressive-disclosure, memory-compounding, or closed-loop invariants disappear.
- **`check_agent_memory_compounding.sh`**: Safe deterministic guard for memory-compounding automation; ensures reusable conclusions route to durable repo memory, source/host-template pointers stay aligned, and autonomous cron/action guidance still requires explicit user approval.
- **`check_docs_gardening.sh`**: Cheap doc-rot check for agent-facing markdown; verifies backticked `*.md` references best-effort and keeps [`validation_scripts.md`](validation_scripts.md) aligned with `tool/delivery_checklist.sh`.
- **`validate_task_trackers.sh`**: Validates `tasks/*/todo.md` tracker contract: required headings, non-empty write set, validation command.
- **`run_harness_fixtures.sh`**: Smoke tests harness scripts and negative-case fixtures; runs in `./bin/checklist-fast` and docs/tooling lanes.
- **`check_ai_generated_code_smells.sh`**: High-signal AI-code smell scan: secret-looking literals, swallowed exceptions, obvious SQL string interpolation, and risky Supabase Edge `verify_jwt = false`. Uses `check-ignore: <reason>` allowlist and fixtures under `tool/fixtures/ai_generated_code_smells/`.
  - **Limitation (intentional)**: `verify_jwt = false` is enforced via TOML section parsing only (`[functions.<name>]`). It does not detect equivalent behavior in deploy flags/scripts/docs/MCP payloads unless those surfaces are added explicitly.

### UI/UX Best Practices

- **`check_material_buttons.sh`**: Prevents raw Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`) - should use `PlatformAdaptive.*` helpers
- **`check_raw_dialogs.sh`**: Prevents raw dialog APIs - should use `showAdaptiveDialog()`
- **`check_raw_network_images.sh`**: Prevents raw `Image.network` usage - should use `CachedNetworkImageWidget`
- **`check_raw_print.sh`**: Prevents raw `print()`/`debugPrint()` usage - use
  `AppLogger` and [`logging.md`](logging.md) conventions instead.
- **`check_raw_google_fonts.sh`**: Prevents per-widget `GoogleFonts.*` usage - should define fonts in `app_config.dart`

### Performance

- **`check_perf_shrinkwrap_lists.sh`**: Flags `shrinkWrap: true` lists/grids in presentation code
- **`check_perf_nonbuilder_lists.sh`**: Flags likely dynamic `ListView`/`GridView` `children:` construction that eagerly builds rows. Small static/prebuilt section lists may use `children:` when that preserves stable widget identity.
- **`check_widget_identity.sh`**: Flags common widget identity traps (missing stable `key:` in builder row returns, builder-by-index over prebuilt widget lists, `AnimatedSwitcher` children without explicit keyed identity, and dynamic `children:` lists that instantiate local `TextEditingController`/`FocusNode` owner widgets without keys). Prefer stable domain IDs via `ValueKey('row-$id')`; use `ListView(children: ...)` for static prebuilt widget lists. Suppress only with `// widget_identity:ignore <reason>` on the same or previous line.
- **`check_perf_missing_repaint_boundary.sh`**: Warns when heavy widgets lack `RepaintBoundary`
- **`check_perf_unnecessary_rebuilds.sh`**: Heuristic check for `setState()` calls that might cause unnecessary rebuilds/blinking (warns but doesn't fail)
- **`check_concurrent_modification.sh`**: Detects potential concurrent modification errors when iterating over collections from getters/properties
- **`check_live_state_list_indexing.sh`**: Prevents presentation builders from indexing live `state.items[index]`/`state.items.elementAt(index)` directly. Snapshot state list into local immutable list, use that snapshot for `itemCount`, and guard stale indexes before indexing.

### Compute/Isolate Usage

- **`check_raw_json_decode.sh`**: Prevents raw `jsonDecode()`/`jsonEncode()` usage - should use `decodeJsonMap()`/`decodeJsonList()`/`encodeJsonIsolate()` for large payloads (>8KB)
- **`check_compute_domain_layer.sh`**: Prevents `compute()` usage in domain layer (domain should be Flutter-agnostic)
- **`check_compute_lifecycle.sh`**: Heuristic check for `compute()` usage in lifecycle methods (`build()`, `performLayout()`) - warns but doesn't fail
- **`check_no_isolate_run_in_presentation.sh`**: Prevents `Isolate.run` under `lib/**/presentation/**`. Closures from `State`/widgets often capture non-sendable Flutter objects and crash with *illegal argument in isolate message*; use `compute(topLevelOrStaticCallback, message)` from `package:flutter/foundation.dart` instead (see `lib/shared/utils/isolate_json.dart`). Suppress with `check-ignore` on same or previous line only for rare, reviewed cases.

### Timing & Services

- **`check_raw_timer.sh`**: Prevents raw `Timer` usage - should use `TimerService` for testability
- **`check_raw_future_delayed.sh`**: Flags `Future.delayed` in production `lib/` - prefer `TimerService.runOnce` where cancellation or test control matters (see [`engineering/delayed_work_guide.md`](engineering/delayed_work_guide.md))

### Widget Lifecycle

- **`check_side_effects_build.sh`**: Heuristic check for side effects in `build()` method (warns but doesn't fail)
- **`check_dialog_controller_dispose.sh`**: Heuristic check for `TextEditingController` with `showDialog`/`showAdaptiveDialog` and dispose in `finally` (can cause "used after being disposed")
- **`check_dialog_text_controller_lifecycle.sh`**: Flags `final`/`var` locals assigned `TextEditingController(` inside `async` blocks when same file uses dialog APIs (prefer Stateful dialog + `initState`/`dispose`)
- **`check_memory_pressure_centralized.sh`**: Ensures `didHaveMemoryPressure()` handling stays centralized in `lib/app/app_scope.dart` so automatic memory trimming is coordinated through app shell
- **`check_pyright_python.sh`**: Runs **Pyright** via `npx pyright` on `demos/render_chat_api` and repo `tool/` Python. Bootstraps `demos/render_chat_api/.venv` from `requirements.txt` when missing (so CI and fresh clones stay reproducible). Fails if `pyrightconfig.json` nests `venvPath` / `venv` under `executionEnvironments` (invalid; use top-level keys). Keep repo-root `exclude` including `**/.venv` so site-packages are not type-checked. Standalone runs always execute; inside `./bin/checklist`, script auto-skips on local non-Python change sets, but still runs in CI or when Python-related files changed. See [`demos/render_chat_api/README.md`](../demos/render_chat_api/README.md) for editor setup.
- **`check_inherited_widget_in_create.sh`**: Prevents `context.l10n`/`Theme.of(context)` inside BlocProvider/Provider `create` (see Context & Async Safety below)
- **`check_inherited_widget_in_initstate.sh`**: Prevents InheritedWidget reads (e.g. `context.l10n`, `Theme.of(context)`) in `initState()`; read in `build()` or `didChangeDependencies()` instead.
- **`check_lifecycle_error_handling.sh`**: Snackbar via ErrorHandling, `stream.listen` onError, `context.mounted` after show\*Dialog (see Context & Async Safety below)
- **`check_offline_first_remote_merge.sh`**: Regression tests ensuring offline-first repos don't overwrite newer unsynced local state with older remote (see Offline-first remote merge below). Standalone runs always execute; inside `./bin/checklist`, script auto-skips on local change sets that don't touch offline-first surfaces, but still runs in CI or when relevant files changed.

## New Validation Scripts (Context & Async Safety)

### Context & Async Safety

#### `check_context_mounted.sh`

**Purpose**: Ensures `context.mounted` checks are present after async operations before using `context`.

**What it checks**:

- `await` followed by `Navigator.of(context)`, `context.read()`, `context.watch()`, `ScaffoldMessenger.of(context)`, etc. without `context.mounted` check

**Why it matters**:

- Using `context` after `await` without checking `mounted` can cause "setState() called after dispose()" errors
- Common bug pattern that causes crashes when widgets are disposed during async operations

**Example violation**:

```dart
await someAsyncOperation();
Navigator.of(context).pop(); // ❌ Missing context.mounted check
```

**Correct pattern**:

```dart
await someAsyncOperation();
if (!context.mounted) return; // ✅ Check mounted first
Navigator.of(context).pop();
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_setstate_mounted.sh`

**Purpose**: Ensures `mounted` checks exist before calling `setState()` after `await`.

**What it checks**:

- `await` followed by `setState(...)` without `if (!mounted) return;` or `if (!context.mounted) return;`

**Why it matters**:

- Calling `setState()` after widget is disposed throws "setState() called after dispose()" errors
- Common source of crashes in async UI flows

**Example violation**:

```dart
await repository.load();
setState(() => _value = 1); // ❌ Missing mounted check
```

**Correct pattern**:

```dart
await repository.load();
if (!mounted) return; // ✅ Check mounted first
setState(() => _value = 1);
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_setstate_async.sh`

**Purpose**: Prevents `setState(() async { ... })` (async `setState` callbacks).

**Why it matters**:

- Flutter expects `setState` callback to be synchronous (return `void`).
- Async callbacks return `Future` and trigger runtime warnings / Crashlytics noise, and are easy to miss until manual device testing.

**Example violation**:

```dart
setState(() async {
  await repo.refresh(); // ❌ setState callback must not be async
});
```

**Correct pattern**:

```dart
await repo.refresh();
if (!mounted) return;
setState(() {
  // ✅ synchronous UI update only
});
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_inherited_widget_in_create.sh`

**Purpose**: Ensures `context.l10n`, `Theme.of(context)`, `Localizations.of(context)`, and `AppLocalizations.of(context)` are not used inside BlocProvider/Provider `create` callbacks.

**What it checks**:

- In any `create: (...)` callback, script flags lines that contain `context.l10n`, `Theme.of(context)`, `Localizations.of(context)`, or `AppLocalizations.of(context)` within callback body (same line or next 20 lines, stopping when callback body ends heuristically).

**Why it matters**:

- Using InheritedWidget reads inside `create` or `initState` throws: "Tried to listen to InheritedWidget in life-cycle that will never be called again."
- `create` callback runs once; registering as listener there is invalid. Read l10n/theme in `build()` and pass value into created object.

**Example violation**:

```dart
return BlocProvider(
  create: (context) => MyCubit(l10n: context.l10n), // ❌ context.l10n in create
  child: ...,
);
```

**Correct pattern**:

```dart
final l10n = context.l10n; // ✅ Read in build()
return BlocProvider(
  create: (_) => MyCubit(l10n: l10n),
  child: ...,
);
```

**Suppression**: Add `// check-ignore: reason` on violating line.

**Regression tests**: `test/shared/inherited_widget_lifecycle_regression_test.dart` (also run via `tool/check_regression_guards.sh`).

### Staff demo Firestore seed vs parser contract

- **Canonical payloads (Dart)**: `test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart` must stay aligned with `functions/tool/seed_staff_demo.js` field names and literals.
- **Contract test**: `test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart` asserts those payloads parse through shared mappers under `lib/features/staff_app_demo/data/staff_demo_*_firestore_map.dart`.
- **When to update**: Any change to seed payloads or mapper logic must update fixtures + seed + mappers in same PR; CI catches drift via `tool/check_regression_guards.sh` (included in `./bin/checklist` when focused regression guards run).

---

### Theme & Colors

#### `check_hardcoded_colors.sh`

**Purpose**: Prevents hard-coded colors in presentation layer.

**What it checks**:

- `Colors.black`, `Colors.white`, `Colors.grey`, `Colors.gray`, and other hard-coded color constants
- Excludes `colorScheme` usage (which is correct)

**Why it matters**:

- Hard-coded colors break dark mode support
- Inconsistent with Material 3 color scheme
- Reduces accessibility and theme adaptiveness

**Example violation**:

```dart
Text('Hello', style: TextStyle(color: Colors.black)) // ❌ Hard-coded color
```

**Correct pattern**:

```dart
Text('Hello', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)) // ✅ Theme-aware
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### Localization

- **`check_missing_localizations.sh`**: Ensures localization keys referenced in code exist in ARB files; run after adding new `context.l10n.*` usages.

#### `check_hardcoded_strings.sh`

**Purpose**: Prevents hard-coded strings in `Text` widgets.

**What it checks**:

- `Text('...')` or `Text("...")` with user-facing strings
- Excludes `context.l10n.*` usage (which is correct)
- Filters out very short strings (likely debug/test)

**Why it matters**:

- Hard-coded strings prevent localization
- Breaks UX for non-English users
- Inconsistent with app's localization strategy

**Example violation**:

```dart
Text('Search...') // ❌ Hard-coded string
```

**Correct pattern**:

```dart
Text(context.l10n.searchHint) // ✅ Localized
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### State Management

- **`check_freezed_preferred.sh`**: Prefers Freezed for new state/domain models over Equatable; encourages consistent code generation.

#### `check_cubit_isclosed.sh`

**Purpose**: Ensures `isClosed` checks before `emit()` in cubits, especially in async callbacks.

**What it checks**:

- `emit()` calls in async contexts (`.listen()`, `.then()`, `.catchError()`, `Future.delayed()`, `Timer`, etc.) without `isClosed` check

**Why it matters**:

- Calling `emit()` after cubit is closed throws "emit() called after close()" errors
- Common bug pattern in stream subscriptions, timers, and async callbacks
- Can cause crashes when cubits are disposed during async operations

**Example violation**:

```dart
stream.listen((data) {
  emit(state.copyWith(data: data)); // ❌ Missing isClosed check
});
```

**Correct pattern**:

```dart
stream.listen((data) {
  if (isClosed) return; // ✅ Check isClosed first
  emit(state.copyWith(data: data));
});
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_unguarded_null_assertion.sh`

**Purpose**: Flags use of null assertion operator `!` that doesn't have same-line null check, to prevent runtime crashes from unguarded assertions.

**What it checks**:

- Lines in `lib/` (excluding generated and test) that contain `!` (null assertion) and do **not** contain same-line guard: `!= null`, `== null`, or `??=`
- Detects assertion use before member access and calls (like `value!.field` and `callback!(...)`)
- Excludes boolean negation (`if (!`, `&& !`, etc.), `is!` (type check), `!=` (not equals), comments, and l10n/GraphQL string patterns

**Why it matters**:

- Unguarded `!` throws at runtime if value is null (e.g. after async, or from nullable API returns)
- Follow repository null-safety rules for allowed `!` usage and high-risk spots

**Correct patterns**:

- Preferred optional-to-non-null pattern: `if (x case final value?) { value.method(); }`
- Preferred switch null pattern: `final label = switch (x) { final value? => value.toString(), _ => '-' };`
- Legacy same-line guard (allowed but less preferred): `if (x != null) ... x!.method()`
- Or add `// check-ignore: reason` when guard is on previous line or otherwise verified (e.g. `putIfAbsent` then map lookup)

**Suppression**: Add `// check-ignore: reason` on same line or line above when value is provably non-null (e.g. guard on previous line).

**Why this style is preferred**:

- `if (x case final value?)` and `switch` null patterns produce non-null local value at compile time without `!`
- This removes entire class of runtime null-assertion crashes in async and callback-heavy code
- Pattern matching also keeps branches explicit and easier to review than repeated nullable checks plus force unwrapping

---

#### `check_row_text_overflow.sh`

**Purpose**: Detects Row + Icon + Text without Flexible/Expanded/IconLabelRow to avoid RenderFlex overflow on narrow widths.

**What it checks**:

- In `lib/`, any `Row(` block (55-line window) that contains both `Icon(` and `Text(` but does **not** contain `Flexible(`, `Expanded(`, or `IconLabelRow(`
- Skips `lib/shared/widgets/icon_label_row.dart` (canonical fix)

**Why it matters**:

- Unconstrained `Text` in horizontal `Row` causes overflow on small screens or large text scale
- Use `IconLabelRow` (or wrap label in `Flexible`/`Expanded` with `overflow: TextOverflow.ellipsis`) for icon+label rows

**Regression tests**: `test/shared/widgets/row_overflow_regression_test.dart` (also run via `tool/check_regression_guards.sh`).

**Suppression**: Add `// check-ignore: reason` on violation line or line above when Row is intentionally safe (e.g. label is always short and constrained elsewhere).

---

#### `check_lifecycle_error_handling.sh`

**Purpose**: Catches lifecycle and error-handling patterns that can cause crashes or unhandled errors.

**What it checks**:

1. **Snackbar / ScaffoldMessenger**: Direct use of `.hideCurrentSnackBar()` or `.clearSnackBars()` instead of `ErrorHandling.hideCurrentSnackBar(context)` / `ErrorHandling.clearSnackBars(context)`. (Excludes `lib/shared/utils/error_handling.dart`, which implements these.)
2. **stream.listen() without onError**: Any `.listen(` invocation that doesn't include `onError:` in same call block (heuristic: next 25 lines). Ensures stream subscriptions handle errors and avoid unhandled zone errors. (Excludes doc-only examples in `cubit_subscription_mixin.dart` and `subscription_manager.dart`.)
3. **After await show\*Dialog**: Use of `cubit.`, `context.cubit`, or `onClose()` after `await show*Dialog` / `await showAdaptiveDialog` without prior `context.mounted` check in same block.

**Why it matters**:

- Direct `messenger.hideCurrentSnackBar()` can throw `StateError` when snackbar was already dismissed; `ErrorHandling` catches this.
- `stream.listen()` without `onError` leaves errors unhandled and can break reactivity or crash.
- Using context or cubit after async dialog without `context.mounted` can trigger "setState() after dispose" or use of disposed context.

**Correct patterns**:

- Use `ErrorHandling.hideCurrentSnackBar(context)` and `ErrorHandling.clearSnackBars(context)` before showing snackbars.
- Always pass `onError: (Object error, StackTrace stackTrace) { ... }` (and log with `AppLogger.error`) in `stream.listen()`.
- After `await show*Dialog`, add `if (!context.mounted) return;` before using `context`, `cubit`, or `onClose()`.

**Suppression**: Add `// check-ignore: reason` on violation line or line above.

---

#### `check_offline_first_remote_merge.sh`

**Purpose**: Regression guard to catch bugs where offline-first repositories overwrite newer unsynced local state with older remote snapshot (e.g. from remote watch stream). That can cause UI flicker (e.g. counter up then down then up).

**What it checks**:

- Runs focused tests that assert: when local has unsynced changes, applying remote snapshot with older timestamp must not overwrite local. Tests live in `test/features/counter/data/offline_first_counter_repository_test.dart` (e.g. `remote watch does not overwrite newer unsynced local count`).

**Why it matters**:

- Offline-first repos merge remote watch into local state. If they apply remote whenever `remote.count != local.count` (or similar) without checking `synchronized` and `lastChanged`, stale remote event can overwrite newer user changes.

**Correct pattern**:

- Before applying remote over local, use `_shouldApplyRemote`-style check: when local is not synchronized, apply remote only if remote is strictly newer (e.g. `remote.lastChanged.isAfter(local.lastChanged)`). See `OfflineFirstCounterRepository._shouldApplyRemote` and AGENTS.md §5 Offline-first repositories.

**Adding tests**: When adding new offline-first repository that merges remote watch into local, add regression test that emits older remote snapshot and asserts local is unchanged; then add that test file to `tests` array in `tool/check_offline_first_remote_merge.sh`.

---

### Performance Optimization

#### `check_missing_const.sh`

**Purpose**: Identifies potential missing `const` constructors in `StatelessWidget` (heuristic check).

**What it checks**:

- `StatelessWidget` classes with constructors that could be `const`
- Heuristic-based (may have false positives/negatives)

**Why it matters**:

- `const` constructors reduce widget rebuilds
- Improves performance by reusing widget instances
- Best practice for widgets that don't depend on runtime data

**Example violation**:

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // Could be const but isn't
  // ...
}
```

**Note**: This is **heuristic check** (warns but doesn't fail checklist). Review manually for optimization opportunities.

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_perf_shrinkwrap_lists.sh`

**Purpose**: Flags `shrinkWrap: true` on presentation lists (potential perf issue).

**What it checks**:

- `shrinkWrap: true` in presentation widgets

**Why it matters**:

- `shrinkWrap` forces additional layout passes and can be expensive on large lists
- Often avoidable with constrained layouts or builders

**Example violation**:

```dart
ListView(shrinkWrap: true, children: items) // ❌ Potential perf hit
```

**Correct pattern**:

```dart
ListView.builder(itemCount: items.length, itemBuilder: ...) // ✅
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_perf_nonbuilder_lists.sh`

**Purpose**: Flags likely dynamic `ListView`/`GridView` `children:` construction in presentation (eager build).

**What it checks**:

- `ListView`/`GridView` with dynamic `children:` sources such as `.map(...)`,
  `List.generate(...)`, or collection `for`

**Why it matters**:

- Eager list builds can be slow for large/dynamic data sets
- Builder variants are more efficient
- Small static/prebuilt section lists may use `children:` when stable widget
  identity matters.

**Example violation**:

```dart
ListView(children: rows.map(buildRow).toList()) // ❌ Eager dynamic build
```

**Correct pattern**:

```dart
ListView.builder(itemCount: items.length, itemBuilder: ...) // ✅
ListView(children: staticSections) // ✅ small prebuilt/static sections
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_perf_missing_repaint_boundary.sh`

**Purpose**: Flags heavy widgets without `RepaintBoundary` in presentation (heuristic).

**What it checks**:

- Uses of `CustomPaint`, `ShaderMask`, `BackdropFilter`, `ImageFiltered`, `ClipPath` without `RepaintBoundary` in same file

**Why it matters**:

- Heavy paint/filter widgets can trigger costly repaints
- `RepaintBoundary` can isolate expensive subtrees

**Example violation**:

```dart
CustomPaint(painter: painter) // ❌ No RepaintBoundary in file
```

**Correct pattern**:

```dart
RepaintBoundary(child: CustomPaint(painter: painter)) // ✅
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_perf_unnecessary_rebuilds.sh`

**Purpose**: Heuristic check for potential unnecessary rebuilds that might cause blinking or performance issues.

**What it checks**:

- `setState()` calls triggered by `hasAnyChange` patterns near camera/position-related code
- State handlers that might rebuild on camera/position updates

**Why it matters**:

- Camera/position updates from user interaction shouldn't trigger widget rebuilds
- Unnecessary rebuilds cause visual blinking and performance degradation
- State handlers should only rebuild for meaningful changes (markers, map type, etc.), not camera position

**Example violation**:

```dart
Future<void> _applyStateUpdate(final MapSampleState state) async {
  final MapStateChanges changes = _stateManager.applyStateUpdate(state);
  if (changes.hasAnyChange) {  // ❌ Includes camera changes
    setState(() {});
  }
}
```

**Correct pattern**:

```dart
Future<void> _applyStateUpdate(final MapSampleState state) async {
  final MapStateChanges changes = _stateManager.applyStateUpdate(state);
  // Camera changes are handled by moveCamera() and don't need setState
  if (changes.mapTypeChanged ||
      changes.markersChanged ||
      changes.trafficChanged) {  // ✅ Excludes camera changes
    setState(() {});
  }
}
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

**Note**: This is heuristic check - it warns but doesn't fail. Review manually to confirm.

---

#### `check_concurrent_modification.sh`

**Purpose**: Detects potential concurrent modification errors when iterating over collections.

**What it checks**:

- `for-in` loops iterating over collection properties/getters (e.g., `registry.repositories`, `.values`, `.keys`, `.entries`)
- Missing snapshot creation before iteration

**Why it matters**:

- Iterating over collections from getters/properties can throw `ConcurrentModificationError` if underlying collection is modified during iteration
- Collections should be snapshot with `List.from()`, `.toList()`, or similar before iteration
- Common in registry/collection patterns where multiple threads or async operations might modify collection

**Example violation**:

```dart
final List<SyncableRepository> syncables = registry.repositories;  // ❌ Returns view
for (final SyncableRepository repo in syncables) {  // May throw ConcurrentModificationError
  await repo.pullRemote();
}
```

**Correct pattern**:

```dart
// Create a snapshot copy to avoid concurrent modification during iteration
final List<SyncableRepository> syncables =
    List<SyncableRepository>.from(registry.repositories);  // ✅ Creates snapshot
for (final SyncableRepository repo in syncables) {
  await repo.pullRemote();
}
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### Memory Safety

#### `check_memory_unclosed_streams.sh`

**Purpose**: Flags `StreamController` usage without `.close()` (heuristic).

**What it checks**:

- `StreamController` usage without `.close()` call in same file

**Why it matters**:

- Unclosed controllers can leak memory and subscriptions

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_memory_missing_dispose.sh`

**Purpose**: Flags controller instantiation in `State` classes without `dispose()` (heuristic).

**What it checks**:

- `TextEditingController`, `ScrollController`, `AnimationController`, `PageController`, `TabController`, `FocusNode` instantiation in StatefulWidgets without `dispose()`

**Why it matters**:

- Controllers hold resources and need cleanup to avoid leaks

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_dialog_controller_dispose.sh`

**Purpose**: Heuristic check for `TextEditingController` used with `showDialog`/`showAdaptiveDialog` and disposed in `finally` block or immediately after `await`. This pattern can cause "TextEditingController was used after being disposed" when dialog route is still tearing down.

**What it checks**:

- Files that contain `TextEditingController`, `showDialog` or `showAdaptiveDialog`, `finally` block, and `.dispose()` in that scope

**Why it matters**:

- Disposing controller in `finally` (or right after `await showDialog`) runs before dialog route is fully torn down; `TextField` may still reference controller during teardown, causing exception

**Correct pattern**:

- Use `StatefulWidget` for dialog content: create controller in `initState`, dispose it in `State.dispose()`. controller is then only disposed when dialog's widget tree is disposed after route is removed.

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

#### `check_dialog_text_controller_lifecycle.sh`

**Purpose**: Catch `final foo = TextEditingController(` / `var foo = TextEditingController(` declared inside `async` functions (including top-level helpers) in files that call `showDialog` or `showAdaptiveDialog`. That pattern often pairs with disposing controller when helper returns, which can still race dialog route teardown.

**What it checks**:

- Same-file presence of dialog APIs plus local (untyped) `final`/`var` controller declarations whose enclosing block opens with `async` signature tail
- Skips assignments inside `void initState()` bodies and `State` subclass **fields** (`extends State` class body)

**Why it matters**:

- Controllers should typically live in dialog `State` so `State.dispose()` runs after overlay subtree is done with them

**Correct pattern**:

- Same as `check_dialog_controller_dispose.sh`: Stateful dialog content, controllers in `initState`, `dispose` in `State.dispose()`

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### Typography

#### `check_raw_google_fonts.sh`

**Purpose**: Prevents per-widget `GoogleFonts.*` usage in presentation code.

**What it checks**:

- `GoogleFonts.*` calls in presentation widgets (excluding `app_config.dart`)

**Why it matters**:

- Typography should be defined once in theme for consistency and accessibility
- Per-widget font overrides make text scaling and theming inconsistent

**Example violation**:

```dart
Text('Title', style: GoogleFonts.roboto(fontSize: 18)) // ❌ Per-widget font
```

**Correct pattern**:

```dart
Text('Title', style: Theme.of(context).textTheme.titleLarge) // ✅ Theme-based
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

<!-- AUTO-GENERATED-CHECK_SCRIPTS:START -->
## Checklist Script Index (Auto-generated)

The list below is generated from `tool/delivery_checklist.sh` `CHECK_SCRIPTS`.

- `check_flutter_domain_imports.sh`
- `check_material_buttons.sh`
- `check_no_hive_openbox.sh`
- `check_raw_timer.sh`
- `check_raw_future_delayed.sh`
- `check_direct_getit.sh`
- `check_raw_dialogs.sh`
- `check_raw_network_images.sh`
- `check_raw_print.sh`
- `check_raw_google_fonts.sh`
- `check_side_effects_build.sh`
- `check_context_mounted.sh`
- `check_inherited_widget_in_create.sh`
- `check_inherited_widget_in_initstate.sh`
- `check_setstate_mounted.sh`
- `check_setstate_async.sh`
- `check_hardcoded_colors.sh`
- `check_hardcoded_strings.sh`
- `check_missing_localizations.sh`
- `check_cubit_isclosed.sh`
- `check_missing_const.sh`
- `check_solid_presentation_data_imports.sh`
- `check_solid_data_presentation_imports.sh`
- `check_perf_shrinkwrap_lists.sh`
- `check_perf_nonbuilder_lists.sh`
- `check_widget_identity.sh`
- `check_perf_missing_repaint_boundary.sh`
- `check_perf_unnecessary_rebuilds.sh`
- `check_live_state_list_indexing.sh`
- `check_memory_unclosed_streams.sh`
- `check_memory_missing_dispose.sh`
- `check_dialog_controller_dispose.sh`
- `check_dialog_text_controller_lifecycle.sh`
- `check_concurrent_modification.sh`
- `check_raw_json_decode.sh`
- `check_unvalidated_base_url_parse.sh`
- `check_auth_refresh_single_flight.sh`
- `check_compute_domain_layer.sh`
- `check_compute_lifecycle.sh`
- `check_no_isolate_run_in_presentation.sh`
- `check_freezed_preferred.sh`
- `check_unguarded_null_assertion.sh`
- `check_row_text_overflow.sh`
- `check_lifecycle_error_handling.sh`
- `check_offline_first_remote_merge.sh`
- `check_feature_modularity_leaks.sh`
- `check_memory_pressure_centralized.sh`
- `check_macos_debug_web_guard.sh`
- `check_agent_knowledge_base.sh`
- `check_agent_memory_compounding.sh`
- `check_ai_generated_code_smells.sh`
- `check_pyright_python.sh`

<!-- AUTO-GENERATED-CHECK_SCRIPTS:END -->

## Keeping This Doc in Sync

`tool/validate_validation_docs.sh` checks that every script in `CHECK_SCRIPTS`
(in `tool/delivery_checklist.sh`) is mentioned in this document. It runs as
part of `./bin/checklist` when you choose full sweep. If you add or remove
script from `CHECK_SCRIPTS`, add or remove corresponding entry here and
run `bash tool/validate_validation_docs.sh` to verify.

## Running Validation Scripts

### Full Sweep

All validation scripts are run by delivery checklist when you want full
repo sweep:

```bash
./bin/checklist
```

This runs all validation scripts in sequence and fails if any critical violations are found.

### Fast Local Sanity Path

Use `./bin/checklist-fast` for local-only sanity pass when tree is clean
or when local change set is limited to docs/tooling surfaces:

```bash
./bin/checklist-fast
```

Contract:

- local only; CI must keep using `./bin/checklist`
- supports clean-tree sanity checks
- supports narrow local docs/tooling change sets only
- refuses broader app/runtime diffs instead of silently weakening full gate
- runs syntax/doc-link/doc-sync/agent-drift checks when relevant
- skips dependency, analyze, app validator-suite, Mix lint, focused regression, and coverage work

checklist is also change-aware:

- skips `flutter pub get` when dependency metadata is unchanged
- formats only changed Dart files
- exits early for docs-only change sets instead of running code validation
- exits early for local tooling-only change sets (`tool/*.sh`, `bin/*`, host-template files, and validation-guidance docs) after syntax/doc-sync/drift checks instead of running app-wide Flutter validation
- caches checklist self-validation until checklist script/dependency scripts or validation docs change
- auto-skips `flutter analyze` on local change sets with no Dart/analyzer-relevant files; CI and Dart/config/l10n changes still run it
- auto-skips Pyright Python lane on local non-Python change sets; CI and standalone `tool/check_pyright_python.sh` runs still execute it
- auto-skips offline-first remote-merge regression lane on local non-offline-first change sets; CI and standalone `tool/check_offline_first_remote_merge.sh` runs still execute it
- auto-selects smallest honest `tool/check_regression_guards.sh` test subset for local feature-scoped changes; CI, broad shared/core changes, and standalone runs still use full suite
- skips Mix lint unless Mix-related files changed
- when coverage is disabled, runs focused regression guards and only runs Todo keyboard/layout subset when current change set touches Todo/layout-relevant files

### Manual Execution

You can run individual scripts manually:

```bash
# Check for context.mounted issues
bash tool/check_context_mounted.sh

# Check for hard-coded colors
bash tool/check_hardcoded_colors.sh

# Check for hard-coded strings
bash tool/check_hardcoded_strings.sh

# Check for missing isClosed checks
bash tool/check_cubit_isclosed.sh

# Check lifecycle and error-handling (snackbar, stream.listen onError, dialog mounted)
bash tool/check_lifecycle_error_handling.sh

# Check offline-first remote-merge regression (don't overwrite newer local with older remote)
bash tool/check_offline_first_remote_merge.sh

# Check for missing const constructors (heuristic)
bash tool/check_missing_const.sh

# Check SOLID layering
bash tool/check_solid_presentation_data_imports.sh
bash tool/check_solid_data_presentation_imports.sh

# Check performance heuristics
bash tool/check_perf_shrinkwrap_lists.sh
bash tool/check_perf_nonbuilder_lists.sh
bash tool/check_perf_missing_repaint_boundary.sh
bash tool/check_perf_unnecessary_rebuilds.sh

# Check for concurrent modification issues
bash tool/check_concurrent_modification.sh

# Check memory heuristics
bash tool/check_memory_unclosed_streams.sh
bash tool/check_memory_missing_dispose.sh
bash tool/check_dialog_controller_dispose.sh
bash tool/check_dialog_text_controller_lifecycle.sh
```

## Suppressing Violations

All scripts support `check-ignore` comment pattern:

```dart
// check-ignore: reason for ignoring
Navigator.of(context).pop(); // This line will be ignored

// Or on the same line:
Navigator.of(context).pop(); // check-ignore: temporary debug code
```

**Important**: Always provide reason when using `check-ignore`. Ignored violations are reported in script output.

## Script Output

Each script provides:

1. **Status message**: What is being checked
2. **Ignored violations**: Items with `check-ignore` comments (with reasons)
3. **Violations**: Actual issues that need to be fixed
4. **Exit code**: `0` for success, `1` for failures (heuristic checks may exit `0` with warnings)

## Best Practices

1. **Run checklist for broad or pre-ship validation**: `./bin/checklist`
   catches issues early when you need full sweep
2. **Use checklist-fast only for local sanity**: `./bin/checklist-fast`
   is intentionally narrow and should not replace full gate for app/runtime work
3. **Fix violations immediately**: Don't accumulate technical debt
4. **Use check-ignore sparingly**: Only when there's legitimate reason
5. **Review heuristic warnings**: Scripts like `check_missing_const.sh` and `check_side_effects_build.sh` are heuristics - review manually
6. **Keep scripts updated**: As codebase patterns evolve, update scripts accordingly

## Related Documentation

- **Developer onboarding**: [`new_developer_guide.md`](new_developer_guide.md)
- **UI/UX Guidelines**: [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md)
- **Testing Best Practices**: [`testing_overview.md`](testing_overview.md)
- **Common Bugs Prevention Tests**: `test/shared/common_bugs_prevention_test.dart`
