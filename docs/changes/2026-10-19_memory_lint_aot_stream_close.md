# memory_lint AOT restore + StreamController close hooks — 2026-10-19

## Summary

Unblocked native `memory_lint` AOT compile (analyzer 14 `Argument` AST) and
satisfied `memory_stream_controller_missing_close` at social-feed teardown
helpers plus the perf TodoRepository stub so CI Step 3 `flutter analyze` stays
green once the plugin loads.

## Feature brief

- Feature: [social_feed_demo](../features/social_feed_demo.md)
- Scope: data-layer teardown naming only (`close()` wrapping existing
  `_shutdown` / controller close paths); no product UX change
- Also: `integration_test/perf/perf_repos.dart` stub `close()` for the same lint

## Changes

- `custom_lints/memory_lint` rule + `tool/run_memory_lint.sh` preflight (fail closed)
- `simulated_social_feed_realtime_source.dart`: `_shutdown` → `close()`
- `offline_first_social_feed_repository_replay.part.dart`: shared `close()`
- `integration_test/perf/perf_repos.dart`: `_PerfTodoRepository.close()`

## Verification

```bash
cd custom_lints/memory_lint && dart analyze lib && dart test
bash tool/run_memory_lint.sh
cd apps/mobile && flutter analyze --no-pub
cd apps/mobile && dart analyze .
```
