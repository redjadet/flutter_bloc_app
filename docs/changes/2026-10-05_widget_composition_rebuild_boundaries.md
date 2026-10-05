# Widget composition and rebuild boundaries (docs)

## Why

Medium article prompt on Flutter widget architecture (intentional composition vs
file splits; giant `build()`; rebuilds/keys/Element boundaries). Official Flutter
already teaches widgets-over-helper-methods and change-local splits; this repo
had three-tree/`canUpdate`/keys teaching (#972) and leaf-widget reuse contracts,
but no living page for composition vs `_build*` helpers.

## Change

- Added
  [`engineering/widget_composition_and_rebuild_boundaries.md`](../engineering/widget_composition_and_rebuild_boundaries.md).
- Indexed from [`engineering/README.md`](../engineering/README.md).
- Clarified [`CODE_QUALITY.md`](../CODE_QUALITY.md) file-size extract guidance
  (widgets over helpers) with a link to the new page.

## Ownership

Widget identity / keys remain in
[`engineering/flutter_fundamentals_and_production_practices.md`](../engineering/flutter_fundamentals_and_production_practices.md).
Leaf preview/test contract remains in [`design_system.md`](../design_system.md).
Dirty RenderObject marking is a separate track
([PR #984](https://github.com/redjadet/flutter_bloc_app/pull/984)) — not edited
here.

## Validation

```bash
bash tool/check_docs_gardening.sh --paths \
  docs/engineering/widget_composition_and_rebuild_boundaries.md \
  docs/engineering/README.md \
  docs/CODE_QUALITY.md \
  docs/changes/2026-10-05_widget_composition_rebuild_boundaries.md \
  docs/changes/README.md
```
