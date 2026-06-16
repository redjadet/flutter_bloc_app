# Widget list stable keys audit

**Date:** 2026-06-16

## Purpose

Flutter reuses `Element` trees by matching **widget keys** and runtime types. In
dynamic lists (`ListView.builder`, `GridView.builder`, slivers), returning row
widgets **without** a stable `key`, or keyed only by **list index**, causes the
framework to attach the wrong element when:

- items are inserted, removed, or reordered;
- the backing list is rebuilt with new object instances but the same logical rows;
- scroll position is preserved while data updates (common in chat and market UIs).

Symptoms: lost `TextEditingController` / focus, stale expansion state, wrong
animation targets, extra repaints, and flaky widget tests that pass on first pump
but fail after a rebuild.

This change implements the widget keys audit (see plan at
`../../.cursor/plans/flutter_keys_audit_603db7d3.plan.md`):
assign **domain-stable** `ValueKey`s to high-traffic dynamic lists and extend the
repo guardrail to discourage `ObjectKey` in builder rows.

## Design rules applied

| Pattern | Use when | Avoid |
| --- | --- | --- |
| `ValueKey('prefix-$domainId')` | Row has a durable id (`clientMessageId`, `sequence`, enum id) | Index-only keys when order can change |
| `ValueKey<Type>(typedId)` | Id is already a typed value object (`CaseStudyQuestionId`) | `ObjectKey(instance)` — identity follows Dart object, not domain |
| Composite key | Same id can show different content (`qid` + media `path`) | Assuming type alone is enough for stateful children |

`ObjectKey` is valid for **const** slots or when the keyed object *is* the
identity (e.g. one global `FormState`). It is a poor default for **builder rows**
because each rebuild often allocates fresh model instances.

## Feature changes

### Websocket demo

- **Domain:** `WebsocketMessage` gains required `sequence` (`int`), assigned
  monotonically in `WebsocketCubit` and `EchoWebsocketRepository` on send/receive.
- **Presentation:** `WebsocketMessageList` keys rows with
  `ValueKey('ws-msg-${direction}-${sequence}')` on the `RepaintBoundary` wrapper.
- **Lifecycle:** `_messageSequence` in the cubit is **not** reset on
  `disconnect()` so keys stay unique across reconnect while the message list remains
  append-only (matches echo demo semantics).

### Chat

- **`_chatMessageKey`:** `clientMessageId` → `createdAt` millis → index fallback.
- Removed `ObjectKey(message)` from the message list.
- **Cubit:** transcript rebuild assigns stable `clientMessageId` per row;
  assistant reply uses `'$clientMessageId-reply'` so reply does not collide with
  the user message key.

### Case study demo

- `ExpansionTile` keyed by `ValueKey<CaseStudyQuestionId>(qid)` so expand/collapse
  state tracks the question, not list index.
- Video tile: `ValueKey('case-study-video-$qid-$path')` so swapping clip path
  resets the player element.

### Realtime market (order book)

- Row key: `ValueKey('order_book_${index}_${side}_${price}')` — side + price
  stabilize identity when level objects are recreated on each tick; index
  disambiguates duplicate price levels if they ever appear.

## Tooling

- **`tool/check_widget_identity.dart`:** new advisory when an `itemBuilder` return
  uses `ObjectKey(` (same severity as missing key in builder rows).
- **Fixture:** `tool/fixtures/widget_identity/bad_builder_object_key.dart` for the
  Python harness.
- **Catalog:** [`validation_scripts/catalog.md`](../validation_scripts/catalog.md) documents the `ObjectKey` check.

## Tests added/updated

| Area | File |
| --- | --- |
| Websocket list keys + rebuild | `test/features/websocket/presentation/widgets/websocket_message_list_test.dart` |
| Sequence monotonicity on reconnect | `test/features/websocket/presentation/websocket_cubit_test.dart` |
| Chat fallback / stable ids | `test/chat_message_list_test.dart`, `test/chat_cubit_test.dart` |
| Case study expansion/video keys | `test/features/case_study_demo/presentation/pages/case_study_step_guards_test.dart` |
| Order book row keys | `test/features/realtime_market/presentation/widgets/order_book_panel_test.dart` |

## Verification

```bash
dart run tool/check_widget_identity.dart
python3 tool/check_widget_identity_test.py
flutter test \
  test/features/websocket/presentation/widgets/websocket_message_list_test.dart \
  test/features/websocket/presentation/websocket_cubit_test.dart \
  test/chat_message_list_test.dart \
  test/features/case_study_demo/presentation/pages/case_study_step_guards_test.dart \
  test/features/realtime_market/presentation/widgets/order_book_panel_test.dart
```

Full gate: `./bin/checklist` (includes `check_widget_identity.sh` on presentation
diffs).

## Follow-up (out of scope)

- Broader audit of remaining `ListView.builder` sites outside this plan.
- Promote `ObjectKey` advisory to hard fail after cleanup window (if desired).
