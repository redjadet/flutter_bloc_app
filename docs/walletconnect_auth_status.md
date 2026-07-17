# WalletConnect Auth — status contract

**Status:** Demo-ready UI + Firebase linkage · **Not** production WalletConnect
SDK (service is mock/placeholder).

## Access

- Route: `/walletconnect-auth`
- Example page → **WalletConnect Auth (Demo)**
- Code: `apps/mobile/lib/features/walletconnect_auth/`
- **Auth-gated** via `AppRouteAuthGate` (signed-out deep links redirect to
  `/auth` then return)

## What is real

- Cubit + Freezed state, domain value objects, Firestore user doc at
  `users/{uid}` for wallet linkage/profile
- DI, routes, l10n, unit/bloc/repository tests

## What is mock

- `WalletConnectService` — no live WalletConnect protocol session

## Production gate (before shipping)

1. Replace mock service with official WalletConnect / Reown SDK.
2. Threat-model wallet signature + Firebase linking.
3. Confirm secrets stay out of client (see [`security_and_secrets.md`](security_and_secrets.md)).

## Related

- [`authentication.md`](authentication.md)
- [`feature_overview.md`](feature_overview.md)
