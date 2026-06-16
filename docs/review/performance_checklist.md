# Performance Review Checklist

Use before accepting Cursor/Codex UI, Cubit, repository, or list-heavy changes.
Findings must cite files and the violated rule.

Primary references:
[`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md),
[`ai_code_review_protocol.md`](../ai_code_review_protocol.md) (Performance row).

## Rebuild Scope

- `BlocBuilder` / selectors listen to the smallest state slice needed.
- Heavy `build()` work is not repeated on unrelated state changes.
- Const constructors and stable keys used where lists reorder or filter.
- Run `bash tool/check_perf_unnecessary_rebuilds.sh` on presentation changes.

## Lists and Layout

- Long lists use builder constructors — not eager `children:` lists.
- `shrinkWrap: true` is justified and bounded; prefer slivers when nested.
- Repaint boundaries added for expensive list cells or animations when needed.
- Builder rows use `ValueKey` with durable domain ids (not index-only or
  `ObjectKey` on per-tick model instances). Run `bash tool/check_widget_identity.sh`
  on list-heavy presentation diffs.
- Run `bash tool/check_perf_nonbuilder_lists.sh` and
  `bash tool/check_perf_shrinkwrap_lists.sh` on layout-sensitive diffs.
- Run `bash tool/check_perf_missing_repaint_boundary.sh` when scroll jank is
  plausible.

## Async and I/O

- No N+1 network or disk calls inside loops or per-item builders.
- Parsing, decoding, and mapping run off the UI isolate when payloads are large.
- Polling intervals and stream subscriptions are cancelled in `close()` /
  dispose paths.
- In-flight coalescing or request freshness guards exist for hot async paths.

## Memory and Lifecycle

- Streams, timers, and controllers disposed in Cubit `close()` or widget
  dispose.
- Large caches have bounds or eviction; images use repo sizing conventions.
- Run lifecycle checks from validation routing when subscriptions or timers
  changed.

## Scale and Edge Cases

- Empty, large, and concurrent update paths considered for lists and forms.
- Offline/resume does not replay unbounded work on the main isolate.
- Document known tradeoffs in feature brief **Risks** when deferring optimization.

## Proof

Minimum: focused widget/cubit tests for changed states; perf scripts above when
triggers match. Escalate to `./bin/checklist` for shared infrastructure, sync,
or cross-feature performance changes.
