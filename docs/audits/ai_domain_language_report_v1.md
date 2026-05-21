---
generated: 2026-05-21
next: docs/domain/domain_glossary.md (Wave 2 SoT)
---

# Domain language report v1

Naming inventory for agents—**not** the glossary source of truth. Curate into [`docs/domain/domain_glossary.md`](../domain/domain_glossary.md) in Wave 2.

## Method

```bash
rg -o '\b([A-Z][a-zA-Z0-9]*(?:Cubit|Bloc|Repository|Service|UseCase|Failure|Exception|State|Event|Dto))\b' lib \
  --glob '*.dart' --glob '!**/*.freezed.dart' --glob '!**/*.g.dart' \
  | sort | uniq -c | sort -nr | head -80
```

## Top symbols by reference count (sample)

| Count | Symbol | Notes |
| ---: | --- | --- |
| 19 | `HiveCounterRepository` | Counter persistence |
| 17 | `OfflineFirstIotDemoRepository` | IoT sync |
| 16 | `RegisterFieldState` | Auth registration UI state |
| 15 | `CircuitState` | Shared HTTP circuit breaker |
| 15 | `ChatRemoteFailureException` | Chat errors (multiple mappers) |
| 14 | `WalletConnectAuthRepository` | Wallet feature |
| 14 | `SupabaseAuthState` | Supabase auth demo |
| 13 | `WebsocketConnectionState` | WebSocket demo |
| 13 | `CounterState` | Shared name—also in validator |
| 12 | `IotDemoState` | IoT presentation |

(Full histogram in preflight `/tmp/ai_first_terms_freq.txt`—regenerate locally.)

## Overloaded / ambiguous terms

| Term | Locations | Guidance |
| --- | --- | --- |
| `CounterState` | `counter` feature + `state_transition_validator` | Qualify imports; do not rename without audit |
| `ChatRemoteFailureException` | Multiple `chat/data/*` mappers | Consolidate (ARCH-006) |
| `*Repository` | 80+ types | Always prefix with feature in new code (`ChatRepository`, not `Repository`) |
| `*State` | Cubit states across features | Feature-scoped names only |

## Duplicates to resolve in glossary (Wave 2)

1. Auth vs Supabase auth vs WalletConnect auth boundaries.
2. “Demo” suffix features (`*_demo`) vs production-shaped modules (`counter`, `auth`).
3. Offline-first repository naming (`OfflineFirst*` vs `Hive*` vs `Persistent*`).

## Do not rename (stability)

- Public route names in `app_routes.dart`
- Hive box keys and migration type names
- Generated Freezed class names without migration plan

## Pilot glossary terms (seed for Wave 2)

| Term | Meaning |
| --- | --- |
| Feature module | `lib/features/<name>/` vertical slice |
| Offline-first repository | Local write + pending sync queue |
| Pending sync | `PendingSyncRepository` outbound mutations |
| Feature Brief | Pre-implementation doc ([`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md)) |
