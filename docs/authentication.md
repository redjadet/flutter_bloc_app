# Authentication Overview

## Repository roles (app-wide)

| Type | DI token | Scope | Use when |
| --- | --- | --- | --- |
| `AuthRepository` | `getIt<AuthRepository>()` | **Firebase** (or debug guest fallback) | Router redirect, Settings account section, sign-in/sign-out, HTTP `AuthTokenInterceptor`, counter RTDB scoping |
| `SupabaseAuthRepository` | `getIt<SupabaseAuthRepository>()` | **Supabase** email/password on `/supabase-auth` | Supabase auth page, sign-in/up/out against Supabase project |
| `RemoteBackendAuthPort` | `getIt<RemoteBackendAuthPort>()` | **Read-only** remote-backend session (`authStateChanges`, `currentUser`, `signOut`) | Cross-feature seams (chat session port, case study demo) without importing `supabase_auth/domain` |
| `WalletConnectAuthRepository` | `getIt<WalletConnectAuthRepository>()` | **WalletConnect** on `/walletconnect-auth` | Web3 wallet sign-in demo; separate from Firebase routing |

`SupabaseAuthRepository` implements `RemoteBackendAuthPort`; DI registers the same instance for both types (`register_supabase_services.dart`). Do not use Supabase or WalletConnect repos for GoRouter guards—those use `AuthRepository` only.

## What We Use

- **Firebase Auth + FirebaseUI** for primary sign-in, backed by GoRouter guards. Providers are built via `buildAuthProviders()` to ensure email/password is always available and to append Google auth when configured (`apps/mobile/lib/features/auth/presentation/widgets/provider_builder.dart`, `widgets/google_provider_helper.dart`).
- **Anonymous sessions** supported from the sign-in screen and treated as authenticated for routing; anonymous users can upgrade accounts without being redirected away (`apps/mobile/lib/features/auth/presentation/pages/sign_in_page.dart`).
- **Biometric gate** wraps sensitive navigation (e.g., Settings) through `BiometricAuthenticator` with a `local_auth` implementation that allows bypass when biometrics are unsupported or not enrolled (`apps/mobile/lib/app/platform/biometric_authenticator.dart`, `apps/mobile/lib/features/counter/presentation/pages/counter_page.dart`).
- **Auth-scoped data** in the counter feature uses Firebase Realtime Database keyed by `user.uid`, waiting up to 5s for a signed-in user before failing (`apps/mobile/lib/features/counter/data/realtime_database_counter_repository.dart`, `apps/mobile/lib/app/composition/injector_factories.dart`).

## Routing & Access Control

- `MyApp` wires GoRouter with `refreshListenable: GoRouterRefreshStream(auth.authStateChanges())` so auth state transitions refresh navigation (`apps/mobile/lib/app.dart`, `apps/mobile/lib/app/router/go_router_refresh_stream.dart`).
- `createAuthRedirect()` enforces:
  - Redirect unauthenticated users to `/auth` **except** when navigating to deep-link paths (anything other than `/`, `/counter`, `/auth`).
  - Redirect authenticated users away from `/auth` to `/counter`; anonymous users stay on `/auth` only with `?upgrade=true` (Settings upgrade flow) (`apps/mobile/lib/app/router/auth_redirect.dart`).
- Routes needing auth today rely on this router-level guard; there is no per-page auth check beyond GoRouter redirects.

## Route-level protection (deep-link safe)

Router redirect intentionally allows deep links while unauthenticated (universal links). Any route that must be authenticated must enforce it at the route level via:

- `AppRouteAuthGate` (`apps/mobile/lib/app/router/app_route_auth_gate.dart`)
- `AppRoutePolicies` (`apps/mobile/lib/app/router/route_auth_policy.dart`)

This ensures both deep-link entry and in-app navigation go through the same auth checks.

Protected examples:

- `/profile` (gated by `AppRouteAuthGate` + `AppRoutePolicies.profile`)
- `/manage-account` (gated by `AppRouteAuthGate` + `AppRoutePolicies.manageAccount`)
- `/settings` — policy `publicRoute` (biometric gate on page, not router auth); matches `AppRoutePolicies.settings`
- `/walletconnect-auth` (gated by `AppRouteAuthGate` + `AppRoutePolicies.walletconnectAuth`)
- Online therapy demo admin routes (gated by `AppRouteAuthGate` + `AppRoutePolicies.onlineTherapyDemoAdmin*`)

## Sign-In & Account Flows

