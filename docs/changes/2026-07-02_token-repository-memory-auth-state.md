# Token Repository Memory Auth State

## Why

API-call paths should not depend on provider secure-storage reads. Secure
storage remains the persistent session owner, but app repositories and
interceptors need a dedicated token seam so request-time token access is fast,
testable, and centrally cleared on logout.

## What changed

- Added `TokenRepository` / `InMemoryTokenRepository` as the app-owned token
  state boundary.
- Routed Firebase `AuthTokenManager` through `TokenRepository` while preserving
  per-user expiry and single-flight refresh behavior.
- Routed Supabase session access through `TokenRepository`: service startup and
  auth success hydrate memory, refresh writes memory, and API-call reads use
  memory via DI.
- Updated chat, chart, and GraphQL Supabase DI to use `SupabaseSessionManager`
  memory reads instead of direct SDK session reads.
- Documented the startup / login / refresh / logout secure-storage boundary in
  [`authentication.md`](../authentication.md).

## Proof

- `test/core/auth/token_repository_test.dart`
- `test/shared/http/supabase_session_manager_test.dart`
- `test/features/supabase_auth/data/supabase_auth_repository_impl_test.dart`
- `test/shared/http/auth_token_manager_test.dart`
