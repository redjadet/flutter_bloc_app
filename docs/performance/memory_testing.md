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

## Wave B0 — report-only dry-run

Opt-in full-suite tracking without flipping the default ignore:

```bash
bash tool/run_memory_leak_tracking_dry_run.sh
# optional scoped: MEMORY_LEAK_DRY_RUN_ARGS='test/shared' bash tool/run_memory_leak_tracking_dry_run.sh
```

- Sets `--dart-define=MEMORY_LEAK_TRACKING_DRY_RUN=true` (see `flutter_test_config.dart`)
- Writes raw log + summary under `tmp/memory_leak_dry_run/<stamp>/`
- **Always exits 0** — never a checklist/CI gate
- Default untagged path remains `withIgnoredAll()`

## Seed suite (Wave A)

- `test/shared/memory_leak_smoke_test.dart` — AppScope mount/unmount
- `test/app/router/go_router_refresh_stream_test.dart` — dispose is leak-safe
- `test/shared/memory_leak_route_cycle_test.dart` — GoRouter MaterialApp mount/unmount
- `test/shared/memory_leak_controller_lifecycle_test.dart` — TextEditingController State

## Stable journeys (Wave B1)

Tag only proven-stable paths; keep global `withIgnoredAll()` for untagged tests.

| Journey | Test |
| --- | --- |
| Auth route sign-out → teardown | `test/app/router/app_route_auth_gate_test.dart` (`authenticated route sign-out…`) |
| App-shell `go` replacement (`NoTransitionPage`) | `test/shared/memory_leak_app_shell_route_replacement_test.dart` |
| Realtime watch → emit → teardown (thin `BlocBuilder`, not full chart page) | `test/shared/memory_leak_realtime_teardown_test.dart` |
| BLE tab leave teardown | `test/app/router/iot_demo_hub_page_test.dart` (`leaving BLE tab…`) |

Helper may pass `ignoredNotDisposedClasses` (e.g. `memoryLeakHarnessLayerClasses` +
`TextPainter`) for proven compositor noise only — never product owners.

Scoped run:

```bash
cd apps/mobile && flutter test \
  test/shared/memory_leak_*.dart \
  test/app/router/app_route_auth_gate_test.dart \
  test/app/router/go_router_refresh_stream_test.dart \
  test/app/router/iot_demo_hub_page_test.dart \
  --tags memory_leak --concurrency=1
```

## Rules

- Prefer bounded `pump` / short durations; avoid unbounded `pumpAndSettle`.
- Dispose owned `GoRouter` instances after unmounting the widget tree.
- On failure: confirm ownership, fix teardown, or document a narrow ignore with
  an audit entry — never restore global ignore for tagged tests.

## Triage

See [leak_tracker TROUBLESHOOT](https://github.com/dart-lang/leak_tracker/blob/main/doc/leak_tracking/TROUBLESHOOT.md).
