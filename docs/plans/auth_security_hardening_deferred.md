# Auth security hardening — deferred work

**Status:** Shipped baseline — PR A (Firebase coordinator), PR B (Supabase manager), PR C
(`AppAuthCubit` UX). See change notes
[`2026-06-28_auth-security-hardening-pr-a.md`](../changes/2026-06-28_auth-security-hardening-pr-a.md)
through
[`pr-c`](../changes/2026-06-28_auth-security-hardening-pr-c.md) and
[`authentication.md`](../authentication.md).

This file tracks **intentionally deferred** follow-ups from the auth security
hardening plan. Do not implement without an explicit product/ADR decision or a
repro that proves the deferral is no longer safe.

## Index

| ID | Item | Unblock when |
| --- | --- | --- |
| [AUTH-D01](#auth-d01-render-fastapi-coordinator-hook) | Render FastAPI coordinator hook | Persistent 401 on orchestration path after Firebase refresh |
| [AUTH-D02](#auth-d02-registerpage-backend) | `RegisterPage` backend | Product requires non–FirebaseUI registration path |
| [AUTH-D03](#auth-d03-roleclaims-authorization) | Role/claims route authorization | ADR on claims source of truth |
| [AUTH-D04](#auth-d04-auth_injection_failed-extra-flag) | `auth_injection_failed` Dio extra | Need to distinguish injection failure vs absent user |

---

## AUTH-D01: Render FastAPI coordinator hook

**What:** Wire `SessionLifecycleCoordinator.invalidateSession` when the **Render
orchestration** HTTP client (`RenderFastApiChatRepository` / dedicated Render
`Dio`) gets a **persistent 401** after caller auth refresh — mirroring Firebase
`AuthTokenInterceptor` post-retry behavior.

**Why deferred:** Render chat uses a **separate** `Dio` instance (no shared
`AuthTokenInterceptor`). PR A already clears the HF orchestration token on
Firebase sign-out via `bindHfTokenProvider` in `register_chat_services.dart`.
Orchestration auth failures are surfaced today through cubit/UI copy
(`chatAuthRefreshRequired`, `chatSessionEnded`) and repository terminal queue
behavior — not global Firebase sign-out.

**Current seams:**

- `apps/mobile/lib/core/di/features/register_chat_services.dart` — `RenderOrchestrationHfTokenProvider`,
  Render-named `Dio`
- `apps/mobile/lib/features/chat/data/render_fast_api_chat_repository.dart`
- `apps/mobile/lib/core/auth/session_lifecycle_coordinator.dart`
- Plan: [`render_fastapi_chat_demo_plan.md`](render_fastapi_chat_demo_plan.md)

**Unblock criteria:**

1. Repro: Render returns **401 after** a successful Firebase ID token refresh
   (or HF token refresh) on the orchestration path, **and**
2. Product wants **global** Firebase session invalidation (not feature-local
   terminal failure only).

**Implementation sketch (when unblocked):** Classify Render 401 + replay in the
Render repository or a Render-specific interceptor; call
`coordinator.invalidateSession(firebase, remoteRejected)` only when refresh did
not help. Do **not** attach the shared `AuthTokenInterceptor` to the Render
`Dio` (would inject wrong tokens / retry policy) — follow the plan’s separate
client rule.

---

## AUTH-D02: `RegisterPage` backend

**What:** Persist `RegisterPage` form data to a real backend or create Firebase
users from the custom registration screen.

**Why deferred:** Out of scope for auth security hardening. Real account creation
uses **FirebaseUI** on `/auth` and **Supabase** email/password on
`/supabase-auth`. `RegisterPage` is a **UI-only** demo (`RegisterCubit` shows a
confirmation dialog only).

**Current seams:**

- `apps/mobile/lib/features/auth/presentation/pages/register_page.dart`
- `apps/mobile/lib/features/auth/presentation/cubit/register/`
- Doc: [`authentication.md`](../authentication.md) — “Registration Flow (UI-Only)”

**Unblock criteria:** Product asks for a dedicated registration flow separate
from FirebaseUI (backend API, custom Firebase Admin flow, or Supabase-only
onboarding).

---

## AUTH-D03: Role/claims authorization

**What:** Role-restricted routes and UI (e.g. student/teacher, admin) using a
single **source of truth** for claims.

**Why deferred:** Client-only role checks are not security boundaries. Router
policy today is **`public | authenticated`** via `AppRouteAuthGate` /
`AppRoutePolicies`. PR C explicitly documented “no client-side role security until
claims ADR” in the secure session checklist.

**Current seams:**

- `apps/mobile/lib/app/router/route_auth_policy.dart`, `app_route_auth_gate.dart`
- [`authentication.md`](../authentication.md) — “Roles/claims (design note)”
- Broader roadmap: [`future_architecture_code_quality_improvement_plan.md`](future_architecture_code_quality_improvement_plan.md) Phase 1

**Unblock criteria:**

1. ADR choosing **Firebase custom claims** vs **profile field** vs **hybrid**
2. Documented refresh/access path (no async router redirect races)
3. At least one protected route group as reference implementation

**Do not** implement ad-hoc `if (role == …)` in presentation without the ADR.

---

## AUTH-D04: `auth_injection_failed` extra flag

**What:** Add a request `extra` flag (e.g. `auth_injection_failed`) on the shared
`Dio` path when `AuthTokenInterceptor` cannot attach a bearer token because
`getIdToken` failed — distinct from “no signed-in user” (skip injection) and
distinct from post-response 401 handling.

**Why deferred:** Not required for the shipped invalidation paths
(classified refresh failure, post-retry 401). Callers today cannot distinguish
proactive injection failure from absent `FirebaseAuth` user without reading logs.

**Current seams:**

- `apps/mobile/lib/shared/http/interceptors/auth_token_interceptor.dart` — existing extras:
  `auth_401_retried`, `managed_auth_user`, `skip_auth_handling`
- `apps/mobile/lib/shared/http/auth_token_manager.dart`

**Unblock criteria:**

1. A feature needs to branch on **injection failure** (metrics, UI, or tests)
   without parsing interceptor logs, **or**
2. Product wants coordinator invalidation when injection fails before the
   request is sent (today only 401-after-refresh triggers invalidation).

**Implementation sketch (when unblocked):** Set `extra['auth_injection_failed'] =
true` when `getIdToken` throws auth-classified errors in `onRequest`; document
the contract in [`authentication.md`](../authentication.md) and add interceptor unit tests. Avoid
breaking callers that clone `RequestOptions.extra`.

---

## Related non-deferred work (still open)

These are **not** part of the auth security hardening deferral list but remain on
the auth roadmap in [`authentication.md`](../authentication.md):

- Expand `AppRoutePolicies` for sensitive routes that still assume auth implicitly.
- Biometric policy hardening (bypass when unsupported is documented as a risk).
