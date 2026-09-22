# Why-comment Wave 2 — chat / IoT / therapy + packages

**Date:** 2026-09-22  
**Scope:** Comments-only maintainability pass (no behavior/signature changes).

## Canon (do not redefine)

- [`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) § Readable code and useful comments
- [`docs/CODE_QUALITY.md`](../CODE_QUALITY.md) § Clean code in the AI era
- Wave 1: [`2026-09-22_why_comment_wave1_shell_refs.md`](2026-09-22_why_comment_wave1_shell_refs.md)

## What changed

High-signal **why** comments on:

- Chat: offline-first enqueue/terminal drop, local updater replay `clientMessageId`, Composite Edge→direct online-only codes, Render runnable gates, OfflineFirst outermost DI
- IoT demo: setValue debounce + pinned scheduling user, pull skip/re-check, per-user pull coalesce, `local_only` Hive scope
- IoT BLE: real-BLE registrar gate, scan timeout cancel-before-restart
- Therapy demo: role-switch clear/restore, shared fake API singleton
- `packages/storage` HiveService: concurrent `initialize` coalesces on `_initializeInFlight`

## Evidence anchors

| Claim | Test / guard |
| --- | --- |
| Chat non-retryable no-enqueue / terminal dequeue | `apps/mobile/test/features/chat/data/offline_first_chat_repository_test.dart` |
| Chat updater no-resurrect / terminal merge | `apps/mobile/test/features/chat/data/chat_local_conversation_updater_test.dart` |
| Composite Edge→direct policy | `apps/mobile/test/features/chat/data/composite_chat_repository_test.dart` |
| IoT demo debounce / skip pull / coalesce | `apps/mobile/test/features/iot_demo/data/offline_first_iot_demo_repository_test.dart` |
| IoT demo local-only registration | Source inspection: `apps/mobile/lib/app/composition/features/register_iot_demo_services.dart`; no dedicated registration test found |
| BLE stale scan timeout | `apps/mobile/test/features/iot/presentation/cubit/iot_ble_cubit_test.dart` — `stale scan timeout does not stop a later scan` |
| Therapy role switch + admin gate | `apps/mobile/test/features/online_therapy_demo/edge_cases_test.dart`; `role_guard_test.dart` |
| Hive initialize coalescing | Source inspection: `packages/storage/lib/src/hive/hive_service.dart`; no dedicated concurrent-initialize test found |

## Deferrals / known limitations

- Chat updater: no dedicated repeated-`clientMessageId` regression; comment is source-bound replay wording.
- Render runnable predicate: no full matrix unit test (enabled / base / release HTTPS / Firebase user).
- Chat DI nesting `OfflineFirst(DemoFirst(Composite))`: compositional comment; not full integration-proven chain wording.
- BLE registrar: does not alone select mock/unsupported repository; branch comment is gateway-bounded.
- Therapy fake API shared singleton: compositional; no DI identity test across all fake repos.
- Admin role fail-closed is enforced via `_requireRole` (no extra comment; `_require*` names carry the gate).
- Networking sync coordinator/runner / `SyncAuthPinScope` / pending_sync filter docs already present — skipped this wave.
