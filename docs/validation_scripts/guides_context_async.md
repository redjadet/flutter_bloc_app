# Validation scripts — context and async

Router: [`../validation_scripts.md`](../validation_scripts.md).

## New Validation Scripts (Context & Async Safety)

## Context & Async Safety

### `check_context_mounted.sh`

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

### `check_setstate_mounted.sh`

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

### `check_setstate_async.sh`

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

### `check_inherited_widget_in_create.sh`

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
