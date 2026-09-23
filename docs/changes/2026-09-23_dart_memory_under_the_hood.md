# Dart memory under the hood (heap / GC / lifetimes)

**Date:** 2026-09-23

## Why

Agents and reviewers need a shared mental model: Dart GC frees *unreachable*
heap objects eventually; leaks are usually retention (caches, listeners,
closures), not a broken collector. GC does not replace dispose; DevTools
investigation must separate heap / external / RSS.

## In

- Canon doc: [`docs/performance/dart_memory_under_the_hood.md`](../performance/dart_memory_under_the_hood.md)
- Hub/checklist/lints/testing/review/fundamentals/reliability/CODE_QUALITY links
- `CalculatorFormatters.trimMemory` on pressure; wired via
  `AppMemoryService.onStaticCacheTrim` (renamed from `onChartMemoryTrim`) with
  chart + locale formatter caches
- Why-comments on static chart/formatter caches and `AppMemoryService`

## Out / not in this change

- New AST lint for closure-captured `BuildContext` (still Wave B backlog)
- Changing chart TTL or image-cache policy beyond wiring
