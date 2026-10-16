# Change note: teach official Flutter release size flags

**Date:** 2026-10-16  
**Branch:** `cursor/interview-app-size-flags-d7ce`

## Why

Interview “app size + cold start” teaching named `--split-debug-info`, symbol
stripping / obfuscation, and `--split-per-abi`. Living
[`bundle_size_monitoring.md`](../performance/bundle_size_monitoring.md) already
covered budgets, `--analyze-size`, deferred imports, assets, and ProGuard, but
omitted Flutter’s primary Dart size flags from
[app size](https://docs.flutter.dev/perf/app-size) /
[obfuscate](https://docs.flutter.dev/deployment/obfuscate).

Same bar as dirty-RO / widget-composition teaching fills: practice-adjacent
shipping guidance without a living pointer.

## What changed

- Added **Official Dart release size flags** section to
  `docs/performance/bundle_size_monitoring.md` (flags table, example, CI caution).
- Added **Release size** bullets to `docs/review/performance_checklist.md`.

## Explicitly not done

- No CI dry-run switch to `--obfuscate` (needs symbol retention / Crashlytics
  upload plan first).
- No product or build-script changes.
- No restatement of isolate / rebuild / BLoC interview topics (already covered).
