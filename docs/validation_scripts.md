# Validation Scripts Documentation

This document describes all validation scripts in the `tool/` directory that are automatically run by `./bin/checklist` to catch bugs and enforce best practices early.

## Overview

The validation scripts provide automated guards for architecture, UI/UX, async safety, performance, and memory hygiene. These scripts are automatically executed when you run `./bin/checklist` before commits, ensuring code quality and consistency across the codebase.

The checklist includes automated guards for:

- **Architecture compliance** - Ensures clean architecture boundaries and dependency injection patterns
- **UI/UX best practices** - Enforces platform-adaptive widgets, proper image caching, and responsive design
- **Async safety** - Detects missing lifecycle guards and context usage after async operations
- **Performance** - Flags performance anti-patterns like unnecessary rebuilds and missing repaint boundaries
- **Memory hygiene** - Prevents leaks and ensures proper cleanup of resources

Full documentation and suppression guidance is provided in the sections below.

## Existing Validation Scripts

### Architecture & Dependency Injection

- **`check_flutter_domain_imports.sh`**: Ensures domain layer is Flutter-agnostic (no `package:flutter` imports)
- **`check_direct_getit.sh`**: Prevents direct `GetIt` access in presentation widgets (should inject via constructors/cubits)
- **`check_no_hive_openbox.sh`**: Prevents direct `Hive.openBox` usage (should use `HiveService`/`HiveRepositoryBase`)
- **`check_unvalidated_base_url_parse.sh`**: Prevents `Uri.parse(...)` directly on dynamic `baseUrl`-like values without validation helper
- **`check_solid_presentation_data_imports.sh`**: Prevents presentation importing data-layer types (DIP)
- **`check_solid_data_presentation_imports.sh`**: Prevents data layer importing presentation (layering)

### UI/UX Best Practices

- **`check_material_buttons.sh`**: Prevents raw Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`) - should use `PlatformAdaptive.*` helpers
- **`check_raw_dialogs.sh`**: Prevents raw dialog APIs - should use `showAdaptiveDialog()`
- **`check_raw_network_images.sh`**: Prevents raw `Image.network` usage - should use `CachedNetworkImageWidget`
- **`check_raw_print.sh`**: Prevents raw `print()`/`debugPrint()` usage - should use `AppLogger`
- **`check_raw_google_fonts.sh`**: Prevents per-widget `GoogleFonts.*` usage - should define fonts in `app_config.dart`

### Performance

- **`check_perf_shrinkwrap_lists.sh`**: Flags `shrinkWrap: true` lists/grids in presentation code
- **`check_perf_nonbuilder_lists.sh`**: Ensures lists/grids use builder constructors for lazy rendering
- **`check_perf_missing_repaint_boundary.sh`**: Warns when heavy widgets lack `RepaintBoundary`
- **`check_perf_unnecessary_rebuilds.sh`**: Heuristic check for `setState()` calls that might cause unnecessary rebuilds/blinking (warns but doesn't fail)
- **`check_concurrent_modification.sh`**: Detects potential concurrent modification errors when iterating over collections from getters/properties

### Compute/Isolate Usage

- **`check_raw_json_decode.sh`**: Prevents raw `jsonDecode()`/`jsonEncode()` usage - should use `decodeJsonMap()`/`decodeJsonList()`/`encodeJsonIsolate()` for large payloads (>8KB)
- **`check_compute_domain_layer.sh`**: Prevents `compute()` usage in domain layer (domain should be Flutter-agnostic)
- **`check_compute_lifecycle.sh`**: Heuristic check for `compute()` usage in lifecycle methods (`build()`, `performLayout()`) - warns but doesn't fail

### Timing & Services

- **`check_raw_timer.sh`**: Prevents raw `Timer` usage - should use `TimerService` for testability

### Widget Lifecycle

- **`check_side_effects_build.sh`**: Heuristic check for side effects in `build()` method (warns but doesn't fail)
- **`check_inherited_widget_in_create.sh`**: Prevents `context.l10n`/`Theme.of(context)` inside BlocProvider/Provider `create` (see Context & Async Safety below)

## New Validation Scripts (Added 2025)

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_setstate_mounted.sh`

**Purpose**: Ensures `mounted` checks exist before calling `setState()` after `await`.

**What it checks**:

- `await` followed by `setState(...)` without `if (!mounted) return;` or `if (!context.mounted) return;`

