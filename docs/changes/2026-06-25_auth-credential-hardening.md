# Auth Credential Hardening

## Summary

- Supabase email/password auth now rejects malformed email and too-short
  passwords before transport.
- Supabase auth and case-study delete debug logs no longer include
  token-derived values or raw response payloads.
- Credential fields now expose platform autofill hints and disable autocorrect
  and suggestions.

## Verification

- `flutter test test/features/supabase_auth/data/supabase_auth_repository_impl_test.dart`
- `./bin/router_feature_validate`
- `bash tool/check_tracked_secret_literals.sh`
- `bash tool/check_ai_generated_code_smells.sh`