- **Sign-in screen** (`apps/mobile/lib/features/auth/presentation/pages/sign_in_page.dart`):
  - Uses `firebase_ui.SignInScreen` when Firebase is initialized; falls back to a minimal anonymous-sign-in page otherwise.
  - Registers FirebaseUI actions to navigate to `/counter` on sign-in/user-created/credential-linked, and surfaces `FirebaseAuthException` messages through localized snackbars (`auth_error_message.dart` + `l10n` strings).
  - Anonymous sign-in triggers navigation to the counter page on success; failures show localized errors.
- **Account management**:
  - Settings `AccountSection` receives injected `AuthRepository` (wired from `SettingsPage` via `routes_core.part.dart`) and streams `authStateChanges` with `currentUser` as initial data to show signed-in, guest, or signed-out views; routes to `/auth` for upgrades or `/manage-account` for profile management. Sign-out UI still uses FirebaseUI `SignOutButton` (`apps/mobile/lib/features/settings/presentation/widgets/account_section.dart`, `apps/mobile/lib/features/auth/domain/auth_repository.dart`, `apps/mobile/lib/app/composition/features/register_auth_services.dart`).
  - `/manage-account` hosts FirebaseUI `ProfileScreen` with sign-out redirecting to `/auth` (`apps/mobile/lib/features/auth/presentation/pages/profile_page.dart`).

## Registration Flow (UI-Only)

