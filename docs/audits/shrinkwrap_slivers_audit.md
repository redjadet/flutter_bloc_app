# shrinkWrap / Slivers Audit

**Date:** 2026-02-23
**Scope:** All `shrinkWrap: true` usages and Sliver/CustomScrollView patterns in `lib/`.

---

## Summary

| Location | Widget | Context | Necessary? | Prefer Sliver? |
| -------- | ------ | ------- | --------- | -------------- |
| ~~scapes_grid_content.dart~~ (Library demo) | — | CustomScrollView + SliverGrid (done) | — | **Done** |
| scapes_grid_content.dart | GridView | Standalone ScapesPage only (no shrinkWrap) | No | — |
| calculator_page.dart | GridView (keypad) | SingleChildScrollView → Column | When scrolling | Optional |
| register_country_picker.dart | ListView | Bottom sheet Column → Flexible | Yes* | Optional |
| counter_sync_queue_inspector_button.dart | ListView | Sheet/dialog Column → Flexible | Yes* | Optional |
| platform_adaptive_sheets.dart | ListView | Sheet Column → Flexible | Yes* | Optional |

\* Necessary for “list in Column with Flexible” pattern; Slivers would avoid shrinkWrap.

**Excluded from table:** `MaterialTapTargetSize.shrinkWrap` (button tap target, not list/grid).

---

## 1. Scapes grid (Library demo) — **High impact** ✅ Done

**Files:** `lib/features/scapes/presentation/widgets/scapes_grid_content.dart`,
`lib/features/scapes/presentation/widgets/scapes_grid_view.dart`,
`lib/features/library_demo/presentation/widgets/library_demo_body.dart`

**Current:**
`ScapesGridContent()` is used inside `LibraryDemoBody` as:

```text
SingleChildScrollView
  └─ Column
       └─ … (header, search, categories, assets header)
       └─ if (isGridView) ScapesGridContent()  → ScapesGridView(shrinkWrap: true)
```

`ScapesGridView` uses `GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` so it sizes to its content and doesn’t scroll on its own. The whole column scrolls as one.

**Issue:**
With `shrinkWrap: true`, the grid lays out all items to compute height (no viewport-based lazy layout). For large lists this is more expensive and allocates more than a single-scroll Sliver approach.

**Recommendation:**
Prefer a single scroll with Slivers when the grid is embedded in the library demo:

- In **LibraryDemoBody**, when `isGridView` is true, stop nesting `ScapesGridContent()` inside the same `SingleChildScrollView` + `Column`.
- Use **CustomScrollView** with:
  - `SliverToBoxAdapter` (or similar) for the header block (title, search, categories, assets header).
  - A **SliverGrid** (or `SliverChildBuilderDelegate` with `SliverGridDelegateWithFixedCrossAxisCount`) for the scapes grid, using the same delegate logic as `ScapesGridView` (e.g. from `calculateGridLayout`).
- **ScapesGridContent** would then either:
  - Build that sliver (e.g. a widget that returns a `SliverGrid` / delegate) and the parent uses it in a `CustomScrollView`, or
  - Continue to accept a “sliver mode” and return a sliver when used inside a `CustomScrollView`, and keep the current `ScapesGridView(shrinkWrap: true)` only for the standalone ScapesPage (or other non–CustomScrollView usages) if needed.

**Implemented (2026-02-23):** When `isGridView` is true, **LibraryDemoBody** uses **CustomScrollView** with `SliverToBoxAdapter` for the header and **ScapesGridSliverContent** (→ **ScapesGridSliver**). **ScapesGridSliver** in `scapes_grid_view.dart` uses the same delegate/mainAxisExtent as `ScapesGridView` via `_computeScapesGridMetrics`. Library demo path no longer uses shrinkWrap for the grid. **Result:** One scroll, lazy layout via SliverGrid.

---

## 2. Calculator keypad — **Low priority**

