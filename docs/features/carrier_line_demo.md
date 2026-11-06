# Carrier line demo (business phone line)

Thin Senior Mobile surface for an AI-native **carrier-product narrative**:
local activity inbox, **simulated** realtime connection, and eSIM / porting /
billing **status cards**. Built on Clean Architecture + **Cubit** (not Riverpod).

ADR-0005: added as **Depth** by retiring Archive `weather_demo` — see
[`2026-11-06_carrier_line_demo_archive_swap.md`](../changes/2026-11-06_carrier_line_demo_archive_swap.md).

## Open

Navigate to `/carrier-line-demo` (route name `carrier-line-demo`).  
Blocked in prod/release flavors (redirects to counter).

## Honesty

| Surface | What it is | What it is not |
| --- | --- | --- |
| Activity list | Synthetic rows in local Hive (seed-once) | Carrier SMS/calls, threads, sync |
| Connection chip | Deterministic simulated WS-shaped client | Live echo, carrier reachability |
| Status cards | One stub fixture on design-system cards | Real eSIM / porting / billing APIs |
| Push | Composes shared `FcmMessagingService` | Interactive register UI (P1) |

## Layers

```
apps/mobile/lib/features/carrier_line_demo/
  domain/        ports + models
  data/          Hive activity + stubs
  presentation/  CarrierLineCubit + page + DS widgets
```

DI: `registerCarrierLineDemoServices()` + `FcmMessagingService` from FCM demo DI  
Route: `CarrierLineDemoRouteFactory`

## State management

Job descriptions that say “Riverpod or similar” map here to Cubit + repository
ports + GetIt. See
[Cubit ↔ Riverpod JD mapping](../architecture/cubit_riverpod_jd_mapping.md).
Do not migrate.

## Related adjacent evidence

- Offline-first counter + queue replay → [`docs/EVIDENCE.md`](../EVIDENCE.md)
- Live WebSocket demo → `features/websocket`
- FCM push demo → `features/fcm_demo`
- Design tokens → `packages/design_system`

## Non-goals (P0)

- CallKit / ConnectionService / WebRTC
- Interactive push registration UI
- Remote sync / outbound messages
- Example hub button (P1)
