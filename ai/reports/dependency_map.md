---
ai_snapshot:
  generated_at: "2026-07-17T18:59:48Z"
  git_head: "1cd35d48e57dc8ba9c85709b3866b9449d573049"
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
| chat | 6833 | yes |
| staff_app_demo | 5701 | yes |
| online_therapy_demo | 5340 | yes |
| todo_list | 5308 | yes |
| case_study_demo | 4692 | yes |
| counter | 4377 | yes |
| native_platform_showcase | 3464 | yes |
| iot_demo | 3291 | yes |
| iot | 3190 | yes |
| auth | 2477 | yes |
| example | 2312 | yes |
| realtime_market | 2186 | yes |
| graphql_demo | 2057 | yes |
| chart | 2028 | yes |
| calculator | 1867 | yes |
| walletconnect_auth | 1560 | yes |
| ai_decision_demo | 1536 | yes |
| google_maps | 1493 | yes |
| profile | 1406 | yes |
| in_app_purchase_demo | 1363 | yes |
| igaming_demo | 1334 | yes |
| supabase_auth | 1261 | yes |
| remote_config | 1259 | yes |
| settings | 1229 | yes |
| search | 1136 | yes |
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