**Files:** `lib/features/calculator/presentation/widgets/calculator_keypad.dart`,
`lib/features/calculator/presentation/pages/calculator_page.dart`

**Current:**

- When `shouldScroll` is true: `SingleChildScrollView` → `Column` → `CalculatorKeypad(shrinkWrap: true)` (and display, spacing).
- When false: `Column` → `Expanded(CalculatorKeypad())` (no shrinkWrap).

So `shrinkWrap: true` is only used in the “scrollable” layout so the keypad doesn’t take unbounded height.

**Recommendation:**
Acceptable as-is. The keypad has a fixed, small number of cells. If desired, the scrollable branch could be refactored to **CustomScrollView** + `SliverToBoxAdapter` for display + `SliverGrid` for the keypad to remove shrinkWrap; benefit is small.

---

## 3. Register country picker — **Optional**

**File:** `lib/features/auth/presentation/widgets/register_country_picker.dart`

**Current:**
`showModalBottomSheet` → `Column(mainAxisSize: MainAxisSize.min)` → title + `Flexible` → `ListView.builder(shrinkWrap: true)`.

**Recommendation:**
Reasonable pattern for a bottom sheet: list sizes to content. To remove shrinkWrap, use **CustomScrollView** in the sheet with `SliverToBoxAdapter` for the title and `SliverList`/`SliverChildBuilderDelegate` for the countries. Optional improvement.

---

## 4. Counter sync queue inspector — **Optional**

**File:** `lib/features/counter/presentation/widgets/counter_sync_queue_inspector_button.dart`

**Current:**
Bottom sheet / dialog: `Column(mainAxisSize: MainAxisSize.min)` → title + `Flexible` → `ListView.separated(shrinkWrap: true)`.

**Recommendation:**
Same as country picker: valid use of shrinkWrap in a sheet. Optional: **CustomScrollView** + `SliverToBoxAdapter` (title) + `SliverList` (or separated equivalent) to avoid shrinkWrap.

---

## 5. Platform adaptive sheets — **Optional**

**File:** `lib/shared/utils/platform_adaptive_sheets.dart`

**Current:**
Generic selection sheet: `Column` → header + `Flexible` → `ListView.builder(shrinkWrap: true)`.

**Recommendation:**
Same pattern; optional refactor to **CustomScrollView** + Slivers for consistency and to avoid shrinkWrap.

---

## Existing Sliver usage

- **profile_page.dart:** `CustomScrollView` with multiple `SliverToBoxAdapter` children — good pattern.
- **calculator_keypad.dart:** Uses `SliverGridDelegateWithFixedCrossAxisCount` for the grid delegate only; the scroll view is still `GridView.builder`. **scapes_grid_view.dart:** Also provides **ScapesGridSliver** for use in `CustomScrollView` (library demo).

---

## Action items (priority)

1. ~~**High:** Library demo + Scapes grid~~ **Done**
   - ~~Refactor **LibraryDemoBody** (and optionally **ScapesGridContent** / **ScapesGridView**) so the grid is in a **CustomScrollView** with a **SliverGrid** (or equivalent) when `isGridView` is true. Remove `shrinkWrap: true` for that path.~~

2. **Low / optional:**
   - Calculator: consider CustomScrollView + SliverGrid for the scrollable branch.
   - Country picker, sync queue inspector, platform_adaptive_sheets: consider CustomScrollView + SliverList for consistency and to remove shrinkWrap in sheets.

3. **Leave as-is:**
   - All `MaterialTapTargetSize.shrinkWrap` usages (buttons).
   - Calculator non-scrolling branch (Expanded keypad, no shrinkWrap).

---

## References

- Flutter: [Sliver widgets](https://api.flutter.dev/flutter/widgets/SliverWidget.html), [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html).
- Project: `tool/check_perf_shrinkwrap_lists.sh` flags `shrinkWrap: true` in presentation; this audit aligns with preferring Slivers where it makes sense.
