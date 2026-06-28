# Auth security hardening — PR B (Supabase consolidation)

## Summary

Adds `SupabaseSessionManager` for single-flight `refreshSession`, `JwtClaimsReader`
for decode-only JWT diagnostics, refactors Supabase chat/case-study/GraphQL repos,
and adds `sessionExpired` to `SupabaseAuthCubit`.

## Changes

- `SupabaseSessionManager` + refresh failure classifier
- `JwtClaimsReader` replaces inline GraphQL JWT decode; removes `tokenLength` logging
- Chat, case-study delete, GraphQL repos use shared session manager
- Case-study cubits no longer call `RemoteBackendAuthPort.signOut()` on 401
- `SupabaseAuthState.sessionExpired` + coordinator listener

**Deferred (auth hardening):** [`auth_security_hardening_deferred.md`](../plans/auth_security_hardening_deferred.md).

## Verification

```bash
flutter test test/shared/http/supabase_session_manager_test.dart test/core/auth/jwt_claims_reader_test.dart test/features/supabase_auth/
```
