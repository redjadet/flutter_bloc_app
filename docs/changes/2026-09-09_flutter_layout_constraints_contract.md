# Flutter layout constraints contract

**Date:** 2026-09-09

## Summary

- Added canonical [`docs/architecture/flutter_layout_constraints.md`](../architecture/flutter_layout_constraints.md) from Flutter’s official layout sentence: **Constraints go down. Sizes go up. Parents set positions.** Includes tight/loose/unbounded, error → fix map, and repo helper table.
- Wired indexes and owner docs ([`README.md`](../README.md), architecture/design/review/performance/validation/testing, [`DESIGN_layout_components.md`](../../DESIGN_layout_components.md), durable prefs).
- Code: `_ResponsiveBody` now uses **incoming** `LayoutBuilder` max width (was unused) capped by `contentMaxWidth`; doc comments on page shell, `IconLabelRow`, action bars, markdown `performLayout`, overflow test helper.

## Verification

```bash
./bin/format
(cd apps/mobile && flutter test test/shared/widgets/common_page_layout_test.dart \
  test/shared/widgets/responsive_dual_cta_row_layout_test.dart)
```

Includes compact-width regression: nested parent `320` on `1200` viewport —
`ConstrainedBox.maxWidth` equals parent, not `contentMaxWidth`.

## Follow-up (same day)

- macOS `App launch` IT: wait 500ms between +/− taps so `CounterCubit`
  `_manualThrottle` does not no-op decrement on fast desktop hosts.
