# Feature: InheritedWidget audit — theme-following pen color and composer controller disposal

**Date:** 2026-10-22

## Problem

An audit against the Flutter "InheritedWidget & InheritedElement" material
found no hand-written `InheritedWidget`, `InheritedModel`, or
`InheritedNotifier` in `apps/` or `packages/`. Scopes come from
`BlocProvider`, `RepositoryProvider`, `ResponsiveScope`, and Mix's
`MixScope`, and those compare values correctly. Two presentation bugs in the
same area did turn up:

- `WhiteboardWidget` cached `Theme.of(context).colorScheme.onSurface` into
  `_currentColor` with `??=` in `didChangeDependencies`. The call subscribed to
  `Theme`, but the field kept the first theme's color. After a light→dark
  switch the default pen stayed dark on a dark canvas.
- `SocialFeedCommentComposer.show` created a `TextEditingController` (a
  `ChangeNotifier`) and never disposed it. `leak_tracker` reports it as
  `notDisposed`.

[`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md)
also lacked the element-level mechanics (exact-type O(1) lookup, dependents
map, notification flow), a custom-scope checklist, `InheritedModel` aspects,
`InheritedNotifier` ownership, `InheritedTheme` capture, and the
Provider/flutter_bloc internals.

## Scope

- In: whiteboard default pen color; comment-sheet controller ownership;
  regression tests; deep-dive doc sections.
- Out: Cubits, repositories, routes, l10n, state classes, new lints or guards.

## Layers touched

- [ ] domain
- [ ] data
- [x] presentation
- [ ] DI
- [ ] routes / l10n

## Contracts

- Whiteboard: with no user-picked color, the pen and toolbar swatch use the
  current `colorScheme.onSurface`. A picked color is kept across theme
  changes. Strokes already drawn keep their color.
- Comment sheet: same field/submit keys, validation, submit flow, and
  "keep sheet + draft on rejection". The controller is disposed when the
  sheet's `State` is disposed, after the exit animation.

## Behavior contract (define before implementation)

- Must remain true: comment submit pops the sheet only when the Cubit
  accepts; the whiteboard keeps undo/redo/clear and the picked color.
  Owner: those two widgets.
- Inputs: theme switch while the whiteboard is mounted; open, type, and
  close the comment sheet.
- Failure/recovery: none new.
- Source of expected results: Flutter `InheritedElement` /
  `State.didChangeDependencies` API docs and `leak_tracker`.

## What changed

Presentation:

- `apps/mobile/lib/features/example/presentation/widgets/whiteboard/whiteboard_widget.dart`:
  removed the `didChangeDependencies` cache; `_effectiveColor` already falls
  back to the theme.
- `apps/mobile/lib/features/social_feed_demo/presentation/widgets/social_feed_comment_composer.dart`:
  the sheet body is a private `StatefulWidget` that owns and disposes the
  controller.

Docs:

- [`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md):
  new "How `InheritedElement` propagates changes" section (mechanics, custom
  scope checklist, Provider/flutter_bloc internals), two project rows, one
  review question, and sources. Builds on the lookup table from
  [`2026-10-22_buildcontext_guidance.md`](2026-10-22_buildcontext_guidance.md)
  without repeating it.

## Tests (executable contract)

- `apps/mobile/test/features/example/presentation/widgets/whiteboard_widget_test.dart`:
  `default pen color follows the theme after a theme switch` (fails on the old code).
- `apps/mobile/test/features/social_feed_demo/presentation/widgets/social_feed_comment_composer_test.dart`:
  `comment sheet disposes its draft controller after closing`
  (`leakSafeTestWidgets`, fails on the old code with
  `notDisposed: TextEditingController`).

### Proof command

- `./bin/checklist`

## Docs

- [x] This note, indexed from [`docs/changes/README.md`](README.md)
- [x] Living practice in
  [`engineering/build_context_deep_dive.md`](../engineering/build_context_deep_dive.md)
- [ ] [`feature_overview.md`](../feature_overview.md) — unchanged

## Risks

Low. Default-color strokes drawn before a theme switch keep their old color
(unchanged behavior).

## depends_on

- None.

## blocks

- None.

## merge_order

- Single PR.

## rollback

- Revert the commit.

## proof_commands

```bash
bash tool/check_feature_brief_linked.sh --base origin/main
bash tool/run_memory_leak_tests.sh
bash tool/check_docs_gardening.sh --paths docs/changes/2026-10-22_inheritedwidget_audit.md docs/changes/README.md docs/engineering/build_context_deep_dive.md
```
