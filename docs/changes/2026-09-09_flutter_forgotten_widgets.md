# Forgotten Flutter widgets (SDK chooser + polish)

## Why

[Stackademic article](https://blog.stackademic.com/the-flutter-widgets-i-keep-forgetting-exist-until-they-save-me-an-hour-b46eb8201167)
lists shipped widgets people rebuild by habit (`Wrap`, `SelectableText`,
`LayoutBuilder`, `Dismissible`, `AnimatedSwitcher`, `Tooltip`, `AspectRatio`,
`Intrinsic*`). Repo layout/`Wrap`/`LayoutBuilder`/`Dismissible` guidance was
already strong; gaps were copyable diagnostics, icon-menu tooltip, one status-
region switcher, and a durable chooser in owner docs.

## Change

- Extended [`design_system.md`](../design_system.md) with an SDK widget chooser
  (and explicit non-goal: no feature `ValueListenableBuilder`).
- Layout Intrinsic warning in
  [`architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md).
- Review chooser rows in
  [`review/ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md).
- Status-region AnimatedSwitcher + Intrinsic note in
  [`performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md).
- Code: `SelectableText` on remote-config error/test value, secure-messaging
  recovered/failure, production-readiness errors; restore Material
  `PopupMenuButton` tooltip on todo overflow; keyed `AnimatedSwitcher` on
  production readiness shell (`KeyedSubtree` + `ValueKey(status)` for
  `check_widget_identity`).
- Tests: `NoSplash.splashFactory` on touched MaterialApp harnesses so tap
  paths do not load missing `ink_sparkle.frag` (matches `AppConfig` test
  theme override).

## Ownership

Responsive/layout owners remain [`design_system.md`](../design_system.md) and
[`architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md).
Perf notes own status-region switcher guidance.

## Validation

```bash
./bin/format
flutter test \
  apps/mobile/test/features/settings/presentation/widgets/remote_config_diagnostics_section_test.dart \
  apps/mobile/test/features/secure_messaging_demo/presentation/widgets/secure_messaging_demo_body_test.dart \
  apps/mobile/test/features/production_readiness/presentation/production_readiness_page_test.dart \
  apps/mobile/test/features/todo_list/presentation/widgets/todo_list_item_test.dart
bash tool/check_docs_gardening.sh --paths \
  docs/design_system.md \
  docs/architecture/flutter_layout_constraints.md \
  docs/review/ui_ux_responsive_review.md \
  docs/performance/performance_bottlenecks.md \
  docs/changes/2026-09-09_flutter_forgotten_widgets.md \
  docs/changes/README.md
./bin/agent-maintain closeout
```
