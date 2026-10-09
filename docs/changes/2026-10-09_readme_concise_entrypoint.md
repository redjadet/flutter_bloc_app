# Concise README and complete screenshot gallery

**Date:** 2026-10-09
**Scope:** Documentation only.

## Summary

Make the main README a short entrypoint: key badges first, a brief introduction,
quick start, four reviewer paths, and links to detailed guides. Selected
screenshots form the final section. The complete gallery retains all 33 original
images, captions, and alternate text in an existing documentation category.

This delivery also includes the [human–AI documentation refinements](2026-10-09_ai_typing_human_focus_triad.md).
Delegating implementation effort preserves human understanding and acceptance
responsibility; architecture, intent, and edge cases remain explicit decisions.

## Files changed

| File | Change |
| --- | --- |
| [Main README](../../README.md) | Reduce 174 lines to 63; retain key badges, quick start, four reviewer paths, detailed-guide links, and two closing screenshots |
| [Evidence](../EVIDENCE.md#contribution-and-ai-assistance) | Own the existing contribution and AI-assistance explanation, moved from README |
| [Screenshot gallery](../features/screenshots.md) | Preserve all 33 captured screens with corrected relative paths |
| [Docs index](../README.md), [feature index](../features/README.md) | Link the full gallery |
| [Changes index](README.md) | Link this note and the human–AI refinements |
| [Task tracker](../../tasks/codex/readme-human-ai-docs/todo.md) | Record the combined write-set, risks, proof, and delivery status |

## Validation

Use the documentation-only lane in [validation routing](../engineering/validation_routing_fast_vs_full.md).
Validate local links and anchors, image-path preservation, badge contracts,
documentation gates, and rendered layout. Dart format, analyze, and Flutter
tests are N/A: no application, dependency, tool, or CI inputs change.

Exact results and delivery evidence are recorded in the [task tracker](../../tasks/codex/readme-human-ai-docs/todo.md).
The dated application/native test evidence in [`EVIDENCE.md`](../EVIDENCE.md) is unchanged.

## Recovery

Revert the documentation commit if the entrypoint, gallery, or links regress.
No runtime data, configuration, or resource lifecycle changes.
