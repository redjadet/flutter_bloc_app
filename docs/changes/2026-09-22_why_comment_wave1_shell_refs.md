# Why-comment Wave 1 — shell, router, sync, reference features

**Date:** 2026-09-22  
**Scope:** Comments-only maintainability pass (no behavior/signature changes).

## Canon (do not redefine)

- [`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) § Readable code and useful comments
- [`docs/CODE_QUALITY.md`](../CODE_QUALITY.md) § Clean code in the AI era

## What changed

High-signal **why** comments (and tightening of existing docs) on:

- App shell / DI: `app_scope.dart`, demo route factory, staff-app registrar
- Router: `auth_redirect` (path-based coarse guard ≠ authorization), `go_router_refresh_stream` (generic stream adapter + owner dispose), `route_auth_policy`, `route_scoped_page` ownership
- Social feed generation/leases/mutations/paging + pending overlay/dispatch
- Counter / todo / remote_config / profile offline merge contracts
- Network error mapper status-precedence (honest about Dio message fallback)

## Evidence anchors

| Claim | Test / guard |
| --- | --- |
| AppScope resume timer coalesce | `apps/mobile/test/app/app_scope_test.dart` — `debounces a single flush after app resumes` |
| AppScope background trim coalesce | same file — `debounces a background memory trim when app pauses` |
| Auth redirect path allowlist | `apps/mobile/test/app/router/auth_redirect_test.dart` — `allows deep link navigation for unauthenticated users` (name historical; asserts non-root path) |
| GoRouter refresh stream | `apps/mobile/test/app/router/go_router_refresh_stream_test.dart` |
| Social feed stale mutation | `apps/mobile/test/features/social_feed_demo/presentation/cubit/social_feed_cubit_test.dart` — `toggleLike after switchViewer ignores stale mutation result` |
| Social feed merge / pending | `apps/mobile/test/features/social_feed_demo/domain/social_feed_merge_policy_test.dart`; `apps/mobile/test/features/social_feed_demo/data/offline_first_social_feed_repository_test.dart` |
| Counter merge | `apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart` — e.g. `processOperation does not push stale pending over newer remote` |
| Todo merge | `apps/mobile/test/features/todo_list/data/offline_first_todo_repository_test.dart` — e.g. `processOperation does not push stale pending over newer remote` |
| Remote config coalesce | `apps/mobile/test/features/remote_config/data/offline_first_remote_config_repository_test.dart` — `concurrent forceFetch calls run only one remote fetch` |
| Profile cache-then-refresh | `apps/mobile/test/features/profile/data/offline_first_profile_repository_test.dart` — `returns cached immediately and refreshes when online` |
| Offline remote-merge CI | `tool/check_offline_first_remote_merge.sh` |
| Error mapper status / Dio offline | `apps/mobile/test/shared/utils/network_error_mapper_test.dart` — e.g. `maps Dio connection errors to offline network errors` |

## Deferrals / known limitations

- **Dio `error.message` passthrough** when no status-keyed message exists is documented from source inspection—**no dedicated regression test** asserts raw-message retention or l10n suppression of that path. Separate hardening if product requires stripping library text from `AppError.message`.
- Wave 2 shipped: [`2026-09-22_why_comment_wave2_chat_iot_therapy_packages.md`](2026-09-22_why_comment_wave2_chat_iot_therapy_packages.md) (networking skip — already documented).
- [`CODEMAP.md`](../../CODEMAP.md) unchanged (no discoverability gap found).
