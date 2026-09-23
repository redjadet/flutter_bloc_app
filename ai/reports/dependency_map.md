---
ai_snapshot:
  generated_at: "2026-09-23T15:21:49Z"
  git_head: "84443f0cd5d4295441a360e3ab2cbcbdc4026b5d"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---

# Dependency map

**Source:** `bash tool/modular_metrics.sh` via `bash tool/refresh_ai_reports.sh`.

## Per-feature LOC (non-generated Dart)

<!-- refresh_ai_reports:feature_metrics:start -->
| Feature | LOC | Barrel |
| --- | ---: | --- |
| chat | 6588 | yes |
| staff_app_demo | 5532 | yes |
| todo_list | 5480 | yes |
| social_feed_demo | 5324 | yes |
| online_therapy_demo | 5089 | yes |
| case_study_demo | 4592 | yes |
| counter | 4398 | yes |
| native_platform_showcase | 3497 | yes |
| iot | 3075 | yes |
| iot_demo | 3001 | yes |
| example | 2421 | yes |
| auth | 2401 | yes |
| realtime_market | 2129 | yes |
| chart | 1972 | yes |
| graphql_demo | 1911 | yes |
| calculator | 1804 | yes |
| walletconnect_auth | 1510 | yes |
| google_maps | 1452 | yes |
| ai_decision_demo | 1440 | yes |
| in_app_purchase_demo | 1421 | yes |
| settings | 1342 | yes |
| profile | 1328 | yes |
| igaming_demo | 1278 | yes |
| supabase_auth | 1247 | yes |
| remote_config | 1236 | yes |
| library_demo | 1018 | yes |
| search | 1015 | yes |
| camera_gallery | 1015 | yes |
| production_readiness | 972 | yes |
| scapes | 943 | yes |
| websocket | 875 | yes |
| fcm_demo | 806 | yes |
| secure_messaging_demo | 758 | yes |
| genui_demo | 722 | yes |
| playlearn | 607 | yes |
| weather_demo | 547 | yes |
| deeplink | 547 | yes |
| certificate_pinning_demo | 496 | yes |
| notes_demo | 447 | yes |
| event_bus_demo | 302 | yes |
<!-- refresh_ai_reports:feature_metrics:end -->

## Fan-in (heuristic import counts)

| Target | ~Files |
| --- | ---: |
| `package:flutter_bloc_app/app/` | 346 |
| `package:flutter_bloc_app/shared/` | 0 (legacy; post-Melos) |
| `package:flutter_bloc_app/core/` | 0 (legacy; post-Melos) |

## Cross-feature imports

**0 edges** as of latest refresh. Regenerate:

```bash
bash tool/modular_metrics.sh --cross-feature-only
```

**Guidance:** Prefer explicit ports in `packages/auth/` or app composition when features need another backend’s session—see [`docs/modularity.md`](../../docs/modularity.md) and [`docs/engineering/flutter-anti-patterns.md`](../../docs/engineering/flutter-anti-patterns.md) (AP-01).

## Shared → feature imports

Metrics report: **(none)** — good.

## Regenerate

```bash
bash tool/refresh_ai_reports.sh
bash tool/modular_metrics.sh > /tmp/modular_metrics.txt
bash tool/modular_metrics.sh --cross-feature-only > /tmp/cross_feature.txt
```
