# Baseline inventory (2026-03-17) — Codebase improvement plan

Baseline for the codebase improvement plan from `codebase_analysis_2026-03-17.md`.

## Status

This is a **point-in-time baseline snapshot** used to measure follow-up work.
Prefer current validation and workflow docs for day-to-day guidance:

- `docs/validation_scripts.md`
- `docs/testing_overview.md`
- `docs/CODE_QUALITY.md`

## Checks run

- **flutter analyze**: run; no issues found.
- **Unit/widget tests**: suites touching audit-listed and refactored files (sync coordinator, offline_first_todo_repository, walletconnect_service, todo_list_dialogs) are run as part of full test suite / delivery checklist.
- **Coverage**: snapshot in `coverage/coverage_summary.md` (reference point for measuring impact of plan).

## Future.delayed classification (audit-listed and lib/ usage)

| File | Classification | Notes |
| ------ | ---------------- | ------ |
| `lib/features/walletconnect_auth/data/walletconnect_service.dart` | **test/demo-only** | Placeholder 1s delay in `_waitForSession()`; allow-listed in `check_raw_future_delayed.sh`. |
| `lib/shared/utils/retry_policy.dart` | **production (allow-listed)** | Backoff delay; cancelable via `CancelToken` polling; allow-listed. |
| `lib/shared/utils/navigation.dart` | **navigation/UI timing** | Short delay in safeGo; allow-listed; `context.mounted` checked. |
| `lib/features/todo_list/presentation/pages/todo_list_page_handlers.dart` | **navigation/UI timing** | UI timing; allow-listed. |
| `lib/shared/utils/isolate_samples.dart` | **test/demo-only** | Sample code; excluded by script. |
| `lib/features/chart/data/delayed_chart_repository.dart` | **test/demo-only** | Demo; excluded by script. |
| `lib/features/search/data/mock_search_repository.dart` | **test/demo-only** | Mock; excluded by script. |
| `lib/features/profile/data/mock_profile_repository.dart` | **test/demo-only** | Mock; excluded by script. |
| `lib/features/chat/data/mock_chat_list_repository.dart` | **test/demo-only** | Mock; excluded by script. |
| `lib/features/iot_demo/data/mock_iot_demo_repository.dart` | **test/demo-only** | Mock; excluded by script. |
| `lib/shared/http/interceptors/retry_interceptor.dart` | **production (injectable)** | Uses injectable `_waitForDelay`; not raw `Future.delayed` at call site. |

## Audit-listed files (no production-critical Future.delayed after plan)

- `lib/features/todo_list/data/offline_first_todo_repository.dart` — uses `TimerService` (no `Future.delayed`).
- `lib/features/iot_demo/data/persistent_iot_demo_repository.dart` — uses `TimerService` (no `Future.delayed`).

## Refactored hotspots (Phase 2)

- **background_sync_coordinator**: `SyncSchedulePolicy`, `SyncJobRunner` extracted; uses `TimerService`.
- **offline_first_todo_repository**: `TodoMergePolicy` extracted; uses `TimerService`.
