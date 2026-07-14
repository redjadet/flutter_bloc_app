---
ai_snapshot:
  generated_at: "2026-07-14T16:26:48Z"
  git_head: "0d5ea373df32c1577235e19c49bcac1f9f2d6117"
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
| chat | 6728 | yes |
| staff_app_demo | 5443 | yes |
| online_therapy_demo | 5340 | yes |
| todo_list | 5311 | yes |
| case_study_demo | 4606 | yes |
| counter | 4331 | yes |
| iot_demo | 3190 | yes |
| iot | 3190 | yes |
| auth | 2316 | yes |
| example | 2312 | yes |
| realtime_market | 2186 | yes |
| chart | 2001 | yes |
| graphql_demo | 1974 | yes |
| native_platform_showcase | 1898 | yes |
| calculator | 1867 | yes |
| walletconnect_auth | 1560 | yes |
| google_maps | 1493 | yes |
| ai_decision_demo | 1426 | yes |
| profile | 1406 | yes |
| in_app_purchase_demo | 1363 | yes |
| igaming_demo | 1342 | yes |
| supabase_auth | 1261 | yes |
| remote_config | 1231 | yes |
| settings | 1229 | yes |
| search | 1095 | yes |
| library_demo | 1045 | yes |
| camera_gallery | 1039 | yes |
| scapes | 992 | yes |
| websocket | 859 | yes |
| fcm_demo | 813 | yes |
| genui_demo | 736 | yes |
| playlearn | 673 | yes |
| deeplink | 521 | yes |
| certificate_pinning_demo | 507 | yes |
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

**Guidance:** Prefer explicit ports in `packages/auth/` or app composition when features need another backend’s session—see [`docs/modularity.md`](../../docs/modularity.md) and [`docs/flutter-anti-patterns.md`](../../docs/flutter-anti-patterns.md) (AP-01).

## Shared → feature imports

Metrics report: **(none)** — good.

## Regenerate

```bash
bash tool/refresh_ai_reports.sh
bash tool/modular_metrics.sh > /tmp/modular_metrics.txt
bash tool/modular_metrics.sh --cross-feature-only > /tmp/cross_feature.txt
```