- `RegisterPage` validates inputs locally via `RegisterCubit`/`RegisterState` (full name/email/password/phone/terms) and, on success, only shows a confirmation dialog; it **does not create Firebase users** or call any backend (`apps/mobile/lib/features/auth/presentation/pages/register_page.dart`, `cubit/register`). **Backend wiring is deferred** — [AUTH-D02](plans/auth_security_hardening_deferred.md#auth-d02-registerpage-backend).
- Terms acceptance is tracked client-side; there is no persistence or policy enforcement beyond the UI.

## Error Handling & Localization

- Auth errors map `FirebaseAuthException.code` to localized strings for sign-in flows (`apps/mobile/lib/features/auth/presentation/widgets/auth_error_message.dart`, `apps/mobile/lib/l10n/app_*.arb`). The mapper **differentiates** network and rate-limit from invalid-credential: `network-request-failed` → `authErrorNetworkRequestFailed` ("Check your connection and try again"), `too-many-requests` → `authErrorTooManyRequests` ("Too many attempts. Please wait before trying again"), so users don't see "invalid credential" when the issue is connectivity or rate limiting.
- Error toasts/snackbars are cleared before display to avoid stacking (`shared/utils/error_handling.dart` usage inside `SignInPage`).

## Supabase Auth (Optional, Separate Page)

- **Supabase authentication** is an optional flow on a dedicated page, separate from the main Firebase-based app auth. It does not replace Firebase for app-wide redirect or routing.
- **Route:** `/supabase-auth` (see `AppRoutes.supabaseAuthPath`). Entry point: Settings → Integrations → Supabase Auth.
- **Configuration:** Supabase is initialized at bootstrap when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are present in `SecretConfig` (from `--dart-define`, secure storage, or environment injected via `direnv`/wrapper scripts—see [Security & Secrets](security_and_secrets.md)). The same Supabase client is also used by Supabase-backed features (e.g. the IoT demo backend when configured). When Supabase is not configured, the IoT demo page is still accessible in local-only mode. See [Security & Secrets](security_and_secrets.md) and [Supabase migrations](../supabase/README.md). Key paths: `apps/mobile/lib/app/config/secret_config.dart`, `apps/mobile/lib/app/bootstrap/supabase_bootstrap_service.dart`, `apps/mobile/lib/app/bootstrap/bootstrap_coordinator.dart`.
- **Behavior:** When Supabase URL and anon key are configured (e.g. in secrets or environment), the page allows sign-in, sign-up, and sign-out via email/password. When not configured, the page shows a “not configured” message and no forms.
- **Implementation:** `apps/mobile/lib/features/supabase_auth/` (domain `SupabaseAuthRepository`, data `SupabaseAuthRepositoryImpl`, presentation `SupabaseAuthCubit` and `SupabaseAuthPage`). Reuses the app’s `AuthUser` domain model for the current Supabase user. Supabase is initialized at bootstrap when credentials are present (`SupabaseBootstrapService`). DI: `apps/mobile/lib/app/composition/features/register_supabase_services.dart`; route: `apps/mobile/lib/app/router/route_groups.dart`.
- **Credential handling:** The page uses email/password autofill hints and disables autocorrect/suggestions for credential fields. The repository trims email, rejects malformed email and too-short passwords before calling Supabase, and maps unexpected transport failures to a stable generic auth error while preserving the cause for logs/tests. Debug logs must not include token values, token lengths, decoded token claims, passwords, or raw auth response payloads.
- **Error handling:** Auth failures are mapped to `SupabaseAuthErrorCode` (invalidCredentials, invalidEmail, network, userAlreadyExists, weakPassword) and shown via localized strings (`app_*.arb`). Expected user errors (e.g. wrong password, weak password, invalid email, user already exists) are logged at debug to reduce console noise.
- **Accessing the signed-in Supabase user from other code:** `SupabaseAuthRepository` is registered as a singleton in DI. Resolve it via the app injector (e.g. `getIt<SupabaseAuthRepository>()`) and use **`currentUser`** (`AuthUser?`) for one-off checks or **`authStateChanges`** (`Stream<AuthUser?>`) to react to sign-in/sign-out. The same instance is used app-wide, so the signed-in user is visible from any feature that resolves the repository.
- **Testing:** Unit and widget tests in `test/features/supabase_auth/`; repository access from other code is covered by `test/features/supabase_auth/data/supabase_auth_repository_access_test.dart`.

## Session lifecycle coordinator (PR A)

- `SessionLifecycleCoordinator` (`apps/mobile/lib/app/auth/session_lifecycle_coordinator.dart`) is the central cleanup and invalidation seam for Firebase-primary auth.
- All `AuthRepository` DI registrations are wrapped with `SignOutAwareAuthRepository` so explicit `signOut()` clears `AuthTokenManager` and optional Render HF token cache.
- An auth-stream listener also runs cleanup when Firebase SDK sign-out occurs (e.g. FirebaseUI `SignOutButton` bypassing the repository).
- `AuthTokenManager` is a DI singleton; `register_http_services.dart` binds it to the coordinator after `Dio` creation.
- `AuthTokenInterceptor` invalidates the Firebase session on auth-classified refresh failures and on persistent 401 after one forced refresh + replay (`auth_token_refresh_classifier.dart`).

## Supabase session manager (PR B)

- `SupabaseSessionManager` (`apps/mobile/lib/app/http/supabase/supabase_session_manager.dart`) single-flights `refreshSession()` for chat, case-study delete, and GraphQL edge calls.
- Auth-classified refresh failures call `SessionLifecycleCoordinator.invalidateSession(supabase, …)`.
- `JwtClaimsReader` (in `packages/auth`) decodes JWT payload for diagnostics only (no signature verification, not for authorization).
- `SupabaseAuthCubit` exposes `sessionExpired` when the coordinator invalidates the Supabase stack.

## App auth UX (PR C)

- `AppAuthCubit` (`apps/mobile/lib/app/presentation/cubit/app_auth_cubit.dart`) is **UX-only** for Firebase `sessionExpired` snackbar and acknowledge flow.
- GoRouter redirect policy remains on `AuthRepository.authStateChanges` (no dual router truth).
- `sessionExpired` is sticky until `acknowledgeSessionExpired()`; signing in clears it.
- Snackbar copy: `context.l10n.sessionExpiredMessage` (localized in all `app_*.arb` locales).

## Token Handling (Non-Firebase HTTP)

- The app **Dio** client injects Firebase ID tokens via `AuthTokenInterceptor` when a `FirebaseAuth` instance is provided (`apps/mobile/lib/app/http/auth/interceptors/auth_token_interceptor.dart`).
- App code reads authentication tokens through the dedicated `TokenRepository`
  (`packages/auth`), not directly from secure storage.
  Provider SDKs remain the persistence owners; the repository keeps the app's
  API-call path on in-memory state.
- Tokens are retrieved and cached by `AuthTokenManager`, which:
  - Tracks cached token expiration and refresh window (5 minutes before expiry).
  - Caches per user ID to avoid cross-user token reuse.
  - Uses a serialized refresh gate so concurrent 401 failures share one refresh.
  - Hydrates cache from the refreshed token result so waiters reuse one fresh value.
  - Clears cached token/user on refresh errors or explicit `clearCache()` calls.
  (`apps/mobile/lib/app/http/auth/auth_token_manager.dart`)
- Firebase token state is hydrated into `TokenRepository` at HTTP service
  startup and after forced refresh. Normal request injection reads memory when
  the token is still valid.
- Supabase token state is hydrated into `TokenRepository` at Supabase service
  startup and after Supabase sign-in/sign-up. Supabase-backed chat, chart, and
  GraphQL repositories receive the memory token reader through DI. On 401,
  `SupabaseSessionManager` performs a single SDK refresh, then writes the new
  access token into memory for retry and later API calls.
- On 401 responses, `AuthTokenInterceptor` performs one refresh flow and retries with
  the refreshed bearer token, avoiding chained forced-refresh calls.
- If Firebase Auth is not configured, the interceptor will skip token injection and proceed with standard headers only.
- **Deferred:** proactive `auth_injection_failed` request `extra` when `getIdToken` fails before send — [AUTH-D04](plans/auth_security_hardening_deferred.md#auth-d04-auth_injection_failed-extra-flag).

## Debug & Simulator Auth Behavior

- **iOS simulator (debug):** Firebase App Check activation is skipped so anonymous sign-in can reach Firebase Auth without registering a debug token (`apps/mobile/lib/app/bootstrap/firebase_bootstrap_service_helpers.dart`, [Firebase setup](integrations/firebase_setup.md#troubleshooting)). Firebase Auth still uses the Keychain on the simulator; when that fails (`keychain-error` / entitlement errors), DI falls back to a **local-only** guest session (`ios-simulator-debug-local-guest`) so the demo UI and router guards remain usable (`apps/mobile/lib/app/composition/features/register_auth_services.dart`). That session is **not** a Firebase user—Realtime Database remotes are omitted (same as macOS debug) so sync does not block on `waitForAuthUser`; counter/todo stay local-only until a real Firebase user exists. Physical iOS devices use real Firebase Auth and wired RTDB remotes.
- **iOS device (debug):** Uses Firebase Auth normally. App Check runs with the debug provider; register the token from logs in Firebase Console → App Check → Manage debug tokens if Auth calls fail with App Check errors.
- **macOS (debug):** When Firebase Auth hits Keychain entitlement errors (`SecItemAdd (-34018)` and similar), DI may fall back to a **local-only** guest session (`macos-debug-local-guest`) so the demo UI remains usable (`apps/mobile/lib/app/composition/features/register_auth_services.dart`). That session is **not** a Firebase user—Realtime Database remotes are omitted (`apps/mobile/lib/app/composition/injector_helpers.dart`) so sync does not block on `waitForAuthUser`; counter/todo stay local-only until a real Firebase user exists.
- **Router:** Fresh anonymous sign-in navigates to `/counter`. Anonymous users stay on `/auth` only with `?upgrade=true` (Settings upgrade flow).
- **Regression gates:** `./bin/router_feature_validate` runs `auth_redirect`, `register_auth_services`, `injector_helpers`, and `sign_in_page` tests; device proof lives in `integration_test/guest_sign_in_flow_test.dart` (`pr_smoke` / `smoke` tiers — see [`engineering/integration_journey_map.md`](engineering/integration_journey_map.md) J1).

## Auth Cache Safety

- Cache keying by `user.uid` prevents stale tokens being reused after logout/login or account switching.
- Refresh paths (`refreshToken()` and `refreshTokenAndGet()`) are single-flight and
  cache the refreshed token atomically for all waiters.
- Refresh failures clear cache state and propagate errors to all refresh waiters.
- Secure storage / provider SDK persistence is touched only on startup
  hydration, login/session hydration, explicit token refresh, or logout cleanup.
  Regular API calls use in-memory authentication state via `TokenRepository`.

## Notable Gaps / Risks

- Deep links to non-root routes bypass the auth redirect by design; any route that requires auth must be wrapped with `AppRouteAuthGate`. Remaining un-gated routes should defensively handle missing user context if required.
- The registration flow is non-functional for account creation; users must use the FirebaseUI sign-in/registration path for real accounts.
- Biometric authenticator returns `true` when biometrics are unsupported or not enrolled, which may be acceptable for settings access but is not a hard security gate.
- Firebase-dependent flows auto-fallback to anonymous-only UI when Firebase is uninitialized, which may hide configuration issues in some environments.
- Token injection only applies to HTTP requests made via the shared app **Dio** instance (and its interceptors); other clients (e.g. third-party SDKs) will not include auth headers automatically.

## What remains (next work)

### Deferred from auth security hardening (June 2026)

PR A–C are **shipped**. The following were explicitly **out of scope** for that
delivery; do not implement without the unblock criteria in
[`plans/auth_security_hardening_deferred.md`](plans/auth_security_hardening_deferred.md):

| ID | Item | Summary |
| --- | --- | --- |
| AUTH-D01 | Render FastAPI coordinator hook | Global `invalidateSession` on persistent Render orchestration 401 after refresh — only if repro + product require it |
| AUTH-D02 | `RegisterPage` backend | Keep UI-only; real signup stays FirebaseUI / Supabase |
| AUTH-D03 | Role/claims authorization | Blocked on ADR (claims source of truth) before role-aware `AppRoutePolicies` |
| AUTH-D04 | `auth_injection_failed` extra | Dio `extra` flag when token injection fails pre-flight — deferred until a caller needs it |

### Ongoing auth roadmap

- Expand `AppRoutePolicies` coverage for other sensitive routes that currently assume auth implicitly.
- Decide and document a **roles/claims source of truth** (Firebase custom claims vs profile field vs hybrid) before implementing role-restricted gates — see [AUTH-D03](plans/auth_security_hardening_deferred.md#auth-d03-roleclaims-authorization).

## Roles/claims (design note)

Role-based access is not implemented yet. This is **[AUTH-D03](plans/auth_security_hardening_deferred.md#auth-d03-roleclaims-authorization)** — deferred until an ADR exists. Before adding role-restricted routes, decide a source of truth that can be resolved without introducing async router redirects or startup race conditions:

- **Firebase custom claims** (authoritative, but requires claim refresh and a safe access path)
- **Profile field** (app-controlled, but needs persistence + sync semantics)
- **Hybrid** (claims for coarse roles, profile for app-scoped flags)

Until that decision exists, keep route policy to `public | authenticated`, and gate sensitive routes with `AppRouteAuthGate`.

## Secure session checklist

- Access tokens short-lived (Firebase ID ~1h; Supabase per project settings)
- Refresh tokens only in SDK secure storage (never app SharedPreferences/Hive)
- Access tokens exposed to app API callers only through `TokenRepository`
  memory state; do not read secure storage directly from repositories,
  interceptors, or presentation code.
- Central HTTP injection: Firebase via `AuthTokenInterceptor`; Supabase via `SupabaseSessionManager`
- Single-flight refresh: `AuthTokenManager` + `SupabaseSessionManager`
- One 401 retry max (`auth_401_retried`)
- Auth-classified refresh failure ⇒ `SessionLifecycleCoordinator.invalidateSession`
- Logout clears caches via decorator + coordinator (ATM, HF orchestration token)
- Never log token values (no suffix, no full App Check token in logs)
- JWT decode for UI/diagnostics only (`JwtClaimsReader`)
- No client-side role security until claims ADR ([AUTH-D03](plans/auth_security_hardening_deferred.md#auth-d03-roleclaims-authorization))
- Explicit UX states: `AppAuthCubit.sessionExpired`, `SupabaseAuthState.sessionExpired`

## Request Checklist (Current State)

- **Firebase integration**: Yes — Firebase Auth + FirebaseUI drive sign-in, routing guards, and Realtime Database scoping (`apps/mobile/lib/app.dart`, `apps/mobile/lib/app/router/auth_redirect.dart`, `apps/mobile/lib/features/auth/presentation/pages/sign_in_page.dart`, `apps/mobile/lib/features/counter/data/realtime_database_counter_repository.dart`).
- **Email + password auth**: Yes — Always included in provider list via `buildAuthProviders()` to guarantee availability even when FirebaseUI config is minimal (`apps/mobile/lib/features/auth/presentation/widgets/provider_builder.dart`).
- **Token handling**: Partial — Firebase SDK issues and refreshes ID tokens
  automatically. For non-Firebase HTTP calls, the shared **Dio** client uses
  `AuthTokenInterceptor` and `AuthTokenManager`, which cache per user and apply
  serialized single-flight refresh for concurrent 401s
  (`apps/mobile/lib/app/http/auth/auth_token_manager.dart`,
  `apps/mobile/lib/app/http/auth/interceptors/auth_token_interceptor.dart`).
- **User session persistence**: Yes — Relies on Firebase Auth’s built-in persisted sessions; navigation listens to `authStateChanges()` to react to sign-in/sign-out (`apps/mobile/lib/app/router/go_router_refresh_stream.dart`).
- **Role-based access (e.g., student/teacher)**: No — No role/claims parsing or role-aware route guards; only authenticated vs unauthenticated (with anonymous upgrade exception).
- **Authentication: OAuth, token management**: OAuth: Yes (Google provider added when available via `helpers/google_provider_helper.dart`); token management: Partial (custom token injection for non-Firebase HTTP clients with per-user caching; lifecycle still relies on Firebase defaults).
