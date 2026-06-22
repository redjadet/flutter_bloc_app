# Testing Matrix Required By Change

Cursor and Codex agents use this matrix before reporting done. It turns testing
choice into a deterministic routing step.

| Change | Minimum tests | Escalate when |
| --- | --- | --- |
| Domain model/value rule | Unit tests for constructors, derived getters, equality, edge values | Model affects persistence or API payload |
| Repository contract | Fake-backed unit tests for success, failure, empty, and stream/watch behavior | Offline-first, retry, sync, auth, or cache policy changes |
| DTO/mapper | Mapper tests for valid, missing, unknown, malformed fields | Stored/API shape changes |
| Cubit/BLoC | Cubit/bloc tests for initial, loading, success, error, retry, stale async | Timers, streams, lifecycle, or shared state involved |
| Page/widget state | Widget tests for loading, empty, success, error, action callbacks | Layout responsive, route, auth, or l10n behavior changed |
| Route/auth gate | `./bin/router_feature_validate` plus focused route/widget tests | App shell, redirect, deep link, or auth repository changed |
| UI/design system | Widget proof at relevant widths; `./tool/check_design_md.sh` if [`DESIGN.md`](../../DESIGN.md) changed | Shared components, Mix, theme, or typography changed |
| Golden / visual regression | Golden tests for shared design-system widgets or stable visual contracts; update with `flutter test --update-goldens` after intentional visual change or Flutter upgrade | New/changed shared widget in `lib/shared/`, theme token, or typography affecting goldens |
| Offline-first/sync | Repository/unit tests plus existing sync regression anchors; for remote merge, add TOCTOU re-read tests per [`offline_first/dont_overwrite_guide.md`](offline_first/dont_overwrite_guide.md) | Queue replay, conflict merge, lifecycle, or background coordinator touched |
| Native/platform | Focused platform build/check from validation routing | iOS/macOS/Android dependencies, entitlements, pods/SPM touched |
| Example demo showcase | Unit + widget under `test/features/<feature>/`; `./bin/router_feature_validate` when route/deeplink changes; device integration via selective map (e.g. `native_platform_showcase` → `integration_test/native_platform_showcase_flow_test.dart`); web reachability in `test/integration_preflight/web_bootstrap_smoke_test.dart` when no `kIsWeb` guard | `PlatformAdaptive` layout, Example entry, or journey **J6** in [`integration_journey_map.md`](../engineering/integration_journey_map.md) |
| Docs/tooling only | `./bin/checklist-fast` and doc/tool-specific check | Validation policy, host templates, or repo-wide rules changed |

## Skip Rules

Tests may be skipped only when the change is docs-only, formatting-only, or a
mechanical rename already covered by analyzer and existing tests. Record
`Tests: N/A - <reason>` in the feature brief, change note, or final report.

## Feature Brief Contract

Non-trivial `lib/features/**` changes should fill
[`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md). Cursor and Codex should
run:

```bash
bash tool/check_feature_brief_linked.sh
```

before broad implementation unless the change is a documented trivial fix.

## Proof Order

1. Run focused tests named by the changed behavior.
2. Run `./tool/analyze.sh` for Dart/app code.
3. Add router/integration/native lanes when path triggers require them; resolve
   selective device integration with
   [`tool/integration_selective_map.json`](../../tool/integration_selective_map.json)
   (`python3 tool/integration_selective_resolve.py`).
4. Run `./bin/checklist` for broad, shared, pre-ship, or uncertain blast radius.
