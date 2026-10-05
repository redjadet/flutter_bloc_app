# Dirty RenderObject marking docs

**Date:** 2026-10-05

## Summary

- Extended [`docs/architecture/custom_painter_and_render_object.md`](../architecture/custom_painter_and_render_object.md)
  with a **Dirty marking** section: `markNeedsLayout` / `markNeedsPaint` /
  `markNeedsSemanticsUpdate`, `PipelineOwner` flush order, and
  **relayout boundary ≠ `RepaintBoundary`**.
- Cross-linked from fundamentals pipeline blurb, performance stage table, and
  layout-constraints Related.
- Triggered by Medium fludev article fact-check against Flutter API +
  [Inside Flutter](https://docs.flutter.dev/resources/inside-flutter); closes
  the gap where markdown custom RO setters already call dirty APIs without
  living teaching.

## Verification

Docs-only. Link paths checked against existing architecture/performance owners.
No product code changes.
