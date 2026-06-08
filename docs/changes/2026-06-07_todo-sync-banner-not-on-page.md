# Todo sync banner — not mounted on list page

**Date:** 2026-06-07
**Related:** [Layering optimization](2026-06-07_layering-optimization.md) (PR #310)

## Decision

**Reject** mounting `TodoSyncBanner` on the live todo list page (`TodoListPageBody`).

Counter and chat surfaces show offline/pending-sync banners; the todo list **intentionally does not**.

## Rationale

1. **Header density** — The todo list header already stacks stats, search, filters, sort, batch actions, and add controls. A sync banner competes for vertical space on phone and compact tablet layouts.
2. **Redundant signal** — Todo items are list-native; users infer sync issues from item state and retry flows more than from a global strip. Counter/chat benefit more from queue visibility (single-value or message-thread context).
3. **Layering work unchanged** — `TodoListCubit` still owns `pendingSyncCount` and `refreshPendingSyncCount()`; offline-first enqueue behavior is unchanged. Only **presentation placement** is deferred.

## What stays in the repo

| Asset | Status |
| --- | --- |
| `lib/features/todo_list/presentation/widgets/todo_sync_banner.dart` | Kept — uses shared `sync_banner_helpers` |
| `test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart` | Kept — widget contract tests |
| `todo_list_page_body.dart` comment | Documents product decision at mount site |

## Re-enable checklist (if product reverses)

1. Insert `const TodoSyncBanner()` at top of `headerChildren` in `todo_list_page_body.dart` (replace the comment block).
2. Run `flutter test test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart`.
3. Proof compact header layouts (phone + narrow tablet) in widget or manual QA.

## Verification

```bash
flutter test test/features/todo_list/presentation/widgets/todo_sync_banner_test.dart
grep -n 'Sync banner disabled' lib/features/todo_list/presentation/pages/todo_list_page_body.dart
```