**Why it matters**:

- Calling `setState()` after a widget is disposed throws "setState() called after dispose()" errors
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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_inherited_widget_in_create.sh`

**Purpose**: Ensures `context.l10n`, `Theme.of(context)`, `Localizations.of(context)`, and `AppLocalizations.of(context)` are not used inside BlocProvider/Provider `create` callbacks.

**What it checks**:

- In any `create: (...)` callback, the script flags lines that contain `context.l10n`, `Theme.of(context)`, `Localizations.of(context)`, or `AppLocalizations.of(context)` within the callback body (same line or next 20 lines, stopping when callback body ends heuristically).

**Why it matters**:

- Using InheritedWidget reads inside `create` or `initState` throws: "Tried to listen to an InheritedWidget in a life-cycle that will never be called again."
- The `create` callback runs once; registering as a listener there is invalid. Read l10n/theme in `build()` and pass the value into the created object.

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

**Suppression**: Add `// check-ignore: reason` on the violating line.

**Regression tests**: `test/shared/inherited_widget_lifecycle_regression_test.dart` (also run via `tool/check_regression_guards.sh`).

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

### Localization

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

### State Management

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_unguarded_null_assertion.sh`

**Purpose**: Flags use of the null assertion operator `!` that does not have a same-line null check, to prevent runtime crashes from unguarded assertions.

**What it checks**:

- Lines in `lib/` (excluding generated and test) that contain `!` (null assertion) and do **not** contain a same-line guard: `!= null`, `== null`, or `??=`
- Detects assertion use before member access and calls (for example `value!.field` and `callback!(...)`)
- Excludes boolean negation (`if (!`, `&& !`, etc.), `is!` (type check), `!=` (not equals), comments, and l10n/GraphQL string patterns

**Why it matters**:

- Unguarded `!` throws at runtime if the value is null (e.g. after async, or from nullable API returns)
- Follow the repository null-safety rules for allowed `!` usage and high-risk spots

**Correct patterns**:

- Preferred optional-to-non-null pattern: `if (x case final value?) { value.method(); }`
- Preferred switch null pattern: `final label = switch (x) { final value? => value.toString(), _ => '-' };`
- Legacy same-line guard (allowed but less preferred): `if (x != null) ... x!.method()`
- Or add `// check-ignore: reason` when the guard is on the previous line or otherwise verified (e.g. `putIfAbsent` then map lookup)

**Suppression**: Add `// check-ignore: reason` on the same line or line above when the value is provably non-null (e.g. guard on previous line).

**Why this style is preferred**:

- `if (x case final value?)` and `switch` null patterns produce a non-null local value at compile time without `!`
- This removes an entire class of runtime null-assertion crashes in async and callback-heavy code
- Pattern matching also keeps branches explicit and easier to review than repeated nullable checks plus force unwrapping

---

#### `check_row_text_overflow.sh`

**Purpose**: Detects Row + Icon + Text without Flexible/Expanded/IconLabelRow to avoid RenderFlex overflow on narrow widths.

**What it checks**:

- In `lib/`, any `Row(` block (55-line window) that contains both `Icon(` and `Text(` but does **not** contain `Flexible(`, `Expanded(`, or `IconLabelRow(`
- Skips `lib/shared/widgets/icon_label_row.dart` (canonical fix)

**Why it matters**:

- Unconstrained `Text` in a horizontal `Row` causes overflow on small screens or large text scale
- Use `IconLabelRow` (or wrap the label in `Flexible`/`Expanded` with `overflow: TextOverflow.ellipsis`) for icon+label rows

**Regression tests**: `test/shared/widgets/row_overflow_regression_test.dart` (also run via `tool/check_regression_guards.sh`).

**Suppression**: Add `// check-ignore: reason` on the violation line or line above when the Row is intentionally safe (e.g. label is always short and constrained elsewhere).

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

**Note**: This is a **heuristic check** (warns but doesn't fail the checklist). Review manually for optimization opportunities.

**Suppression**: Add `// check-ignore: reason` on the same line or line above

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_perf_nonbuilder_lists.sh`

**Purpose**: Flags `ListView`/`GridView` with `children` in presentation (eager build).

**What it checks**:

- `ListView`/`GridView` with `children:` in presentation files

**Why it matters**:

- Eager list builds can be slow for large/dynamic data sets
- Builder variants are more efficient

**Example violation**:

```dart
ListView(children: items) // ❌ Eager build
```

**Correct pattern**:

```dart
ListView.builder(itemCount: items.length, itemBuilder: ...) // ✅
```

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_perf_missing_repaint_boundary.sh`

**Purpose**: Flags heavy widgets without `RepaintBoundary` in presentation (heuristic).

**What it checks**:

- Uses of `CustomPaint`, `ShaderMask`, `BackdropFilter`, `ImageFiltered`, `ClipPath` without `RepaintBoundary` in the same file

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

**Note**: This is a heuristic check - it warns but doesn't fail. Review manually to confirm.

---

#### `check_concurrent_modification.sh`

**Purpose**: Detects potential concurrent modification errors when iterating over collections.

**What it checks**:

- `for-in` loops iterating over collection properties/getters (e.g., `registry.repositories`, `.values`, `.keys`, `.entries`)
- Missing snapshot creation before iteration

**Why it matters**:

- Iterating over collections from getters/properties can throw `ConcurrentModificationError` if the underlying collection is modified during iteration
- Collections should be snapshot with `List.from()`, `.toList()`, or similar before iteration
- Common in registry/collection patterns where multiple threads or async operations might modify the collection

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

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

### Memory Safety

#### `check_memory_unclosed_streams.sh`

**Purpose**: Flags `StreamController` usage without `.close()` (heuristic).

**What it checks**:

- `StreamController` usage without a `.close()` call in the same file

**Why it matters**:

- Unclosed controllers can leak memory and subscriptions

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

#### `check_memory_missing_dispose.sh`

**Purpose**: Flags controller instantiation in `State` classes without `dispose()` (heuristic).

**What it checks**:

- `TextEditingController`, `ScrollController`, `AnimationController`, `PageController`, `TabController`, `FocusNode` instantiation in StatefulWidgets without `dispose()`

**Why it matters**:

- Controllers hold resources and need cleanup to avoid leaks

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

### Typography

#### `check_raw_google_fonts.sh`

**Purpose**: Prevents per-widget `GoogleFonts.*` usage in presentation code.

**What it checks**:

- `GoogleFonts.*` calls in presentation widgets (excluding `app_config.dart`)

**Why it matters**:

- Typography should be defined once in the theme for consistency and accessibility
- Per-widget font overrides make text scaling and theming inconsistent

**Example violation**:

```dart
Text('Title', style: GoogleFonts.roboto(fontSize: 18)) // ❌ Per-widget font
```

**Correct pattern**:

```dart
Text('Title', style: Theme.of(context).textTheme.titleLarge) // ✅ Theme-based
```

**Suppression**: Add `// check-ignore: reason` on the same line or line above

---

## Running Validation Scripts

### Automatic Execution

All validation scripts are automatically run by the delivery checklist:

```bash
./bin/checklist
```

This runs all validation scripts in sequence and fails if any critical violations are found.

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
```

## Suppressing Violations

All scripts support the `check-ignore` comment pattern:

```dart
// check-ignore: reason for ignoring
Navigator.of(context).pop(); // This line will be ignored

// Or on the same line:
Navigator.of(context).pop(); // check-ignore: temporary debug code
```

**Important**: Always provide a reason when using `check-ignore`. Ignored violations are reported in the script output.

## Script Output

Each script provides:

1. **Status message**: What is being checked
2. **Ignored violations**: Items with `check-ignore` comments (with reasons)
3. **Violations**: Actual issues that need to be fixed
4. **Exit code**: `0` for success, `1` for failures (heuristic checks may exit `0` with warnings)

## Best Practices

1. **Run checklist before committing**: `./bin/checklist` catches issues early
2. **Fix violations immediately**: Don't accumulate technical debt
3. **Use check-ignore sparingly**: Only when there's a legitimate reason
4. **Review heuristic warnings**: Scripts like `check_missing_const.sh` and `check_side_effects_build.sh` are heuristics - review manually
5. **Keep scripts updated**: As codebase patterns evolve, update scripts accordingly

## Related Documentation

- **Common Bugs Checklist**: `docs/new_developer_guide.md` (Common Bugs to Avoid section)
- **UI/UX Guidelines**: `docs/ui_ux_responsive_review.md`
- **Testing Best Practices**: `docs/new_developer_guide.md` (Testing section)
- **Common Bugs Prevention Tests**: `test/shared/common_bugs_prevention_test.dart`
