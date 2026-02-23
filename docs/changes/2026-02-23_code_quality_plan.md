# Code Quality Improvement Plan — 2026-02-23 (v2)

## Executive Summary

This plan outlines a coordinated effort to bring the codebase into 100% compliance with established project rules. It targets infrastructure deadlocks, async safety, and architectural leaks found during a deep-dive audit.

**Implementation status:** Phases 2 and 3 (code changes) are done. Phase 1 (environment) and Phase 4 (validation) remain for local/CI execution.

---

## 🏗️ Phase 1: Infrastructure Recovery — *Pending (environment)*

The current failure of `build_runner` masks hundreds of potential type-safety issues and prevents proper equality checks in BLoC states.

1. **Resolve SDK Permission Conflict**:
    - Run `sudo chown -R $(whoami) /Users/ilkersevim/Flutter_SDK/bin/cache` to unlock `engine.stamp`.
2. **Restore Code Generation**:
    - Execute `dart run build_runner build --delete-conflicting-outputs`.
    - Verification: Ensure files like `chat_message_list.freezed.dart` are generated and error-free.
3. **Establish Analysis Baseline**:
    - Run `./tool/analyze.sh` once generated code is present to catch hidden type-mismatch bugs.

---

## 🏎️ Phase 2: Lifecycle & Async Security — ✅ Done

Audit found several instances where lifecycle guards are manual or missing in edge cases.

1. **Automated Async Guards** — ✅ Done
    - `CubitExceptionHandler.executeAsync` and `executeAsyncVoid` in `lib/shared/utils/cubit_async_operations.dart` now accept an optional `isAlive` parameter (e.g. `() => !isClosed`). When provided, `onSuccess` and `onError` are only invoked if `isAlive()` returns true.
2. **Subscription Standardization** — ✅ Done
    - `SyncStatusCubit` uses `CubitSubscriptionMixin`; all three stream subscriptions are registered and cancelled via `closeAllSubscriptions()` in `close()`.
3. **Timer Safety Audit** — ✅ Done
    - `ScapesCubit` injects optional `TimerService` (defaults to `DefaultTimerService`), uses `TimerService.runOnce` for the load delay, and disposes the handle in `close()`.

---

## 🎨 Phase 3: Architectural & UI Hygiene — ✅ Done

Audit identified leaks of raw strings and non-responsive measurements into the presentation layer.

1. **Responsive Layer Enforcement** — ✅ Done
    - In `lib/features/todo_list/presentation/widgets/todo_list_content.dart`, replaced `MediaQuery.of(context).size.height * 0.6` with `context.heightFraction(0.6)` from responsive extensions.
2. **L10n Coverage Gaps** — ✅ Done
    - Added keys to `app_en.arb` (and es/fr/de/tr): `noWalletConnected`, `noWalletLinked`, `couldNotPlayAudio`, `scapesErrorOccurred`, `noScapesAvailable`.
    - `WalletConnectAuthCubit` accepts optional `l10n` and uses it for the two error messages (route passes `context.l10n`).
    - `PlaylearnCubit` accepts optional `l10n` and uses it in `speakWord`; pages pass `context.l10n`.
    - Scapes pages and `ScapesGridContent` use `context.l10n.scapesErrorOccurred` and `context.l10n.noScapesAvailable`.
3. **Performance Optimization** — ✅ Audited
    - shrinkWrap/Slivers audit completed; see `docs/audits/shrinkwrap_slivers_audit.md`. High-priority recommendation: refactor Library demo + Scapes grid to `CustomScrollView` + SliverGrid when embedding the grid.
4. **Decorative Color Extraction** — ✅ Done
    - Created `ConfettiTheme` in `lib/core/theme/theme_extensions.dart`; registered in `AppTheme` light/dark with default particle colors. `CounterPage` uses `Theme.of(context).extension<ConfettiTheme>()?.particleColors` (with fallback).

---

## ✅ Phase 4: Validation Workflow — *Pending*

1. **Continuous Verification**:
    - Run `./bin/checklist` (All steps must pass).
    - Execute lifecycle-specific checkers: `./tool/check_cubit_isclosed.sh` and `./tool/check_context_mounted.sh`.
2. **Documentation Update**:
    - Run `dart run tool/update_coverage_summary.dart` to reflect the impact of the infrastructure fixes.

---

## 📝 Concrete Tasks for AI Agent

| Target File | Required Improvement | Status |
| --- | --- | --- |
| `lib/shared/utils/cubit_async_operations.dart` | Integrate `isClosed` guarding directly into `executeAsync`. | ✅ Done (`isAlive` param) |
| `lib/shared/sync/presentation/sync_status_cubit.dart` | Refactor to use `CubitSubscriptionMixin`. | ✅ Done |
| `lib/features/scapes/presentation/scapes_cubit.dart` | Inject and use `TimerService` instead of raw `Future`. | ✅ Done |
| `lib/features/todo_list/presentation/widgets/todo_list_content.dart` | Adopt responsive extensions for height calculation. | ✅ Done (`heightFraction(0.6)`) |
| `lib/l10n/app_en.arb` (+ usage in cubits/pages) | Add keys for WalletConnect, Playlearn, and Scapes error/empty states. | ✅ Done |
| `lib/core/theme/theme_extensions.dart` | Create `ConfettiTheme` for non-functional UI elements. | ✅ Done |

---

## 🚩 Known Risks

- **build_runner performance**: A full build may take 2-5 minutes; use `--build-filter` for rapid iteration if only specific files are needed.
- **L10n Sync**: Changes to `.arb` require a re-run of code generation to update `AppLocalizations`.
