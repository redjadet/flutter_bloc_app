# Memory lints (`memory_lint`)

Native `analysis_server_plugin` package: `custom_lints/memory_lint`.

Registered in root `analysis_options.yaml` as errors.

| Rule ID | Detects |
| --- | --- |
| `memory_state_controller_missing_dispose` | `State` field typed as Flutter controller / `FocusNode` without `<field>.dispose()` in `dispose()` |
| `memory_stream_controller_missing_close` | `StreamController` field without `<field>.close()` in `dispose()` or `close()` |
| `memory_widgets_binding_observer_missing_remove` | `addObserver(this)` without `removeObserver(this)` |
| `memory_static_build_context` | `static` field typed `BuildContext` / `BuildContext?` |

## Scope

Syntax-only, current class. No GetIt inference, aliases, inherited fields, or
automatic fixes in Wave A.

## Run

```bash
bash tool/run_memory_lint.sh
```

Skip: `SKIP_MEMORY_LINT=1` or `CHECKLIST_RUN_MEMORY_LINT=0`.

## Suppression

Use `// ignore: memory_<rule_id>` with an ownership reason on the same line, and
add a row to [`../audits/memory_quality_wave_a_review_2026-07-17.md`](../audits/memory_quality_wave_a_review_2026-07-17.md).
Do not add global ignores.

## Wave B exclusions

Timer.periodic, addListener/removeListener, `ChangeNotifier` fields, GetIt
singleton holding context, closure capture.

## Examples

**Bad**

```dart
class Bad extends State<MyWidget> {
  final TextEditingController controller = TextEditingController();
  // missing dispose()
}
```

**Good**

```dart
class Good extends State<MyWidget> {
  late final TextEditingController controller;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```
