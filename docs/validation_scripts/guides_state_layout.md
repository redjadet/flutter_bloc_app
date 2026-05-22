# Validation scripts — state and layout

Router: [`../validation_scripts.md`](../validation_scripts.md).

## State Management

- **`check_freezed_preferred.sh`**: Prefers Freezed for new state/domain models over Equatable; encourages consistent code generation.

### `check_cubit_isclosed.sh`

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

### `check_unguarded_null_assertion.sh`

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

### `check_row_text_overflow.sh`

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

### `check_row_action_overflow.sh`

**Purpose**: Detects `Row` blocks with two or more action buttons and no `OverflowBar`, `Wrap`, or `Expanded`/`Flexible` mitigation (RenderFlex overflow risk on narrow widths).

**What it checks**:

- Runs **primary** scope, then **all** of `lib/` when `CHECK_ROW_ACTION_OVERFLOW_ALSO_ALL=1` (default; set `0` to skip second pass)
- Primary scope: profile/settings presentation, `presentation/widgets`, dialogs, forms, `*actions_bar*`, `common_form_field.dart`, `staff_app_demo_forms_page.dart`
- `CHECK_ROW_ACTION_OVERFLOW_SCOPE=primary|all` overrides the first pass only (legacy single-pass mode)
- Within 80 lines after each standalone `Row(` (not `ResponsiveDualCtaRow`, `IconLabelRow`, etc.), counts action buttons
- Passes when `OverflowBar`, `ResponsiveActionOverflowBar`, `ResponsiveDualCtaRow`, `Wrap`, or `Expanded`/`Flexible` appears in the same window
- `lib/shared/widgets/responsive_action_bar.dart` is always in primary scope (canonical `Row`+`Expanded` for dual CTAs lives there when call sites use `ResponsiveDualCtaRow`)
- Self-test: `tool/check_row_action_overflow_fixtures.sh` via `tool/fixtures/action_row/`

**Why it matters**:

- Intrinsic-width button groups overflow before they wrap; `OverflowBar` stacks actions vertically when horizontal space is tight
- Complements `check_row_text_overflow.sh` (icon + label rows → `IconLabelRow`)

**Regression tests**: `test/shared/widgets/action_bar_layout_regression_test.dart`, `test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart` (via `tool/check_action_bar_layout.sh` and `CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS=auto|0|1`).

**Env**: `CHECK_ROW_ACTION_OVERFLOW_MODE=fail|warn` (default `fail`). `CHECK_ROW_ACTION_OVERFLOW_ALSO_ALL=1|0` (default `1`). Checklist uses `fail` + dual pass.

**Suppression**: `// check-ignore: reason` on the `Row(` line or the line above.

---

### `check_action_bar_layout.sh`

**Purpose**: Runs focused widget tests for `OverflowBar` and staff proof signature action layout at 320–360dp widths.

**Env**: Invoked from `./bin/checklist` when `CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS=auto|0|1` matches PRIMARY_SCOPE UI changes (see `tool/delivery_checklist.sh`).

---

### `check_lifecycle_error_handling.sh`

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

### `check_offline_first_remote_merge.sh`

**Purpose**: Regression guard to catch bugs where offline-first repositories overwrite newer unsynced local state with older remote snapshot (e.g. from remote watch stream). That can cause UI flicker (e.g. counter up then down then up).

**What it checks**:

- Runs focused tests that assert: when local has unsynced changes, applying remote snapshot with older timestamp must not overwrite local. Tests live in `test/features/counter/data/offline_first_counter_repository_test.dart` (e.g. `remote watch does not overwrite newer unsynced local count`).

**Why it matters**:

- Offline-first repos merge remote watch into local state. If they apply remote whenever `remote.count != local.count` (or similar) without checking `synchronized` and `lastChanged`, stale remote event can overwrite newer user changes.

**Correct pattern**:

- Before applying remote over local, use `_shouldApplyRemote`-style check: when local is not synchronized, apply remote only if remote is strictly newer (e.g. `remote.lastChanged.isAfter(local.lastChanged)`). See `OfflineFirstCounterRepository._shouldApplyRemote` and AGENTS.md §5 Offline-first repositories.

**Adding tests**: When adding new offline-first repository that merges remote watch into local, add regression test that emits older remote snapshot and asserts local is unchanged; then add that test file to `tests` array in `tool/check_offline_first_remote_merge.sh`.

---
