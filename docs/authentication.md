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

## Supabase Auth (Optional, Separate Page)

- **Supabase authentication** is an optional flow on a dedicated page, separate from the main Firebase-based app auth. It does not replace Firebase for app-wide redirect or routing.
- **Route:** `/supabase-auth` (see `AppRoutes.supabaseAuthPath`). Entry point: Settings → Integrations → Supabase Auth.
- **Configuration:** Supabase is initialized at bootstrap when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are present in `SecretConfig` (from `--dart-define`, secure storage, or environment injected via `direnv`/wrapper scripts—see [Security & Secrets](security_and_secrets.md)). The same Supabase client is also used by Supabase-backed features (e.g. the IoT demo backend when configured). When Supabase is not configured, the IoT demo page is still accessible in local-only mode. See [Security & Secrets](security_and_secrets.md) and [Supabase migrations](../supabase/README.md). Key paths: `lib/core/config/secret_config.dart`, `lib/core/bootstrap/supabase_bootstrap_service.dart`, `lib/core/bootstrap/bootstrap_coordinator.dart`.
- **Behavior:** When Supabase URL and anon key are configured (e.g. in secrets or environment), the page allows sign-in, sign-up, and sign-out via email/password. When not configured, the page shows a “not configured” message and no forms.
- **Implementation:** `lib/features/supabase_auth/` (domain `SupabaseAuthRepository`, data `SupabaseAuthRepositoryImpl`, presentation `SupabaseAuthCubit` and `SupabaseAuthPage`). Reuses the app’s `AuthUser` domain model for the current Supabase user. Supabase is initialized at bootstrap when credentials are present (`SupabaseBootstrapService`). DI: `lib/core/di/register_supabase_services.dart`; route: `lib/app/router/route_groups.dart`.
- **Error handling:** Auth failures are mapped to `SupabaseAuthErrorCode` (invalidCredentials, invalidEmail, network, userAlreadyExists, weakPassword) and shown via localized strings (`app_*.arb`). Expected user errors (e.g. wrong password, weak password, invalid email, user already exists) are logged at debug to reduce console noise.
- **Accessing the signed-in Supabase user from other code:** `SupabaseAuthRepository` is registered as a singleton in DI. Resolve it via the app injector (e.g. `getIt<SupabaseAuthRepository>()`) and use **`currentUser`** (`AuthUser?`) for one-off checks or **`authStateChanges`** (`Stream<AuthUser?>`) to react to sign-in/sign-out. The same instance is used app-wide, so the signed-in user is visible from any feature that resolves the repository.
- **Testing:** Unit and widget tests in `test/features/supabase_auth/`; repository access from other code is covered by `test/features/supabase_auth/data/supabase_auth_repository_access_test.dart`.

## Token Handling (Non-Firebase HTTP)

- The shared **Dio** client injects Firebase ID tokens via `AuthTokenInterceptor` when a `FirebaseAuth` instance is provided (`lib/shared/http/interceptors/auth_token_interceptor.dart`).
- Tokens are retrieved and cached by `AuthTokenManager`, which:
  - Tracks cached token expiration and refresh window (5 minutes before expiry).
  - Caches per user ID to avoid cross-user token reuse.
  - Uses a serialized refresh gate so concurrent 401 failures share one refresh.
  - Hydrates cache from the refreshed token result so waiters reuse one fresh value.
  - Clears cached token/user on refresh errors or explicit `clearCache()` calls.
  (`lib/shared/http/auth_token_manager.dart`)
- On 401 responses, `AuthTokenInterceptor` performs one refresh flow and retries with
  the refreshed bearer token, avoiding chained forced-refresh calls.
- If Firebase Auth is not configured, the interceptor will skip token injection and proceed with standard headers only.

## Auth Cache Safety

- Cache keying by `user.uid` prevents stale tokens being reused after logout/login or account switching.
- Refresh paths (`refreshToken()` and `refreshTokenAndGet()`) are single-flight and
  cache the refreshed token atomically for all waiters.
- Refresh failures clear cache state and propagate errors to all refresh waiters.

## Notable Gaps / Risks

- Deep links to non-root routes bypass the auth redirect and can surface pages without an authenticated user; features should defensively handle missing user context if required.
- The registration flow is non-functional for account creation; users must use the FirebaseUI sign-in/registration path for real accounts.
- Biometric authenticator returns `true` when biometrics are unsupported or not enrolled, which may be acceptable for settings access but is not a hard security gate.
- Firebase-dependent flows auto-fallback to anonymous-only UI when Firebase is uninitialized, which may hide configuration issues in some environments.
- Token injection only applies to HTTP requests made via the shared app **Dio** instance (and its interceptors); other clients (e.g. third-party SDKs) will not include auth headers automatically.

## Request Checklist (Current State)

- **Firebase integration**: Yes — Firebase Auth + FirebaseUI drive sign-in, routing guards, and Realtime Database scoping (`lib/app.dart`, `lib/app/router/auth_redirect.dart`, `lib/features/auth/presentation/pages/sign_in_page.dart`, `lib/features/counter/data/realtime_database_counter_repository.dart`).
- **Email + password auth**: Yes — Always included in provider list via `buildAuthProviders()` to guarantee availability even when FirebaseUI config is minimal (`lib/features/auth/presentation/helpers/provider_builder.dart`).
- **Token handling**: Partial — Firebase SDK issues and refreshes ID tokens
  automatically. For non-Firebase HTTP calls, the shared **Dio** client uses
  `AuthTokenInterceptor` and `AuthTokenManager`, which cache per user and apply
  serialized single-flight refresh for concurrent 401s
  (`lib/shared/http/auth_token_manager.dart`,
  `lib/shared/http/interceptors/auth_token_interceptor.dart`).
- **User session persistence**: Yes — Relies on Firebase Auth’s built-in persisted sessions; navigation listens to `authStateChanges()` to react to sign-in/sign-out (`lib/app/router/go_router_refresh_stream.dart`).
- **Role-based access (e.g., student/teacher)**: No — No role/claims parsing or role-aware route guards; only authenticated vs unauthenticated (with anonymous upgrade exception).
- **Authentication: OAuth, token management**: OAuth: Yes (Google provider added when available via `helpers/google_provider_helper.dart`); token management: Partial (custom token injection for non-Firebase HTTP clients with per-user caching; lifecycle still relies on Firebase defaults).
