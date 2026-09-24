---
ai_snapshot:
  generated_at: "2026-09-24T13:42:53Z"
  git_head: "cb935a043a07077910cbaef0dbc0665aa5e0c267"
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
| chat | 6600 | yes |
| staff_app_demo | 5629 | yes |
| todo_list | 5514 | yes |
| social_feed_demo | 5389 | yes |
| online_therapy_demo | 5089 | yes |
| case_study_demo | 4592 | yes |
| counter | 4398 | yes |
| native_platform_showcase | 3497 | yes |
| iot | 3075 | yes |
| iot_demo | 3025 | yes |
| example | 2421 | yes |
| auth | 2403 | yes |
| realtime_market | 2129 | yes |
| chart | 1978 | yes |
| graphql_demo | 1900 | yes |
| calculator | 1805 | yes |
| walletconnect_auth | 1510 | yes |
| google_maps | 1443 | yes |
| ai_decision_demo | 1440 | yes |
| in_app_purchase_demo | 1421 | yes |
| settings | 1345 | yes |
| profile | 1336 | yes |
| igaming_demo | 1290 | yes |
| supabase_auth | 1262 | yes |
| remote_config | 1236 | yes |
| library_demo | 1018 | yes |
| search | 1015 | yes |
| camera_gallery | 1015 | yes |
| production_readiness | 972 | yes |
| scapes | 943 | yes |
| websocket | 875 | yes |
| fcm_demo | 812 | yes |
| secure_messaging_demo | 780 | yes |
| genui_demo | 722 | yes |
| playlearn | 607 | yes |
| deeplink | 549 | yes |
| weather_demo | 547 | yes |
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
