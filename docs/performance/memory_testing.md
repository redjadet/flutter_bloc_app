# Memory testing (leak_tracker)

## Model

| Scope | Settings |
| --- | --- |
| Default (untagged) | `LeakTesting.enable()` + `withIgnoredAll()` in `apps/mobile/test/flutter_test_config.dart` |
| Tagged gate | `leakSafeTestWidgets` → `experimentalLeakTesting: LeakTesting.settings.withTrackedAll()` |

Do **not** pass bare `LeakTesting.settings` into tagged tests (that object is the
global ignore). Always use the helper.

## Helper

```dart
import '../helpers/memory/leak_safe_test_widgets.dart';

leakSafeTestWidgets('… is leak-safe', (tester) async {
  // mount → exercise → pumpWidget(SizedBox.shrink()) → dispose owned routers
});
```

Tag constant: `memoryLeakTag` (`memory_leak`).

## Commands

```bash
cd apps/mobile && flutter test --tags memory_leak
cd apps/mobile && flutter test test/shared/memory_leak_smoke_test.dart
```

## Seed suite (Wave A)

- `test/shared/memory_leak_smoke_test.dart` — AppScope mount/unmount
- `test/app/router/go_router_refresh_stream_test.dart` — dispose is leak-safe
- `test/shared/memory_leak_route_cycle_test.dart` — GoRouter MaterialApp mount/unmount
- `test/shared/memory_leak_controller_lifecycle_test.dart` — TextEditingController State

## Rules

- Prefer bounded `pump` / short durations; avoid unbounded `pumpAndSettle`.
- Dispose owned `GoRouter` instances after unmounting the widget tree.
- On failure: confirm ownership, fix teardown, or document a narrow ignore with
  an audit entry — never restore global ignore for tagged tests.

## Triage

See [leak_tracker TROUBLESHOOT](https://github.com/dart-lang/leak_tracker/blob/main/doc/leak_tracking/TROUBLESHOOT.md).
