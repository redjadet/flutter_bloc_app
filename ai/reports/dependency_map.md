---
ai_snapshot:
  generated_at: "2026-09-03T09:31:07Z"
  git_head: "23203591dd20ed9c8d6379385d61f0dec619c21d"
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
| chat | 6759 | yes |
| staff_app_demo | 5651 | yes |
| todo_list | 5594 | yes |
| social_feed_demo | 5316 | yes |
| online_therapy_demo | 5269 | yes |
| case_study_demo | 4777 | yes |
| counter | 4525 | yes |
| native_platform_showcase | 3593 | yes |
| iot_demo | 3269 | yes |
| iot | 3149 | yes |
| auth | 2487 | yes |
| example | 2415 | yes |
| realtime_market | 2172 | yes |
| graphql_demo | 2042 | yes |
| chart | 2021 | yes |
| calculator | 1862 | yes |
| walletconnect_auth | 1560 | yes |
| google_maps | 1493 | yes |
| in_app_purchase_demo | 1467 | yes |
| ai_decision_demo | 1408 | yes |
| settings | 1399 | yes |
| profile | 1399 | yes |
| igaming_demo | 1328 | yes |
| remote_config | 1280 | yes |
| supabase_auth | 1259 | yes |
| search | 1126 | yes |
| library_demo | 1044 | yes |
| camera_gallery | 1038 | yes |
| scapes | 989 | yes |
| production_readiness | 958 | yes |
| websocket | 897 | yes |
| fcm_demo | 884 | yes |
| genui_demo | 735 | yes |
| playlearn | 660 | yes |
| deeplink | 556 | yes |
| certificate_pinning_demo | 502 | yes |
| event_bus_demo | 311 | yes |
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
