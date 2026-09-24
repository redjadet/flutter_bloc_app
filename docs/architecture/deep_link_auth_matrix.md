# Deep-link auth redirect matrix

**Date:** 2026-09-24  
**Code:** `apps/mobile/lib/app/router/route_auth_policy.dart`,
`app_route_auth_gate.dart`, `auth_redirect.dart`  
**Tests:** `apps/mobile/test/app/router/app_route_auth_gate_test.dart`,
`auth_redirect_test.dart`

`createAuthRedirect` is a coarse deep-link-friendly guard. **Route-level**
`AppRouteAuthGate` + `AppRoutePolicies` own which destinations require a
signed-in user after navigation lands (closes the historical tradeoff note in
[`tradeoffs_and_future.md`](tradeoffs_and_future.md)).

## Matrix

| Path constant | Path | Requirement | Unauthenticated deep link |
| --- | --- | --- | --- |
| `settings` | `/settings` | Public | Shows settings |
| `profile` | `/profile` | Authenticated | → `/auth?redirect=%2Fprofile` |
| `manageAccount` | `/manage-account` | Authenticated | → auth + safe redirect |
| `walletconnectAuth` | `/walletconnect-auth` | Authenticated | → auth + redirect |
| `caseStudyDemo` | `/case-study-demo` | Authenticated | → auth + redirect |
| `staffAppDemo` | `/staff-app-demo` | Authenticated | → auth + redirect |
| `onlineTherapyDemoAdmin` | `/online-therapy-demo/admin` | Authenticated | → auth + redirect |
| `onlineTherapyDemoAdminVerification` | `…/admin/verification` | Authenticated | → auth + redirect |
| `onlineTherapyDemoAdminAudit` | `…/admin/audit` | Authenticated | → auth + redirect |

Public interview spine routes (`/`, `/todo-list`, `/chat-list`, …) remain
reachable without Firebase sign-in unless a nested page wraps
`AppRouteAuthGate`.

## Proof

```bash
cd apps/mobile
flutter test test/app/router/app_route_auth_gate_test.dart test/app/router/auth_redirect_test.dart
```

Adding a gated route: extend `AppRoutePolicies`, wrap the page with
`AppRouteAuthGate`, add a matrix row + policy unit test.
