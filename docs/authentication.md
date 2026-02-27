# Authentication Overview

## What We Use

- **Firebase Auth + FirebaseUI** for primary sign-in, backed by GoRouter guards. Providers are built via `buildAuthProviders()` to ensure email/password is always available and to append Google auth when configured (`lib/features/auth/presentation/helpers/provider_builder.dart`, `helpers/google_provider_helper.dart`).
- **Anonymous sessions** supported from the sign-in screen and treated as authenticated for routing; anonymous users can upgrade accounts without being redirected away (`lib/features/auth/presentation/pages/sign_in_page.dart`).
- **Biometric gate** wraps sensitive navigation (e.g., Settings) through `BiometricAuthenticator` with a `local_auth` implementation that allows bypass when biometrics are unsupported or not enrolled (`lib/shared/platform/biometric_authenticator.dart`, `lib/features/counter/presentation/pages/counter_page.dart`).
- **Auth-scoped data** in the counter feature uses Firebase Realtime Database keyed by `user.uid`, waiting up to 5s for a signed-in user before failing (`lib/features/counter/data/realtime_database_counter_repository.dart`, `lib/core/di/injector_factories.dart`).

## Routing & Access Control

- `MyApp` wires GoRouter with `refreshListenable: GoRouterRefreshStream(auth.authStateChanges())` so auth state transitions refresh navigation (`lib/app.dart`, `lib/app/router/go_router_refresh_stream.dart`).
- `createAuthRedirect()` enforces:
  - Redirect unauthenticated users to `/auth` **except** when navigating to deep-link paths (anything other than `/`, `/counter`, `/auth`).
  - Redirect authenticated users away from `/auth` to `/counter`, unless they are anonymous and upgrading (`lib/app/router/auth_redirect.dart`).
- Routes needing auth today rely on this router-level guard; there is no per-page auth check beyond GoRouter redirects.

## Sign-In & Account Flows

- **Sign-in screen** (`lib/features/auth/presentation/pages/sign_in_page.dart`):
  - Uses `firebase_ui.SignInScreen` when Firebase is initialized; falls back to a minimal anonymous-sign-in page otherwise.
  - Registers FirebaseUI actions to navigate to `/counter` on sign-in/user-created/credential-linked, and surfaces `FirebaseAuthException` messages through localized snackbars (`auth_error_message.dart` + `l10n` strings).
  - Anonymous sign-in triggers navigation to the counter page on success; failures show localized errors.
- **Account management**:
  - Settings `AccountSection` streams `authStateChanges()` to show signed-in, guest, or signed-out views and routes to `/auth` for upgrades or to `/manage-account` for profile management (`lib/features/settings/presentation/widgets/account_section.dart`).
  - `/manage-account` hosts FirebaseUI `ProfileScreen` with sign-out redirecting to `/auth` (`lib/features/auth/presentation/pages/profile_page.dart`).

## Registration Flow (UI-Only)

- `RegisterPage` validates inputs locally via `RegisterCubit`/`RegisterState` (full name/email/password/phone/terms) and, on success, only shows a confirmation dialog; it **does not create Firebase users** or call any backend (`lib/features/auth/presentation/pages/register_page.dart`, `cubit/register`).
- Terms acceptance is tracked client-side; there is no persistence or policy enforcement beyond the UI.

## Error Handling & Localization

- Auth errors map `FirebaseAuthException.code` to localized strings for sign-in flows (`lib/features/auth/presentation/helpers/auth_error_message.dart`, `lib/l10n/app_*.arb`). The mapper **differentiates** network and rate-limit from invalid-credential: `network-request-failed` → `authErrorNetworkRequestFailed` ("Check your connection and try again"), `too-many-requests` → `authErrorTooManyRequests` ("Too many attempts. Please wait before trying again"), so users don't see "invalid credential" when the issue is connectivity or rate limiting.
- Error toasts/snackbars are cleared before display to avoid stacking (`shared/utils/error_handling.dart` usage inside `SignInPage`).

## Token Handling (Non-Firebase HTTP)

- `ResilientHttpClient` injects Firebase ID tokens into outgoing requests when a `FirebaseAuth` instance is provided (`lib/shared/http/resilient_http_client.dart`, `lib/shared/http/resilient_http_client_helpers.dart`).
- Tokens are retrieved and cached by `AuthTokenManager`, which:
  - Tracks cached token expiration and refresh window (5 minutes before expiry).
  - Caches per user ID to avoid cross-user token reuse.
  - Clears cached token/user on refresh, errors, or explicit `clearCache()` calls.
  (`lib/shared/http/auth_token_manager.dart`)
- If Firebase Auth is not configured, `ResilientHttpClient` will skip token injection and proceed with standard headers only.

## Auth Cache Safety

- Cache keying by `user.uid` prevents stale tokens being reused after logout/login or account switching.
- Refresh paths (`refreshToken()` and `refreshTokenAndGet()`) clear cached token and user ID to ensure a fresh token is fetched.

## Notable Gaps / Risks

- Deep links to non-root routes bypass the auth redirect and can surface pages without an authenticated user; features should defensively handle missing user context if required.
- The registration flow is non-functional for account creation; users must use the FirebaseUI sign-in/registration path for real accounts.
- Biometric authenticator returns `true` when biometrics are unsupported or not enrolled, which may be acceptable for settings access but is not a hard security gate.
- Firebase-dependent flows auto-fallback to anonymous-only UI when Firebase is uninitialized, which may hide configuration issues in some environments.
- Token injection only applies to HTTP requests made via `ResilientHttpClient`; other clients (raw `http.Client`, third-party SDKs) will not include auth headers automatically.

## Request Checklist (Current State)

- **Firebase integration**: Yes — Firebase Auth + FirebaseUI drive sign-in, routing guards, and Realtime Database scoping (`lib/app.dart`, `lib/app/router/auth_redirect.dart`, `lib/features/auth/presentation/pages/sign_in_page.dart`, `lib/features/counter/data/realtime_database_counter_repository.dart`).
- **Email + password auth**: Yes — Always included in provider list via `buildAuthProviders()` to guarantee availability even when FirebaseUI config is minimal (`lib/features/auth/presentation/helpers/provider_builder.dart`).
- **Token handling**: Partial — Firebase SDK issues and refreshes ID tokens automatically. For non-Firebase HTTP calls, `ResilientHttpClient` injects Firebase ID tokens via `AuthTokenManager`, which caches tokens per user and clears on refresh or auth changes (`lib/shared/http/auth_token_manager.dart`, `lib/shared/http/resilient_http_client.dart`).
- **User session persistence**: Yes — Relies on Firebase Auth’s built-in persisted sessions; navigation listens to `authStateChanges()` to react to sign-in/sign-out (`lib/app/router/go_router_refresh_stream.dart`).
- **Role-based access (e.g., student/teacher)**: No — No role/claims parsing or role-aware route guards; only authenticated vs unauthenticated (with anonymous upgrade exception).
- **Authentication: OAuth, token management**: OAuth: Yes (Google provider added when available via `helpers/google_provider_helper.dart`); token management: Partial (custom token injection for non-Firebase HTTP clients with per-user caching; lifecycle still relies on Firebase defaults).
