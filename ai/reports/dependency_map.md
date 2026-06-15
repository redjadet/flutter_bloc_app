# Dependency map

**Source:** `bash tool/modular_metrics.sh` (2026-05-21T17:13:13Z).

## Per-feature LOC (non-generated Dart)

| Feature | LOC | Barrel |
| --- | ---: | --- |
| chat | 6384 | yes |
| todo_list | 5166 | yes |
| online_therapy_demo | 4578 | yes |
| staff_app_demo | 4558 | no |
| counter | 3983 | yes |
| case_study_demo | 3711 | no |
| iot_demo | 3056 | yes |
| auth | 2293 | yes |
| example | 2257 | yes |
| realtime_market | 2073 | yes |
| chart | 1991 | yes |
| calculator | 1861 | yes |
| graphql_demo | 1850 | yes |
| google_maps | 1425 | yes |
| walletconnect_auth | 1413 | yes |
| profile | 1383 | yes |
| settings | 1219 | yes |
| remote_config | 1198 | yes |
| igaming_demo | 1191 | no |
| in_app_purchase_demo | 1149 | yes |
| supabase_auth | 1128 | yes |
| search | 1088 | yes |
| library_demo | 1010 | no |
| scapes | 935 | yes |
| ai_decision_demo | 858 | yes |
| websocket | 776 | yes |
| fcm_demo | 749 | yes |
| camera_gallery | 707 | yes |
| genui_demo | 680 | yes |
| playlearn | 640 | yes |
| deeplink | 514 | yes |

## Fan-in (heuristic import counts)

| Target | ~Files |
| --- | ---: |
| `package:flutter_bloc_app/shared/` | 497 |
| `package:flutter_bloc_app/core/` | 166 |
| `package:flutter_bloc_app/app/` | 10 |

## Cross-feature imports

**0 edges** as of 2026-06-15 (staff review R6 / AP-01). Prior snapshot (2026-05-21) listed **11** edges including chat→`supabase_auth` and `case_study_demo`→`camera_gallery` / `supabase_auth`.

Regenerate:

```bash
bash tool/modular_metrics.sh --cross-feature-only
```

**Guidance:** Prefer shared domain types in `lib/shared/` or explicit ports in `lib/core/` when features need another backend’s session—see [`docs/modularity.md`](../../docs/modularity.md) and [`docs/flutter-anti-patterns.md`](../../docs/flutter-anti-patterns.md) (AP-01).

## Shared → feature imports

Metrics report: **(none)** — good.

## Regenerate

```bash
bash tool/modular_metrics.sh > /tmp/modular_metrics.txt
bash tool/modular_metrics.sh --cross-feature-only > /tmp/cross_feature.txt
```
