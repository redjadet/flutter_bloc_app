# Widget test playbook (BLoC)

How-to for screen-level widget tests. **Policy:** [`testing_overview.md`](../testing_overview.md) § Feature-defined testing. **Per-feature contract:** [`plans/FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md).

## When widget vs cubit-only

| Situation | Prefer |
| --- | --- |
| State transition rules, repository orchestration | Cubit test in `test/**` |
| Tap → validation message, dialog, navigation side effect | Widget **behaviour** test |
| Loading / success / error / empty UI for a screen | Widget **state** test (seed cubit) |
| Pure domain parsing | Unit test |

Use P0–P2 guidance in testing_overview before skipping widget coverage.

## Minimal app shell

Wrap the subject with `MaterialApp`, localization delegates, and supported locales.
See [`test/features/auth/presentation/pages/register_page_test.dart`](../../test/features/auth/presentation/pages/register_page_test.dart).

## Inject cubit (BLoC)

Prefer `BlocProvider.value` with a cubit you control in the test; close in tear-down:

```dart
addTearDown(cubit.close);
```

See [`test/features/calculator/presentation/pages/calculator_payment_page_test.dart`](../../test/features/calculator/presentation/pages/calculator_payment_page_test.dart).

This repo uses **BLoC + get_it**, not Riverpod. Override repositories via fakes registered in test setup or pass cubits explicitly—do not hit live APIs.

## Tap targets

Put `ValueKey` on buttons and fields that tests tap (register page pattern). Prefer keys over `find.text` when copy is localized.

## Fakes and stability

1. Search `test/` for an existing fake before adding mocks.
2. Reuse [`test/test_helpers.dart`](../../test/test_helpers.dart) for Firebase/Hive/DI stubs when needed.
3. No live HTTP in widget tests.

## Async pumps

- Use `pump()` for single frames; bounded helpers for async-heavy UI.
- Avoid unbounded `pumpAndSettle()` on animated or network-image flows.
- Align with flaky-prevention rules in [`testing_strategy.md`](testing_strategy.md).

## Layout-sensitive screens

For overflow-prone action bars or narrow widths:

- Set size with `tester.view.physicalSize` and `tester.view.devicePixelRatio`;
  reset them in `addTearDown`.
- Run [`tool/check_action_bar_layout.sh`](../../tool/check_action_bar_layout.sh) when changing horizontal CTAs.

See [`test/shared/widgets/action_bar_layout_regression_test.dart`](../../test/shared/widgets/action_bar_layout_regression_test.dart)
for the current pattern. Do **not** add viewport setup to every widget test until
a shared harness exists—use it only where layout is part of the contract.

## Related

- [`testing_strategy.md`](testing_strategy.md) — RED → GREEN
- [`feature_implementation_guide.md`](../feature_implementation_guide.md) — delivery order
- [`testing_overview.md`](../testing_overview.md) — layers and commands
