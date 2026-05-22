# Validation scripts — memory and typography

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Memory Safety

### `check_memory_unclosed_streams.sh`

**Purpose**: Flags `StreamController` usage without `.close()` (heuristic).

**What it checks**:

- `StreamController` usage without `.close()` call in same file

**Why it matters**:

- Unclosed controllers can leak memory and subscriptions

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_memory_missing_dispose.sh`

**Purpose**: Flags controller instantiation in `State` classes without `dispose()` (heuristic).

**What it checks**:

- `TextEditingController`, `ScrollController`, `AnimationController`, `PageController`, `TabController`, `FocusNode` instantiation in StatefulWidgets without `dispose()`

**Why it matters**:

- Controllers hold resources and need cleanup to avoid leaks

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_dialog_controller_dispose.sh`

**Purpose**: Heuristic check for `TextEditingController` used with `showDialog`/`showAdaptiveDialog` and disposed in `finally` block or immediately after `await`. This pattern can cause "TextEditingController was used after being disposed" when dialog route is still tearing down.

**What it checks**:

- Files that contain `TextEditingController`, `showDialog` or `showAdaptiveDialog`, `finally` block, and `.dispose()` in that scope

**Why it matters**:

- Disposing controller in `finally` (or right after `await showDialog`) runs before dialog route is fully torn down; `TextField` may still reference controller during teardown, causing exception

**Correct pattern**:

- Use `StatefulWidget` for dialog content: create controller in `initState`, dispose it in `State.dispose()`. controller is then only disposed when dialog's widget tree is disposed after route is removed.

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_dialog_text_controller_lifecycle.sh`

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

## Typography

### `check_raw_google_fonts.sh`

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
