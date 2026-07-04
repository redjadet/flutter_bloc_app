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
- Skips `apps/mobile/lib/shared/widgets/icon_label_row.dart` (canonical fix)

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
- `apps/mobile/lib/shared/widgets/responsive_action_bar.dart` is always in primary scope (canonical `Row`+`Expanded` for dual CTAs lives there when call sites use `ResponsiveDualCtaRow`)
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

1. **Snackbar / ScaffoldMessenger**: Direct use of `.hideCurrentSnackBar()` or `.clearSnackBars()` instead of `ErrorHandling.hideCurrentSnackBar(context)` / `ErrorHandling.clearSnackBars(context)`. (Excludes `apps/mobile/lib/shared/utils/error_handling.dart`, which implements these.)
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

**Purpose**: Regression guard to catch bugs where offline-first repositories overwrite newer state with stale sync data. This covers older remote snapshots applied through watch/pull and older queued local snapshots replayed over newer remote state. Stale sync can cause UI flicker (e.g. counter up then down then up) or cross-device data loss.

**What it checks**:

- Runs focused tests that assert stale sync data cannot overwrite newer state: older remote snapshots must not overwrite newer local state, older queued pending snapshots must not overwrite newer remote state, and concurrent local edits during merge must survive remote apply (TOCTOU `re-checks local before save` / `… before deleting`). Counter and todo repositories should maintain the parity matrix in [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md) § Coverage parity. Tests live in `test/features/counter/data/offline_first_counter_repository_test.dart` and `test/features/todo_list/data/offline_first_todo_repository_test.dart` (e.g. `pullRemote re-checks local before save when local advances`, `remote watch does not overwrite newer unsynced local count`, `processOperation does not push stale pending over newer remote`).
- Verifies guard wiring before skip/test selection: if a stale-sync or TOCTOU regression test file exists under `test/features/*/data/*offline_first*_repository_test.dart` (matched by `does not overwrite newer`, `does not push stale pending`, `does not overwrite local when there are pending`, or `re-checks local before save|deleting`) but is not listed in `tool/check_offline_first_remote_merge.sh`, the guard fails early.
- Runs near the start of the checklist static sweep so stale-sync data-loss regressions surface before slower quality gates.

**Why it matters**:

- Offline-first repos merge remote watch into local state and replay queued local writes to remote. If they apply or push whenever values differ without checking `synchronized` and `lastChanged`, stale sync data can overwrite newer user changes.

**Correct pattern**:

- Before applying remote over local, use `_shouldApplyRemote`-style check: when local is not synchronized, apply remote only if remote is strictly newer (e.g. `remote.lastChanged.isAfter(local.lastChanged)`). After the initial local read in a merge loop, **re-read immediately before each `save`/`delete`** and re-run the predicate (TOCTOU). See `OfflineFirstCounterRepository._applyRemoteSnapshotIfCurrent`, `offline_first_todo_repository_helpers.dart`, and [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md).

**Adding tests**: When adding new offline-first repository that merges remote watch into local, add regression test that emits older remote snapshot and asserts local is unchanged. Add TOCTOU tests that intercept the second local read during merge and assert a concurrent local edit wins. When the repository replays queued writes, add a regression test that refuses to push an older queued snapshot over newer remote state. Add a regression test that `pullRemote` retains local data when remote `fetchAll`/`load` fails. Add that test file to the selection in `tool/check_offline_first_remote_merge.sh`; the guard fails if it discovers a matching regression test that is not wired in.

---

### `check_remote_fetch_failure_fallback.sh`

**Purpose**: Catch remote read ops that swallow fetch errors via `onFailureFallback`. An empty list or default snapshot on failure is indistinguishable from a real empty remote and can trigger offline-first mass-delete during `pullRemote`.

**What it checks**:

- Scans `lib/` for `_executeForUser` / `runWithAuthUser` calls where `operation` is a read (`fetchAll`, `load`, `getAll`, `fetch`, `read`, `list`) and `onFailureFallback` is present.
- Write ops (`save`, `delete`, …) may still use no-op fallbacks.

**Correct pattern**: Remove `onFailureFallback` from remote reads; let `OfflineFirst*Repository.pullRemote` catch and log without merging.

**Reference**: [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md) § Remote fetch failures.

---
