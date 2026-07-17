# Domain purity Wave B — chat / counter / todo (2026-07-17)

## Scope

Cleared domain wire `fromJson`/`toJson` for three features:

| Feature | Domain change | Data DTO |
| --- | --- | --- |
| counter | Removed Freezed JSON from `CounterSnapshot` | `counter_snapshot_dto.dart` |
| todo_list | Removed Freezed JSON from `TodoItem` | Existing `todo_item_dto.dart` |
| chat | Removed JSON from `ChatMessage` / `ChatConversation` | `chat_message_dto.dart`, `chat_conversation_dto.dart` |

## Evidence

- `bash tool/check_domain_wire_leaks.sh` — **45 → 31** (chat/counter/todo hits gone)
- Focused tests: counter snapshot + offline-first counter/todo + chat DTO/history — **54 passed**
- Clean Architecture + feature folder contract — pass
- `./tool/analyze.sh` — pass
- `./bin/format --changed`

## Out of scope (remaining warn-only) — closed later same day

Originally deferred: case_study, chart, igaming, iot_demo, search, staff flags.
**Closed** in [`2026-07-17_domain_purity_remaining_demos.md`](2026-07-17_domain_purity_remaining_demos.md)
(`violations=0`).

## Intentionally still deferred

See [`../plans/2026-07-17_maintainability_simplify_deferred.md`](../plans/2026-07-17_maintainability_simplify_deferred.md)
(**MS-D01** Wave C presentation splits; **MS-D02** staff clock-out partial flags).
