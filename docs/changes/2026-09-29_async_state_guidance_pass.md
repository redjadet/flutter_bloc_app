# 2026-09-29 — Async state guidance pass (Cubit-first)

## Summary

Fact-checked a Medium-intro / official-docs draft on Flutter async-state
lifecycle and aligned this repo’s guidance + one widget anti-pattern with
Cubit-first practice. Did not reproduce paywalled Medium body.

## Accuracy (draft)

Mostly correct. Required corrections / nuance captured in
[`flutter_fundamentals_and_production_practices.md`](../engineering/flutter_fundamentals_and_production_practices.md)
§ Async state:

- Explicit `initial → loading → success|empty|error → retry` — correct.
- Refresh should retain prior data when UX allows — correct; Riverpod
  `skipLoadingOnRefresh` is contrast only.
- `AsyncSnapshot.hasData` means `data != null` (empty list ≠ null) — correct.
- Future outside `build` — official FutureBuilder contract.
- Dispose cancel alone does not make bare Futures safe — request identity /
  ignore stale completions required.
- Cubit/BLoC primary here; FutureBuilder/AsyncValue only as local contrast.

## Changes

| Area | Change |
| --- | --- |
| Docs | Cubit-first async section in fundamentals; refresh-retain + FutureBuilder rules in [`bloc_standards.md`](../bloc_standards.md) / [`state_management_choice.md`](../architecture/state_management_choice.md); AP-19 in anti-patterns; index blurbs |
| Code | `ResilientSvgAssetImage` stores load `Future` on `State` (init/didUpdateWidget), not in `build` |
| Tests | Rebuild during wait must not restart load (`debugLoadStarts`) |

## Validation

```bash
cd apps/mobile && flutter test test/shared/widgets/resilient_svg_asset_image_test.dart
bash tool/check_docs_gardening.sh --paths \
  docs/bloc_standards.md \
  docs/architecture/state_management_choice.md \
  docs/engineering/flutter_fundamentals_and_production_practices.md \
  docs/engineering/flutter-anti-patterns.md \
  docs/engineering/README.md \
  docs/README.md \
  docs/changes/2026-09-29_async_state_guidance_pass.md \
  docs/changes/README.md
```
## Out of scope

Medium paywalled body; Flutter SDK version pins; Riverpod adoption; mass Cubit
refresh audits beyond documented exemplars (chart, social feed).
