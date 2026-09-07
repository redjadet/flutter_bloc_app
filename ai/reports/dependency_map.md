---
ai_snapshot:
  generated_at: "2026-09-07T09:08:14Z"
  git_head: "0d2658d6dd858b32d5ff755105eda8abd0533d59"
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
| chat | 6627 | yes |
| staff_app_demo | 5538 | yes |
| todo_list | 5517 | yes |
| social_feed_demo | 5372 | yes |
| online_therapy_demo | 5136 | yes |
| case_study_demo | 4713 | yes |
| counter | 4446 | yes |
| native_platform_showcase | 3516 | yes |
| iot_demo | 3180 | yes |
| iot | 3092 | yes |
| auth | 2402 | yes |
| example | 2392 | yes |
| realtime_market | 2131 | yes |
| graphql_demo | 1980 | yes |
| chart | 1971 | yes |
| calculator | 1805 | yes |
| walletconnect_auth | 1510 | yes |
| google_maps | 1453 | yes |
| in_app_purchase_demo | 1431 | yes |
| ai_decision_demo | 1375 | yes |
| profile | 1374 | yes |
| settings | 1357 | yes |
| igaming_demo | 1279 | yes |
| supabase_auth | 1247 | yes |
| remote_config | 1247 | yes |
| search | 1090 | yes |
| camera_gallery | 1023 | yes |
| library_demo | 1018 | yes |
| scapes | 946 | yes |
| production_readiness | 939 | yes |
| websocket | 875 | yes |
| fcm_demo | 810 | yes |
| secure_messaging_demo | 758 | yes |
| genui_demo | 712 | yes |
| playlearn | 607 | yes |
| deeplink | 547 | yes |
| certificate_pinning_demo | 496 | yes |
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
