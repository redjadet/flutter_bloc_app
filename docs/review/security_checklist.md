# Security Review Checklist

Use before accepting Cursor/Codex code that touches auth, storage, networking,
sync, or configuration. Findings must cite files and the violated rule.

Primary protocol: [`ai_code_review_protocol.md`](../ai_code_review_protocol.md)
(AI-Generated-Code Risk Matrix). This checklist is the deterministic agent pass.

## Secrets and Configuration

- No API keys, JWTs, DSNs, `sk-`, `AKIA`, or private key blocks in tracked
  source, tests, or docs.
- Secrets load from secure storage, gitignored env files (`.envrc`, `.env`), or
  `--dart-define` — not hardcoded.
- Demo-open endpoints are explicit in feature brief or change note.
- Run `bash tool/check_tracked_secret_literals.sh` and
  `bash tool/check_ai_generated_code_smells.sh` when auth or config changed.

## Auth and Ownership

- Mutations require auth gate or documented demo exception.
- User-scoped data reads/writes include ownership checks in repository or use
  case — not only in UI.
- **Auth ≠ ownership in rules/RLS:** `request.auth != null` / a valid JWT is not
  enough for user-owned docs. Bind `request.auth.uid` (Firestore) or
  `auth.uid()` (Supabase RLS) to the owner path/field (`userId`, `user_id`,
  doc id). Reject rules that grant any signed-in user read/write to another
  user's private data unless the product role model explicitly allows it.
- Token/session refresh and revocation paths match existing auth feature
  patterns.
- Route/auth gates updated together with repository changes.

## Backend surface (Cloud / Edge Functions)

- Do **not** invent Firebase Cloud Functions (`backend/firebase/functions/`) or
  Supabase Edge Functions (`supabase/functions/`) unless the request and feature
  brief call for them. Prefer existing callables/Edge endpoints and client/repo
  patterns documented in firebase/supabase setup docs.
- New functions require authz review (callable auth, JWT/`verify_jwt`, secrets
  not returned to clients) and focused denial-path proof.

## Input and Injection

- No string-built SQL, GraphQL, shell, or HTML from untrusted input.
- User-facing rendering avoids raw HTML unless sanitized/escaped.
- Deep links and URI parsers validate shape before navigation.
- File paths and external URLs use allowlists where applicable.

## Logging and Observability

- Logs and telemetry exclude credentials, tokens, PII, and full payloads.
  Enforce via [`AppLogger`/`LogRedaction`](../engineering/logging.md) and
  [`tool/check_sensitive_logging.sh`](../../tool/check_sensitive_logging.sh).
- Error messages exposed to UI use stable contracts — not raw stack traces.
- Crashlytics/analytics hooks follow [`observability.md`](../observability.md)
  (sanitized exception text only).

## Storage and Sync

- Sensitive values use Keychain/secure storage abstractions — not
  `SharedPreferences` or plain Hive without review.
- New or changed `FlutterSecureStorage` / Apple Keychain writes must set an
  explicit `…ThisDeviceOnly` accessibility (repo default:
  `first_unlock_this_device`) and keep `synchronizable: false` unless iCloud
  Keychain sync is an intentional product requirement. See
  [`security/storage_rules.md`](../security/storage_rules.md).
- Apple dual-store Keychain: if `readResult` peeks legacy, `delete` must clear
  legacy too (resurrection). Run
  `bash tool/check_keychain_dual_store_symmetry.sh` when touching
  `secure_secret_storage.dart`.
- Offline-first queues do not replay destructive actions without idempotency.
- Apple debug Hive paths follow
  [`engineering/apple_debug_hive_storage.md`](../engineering/apple_debug_hive_storage.md).

## Network and Retries

- Retries are bounded and idempotent where duplicates are harmful.
- Certificate pinning or trust policy changes are explicit and tested.
  Owner: [`docs/security/certificate_pinning.md`](../security/certificate_pinning.md)
  (default mode `disabled`; enable via `CERT_PINNING_MODE`).
- Auth headers are not logged or cached in insecure stores.

## Proof

Minimum: focused tests for auth failure, ownership denial, and malformed input.
Escalate to `./bin/checklist` for auth repository, sync, DI, or cross-feature
security changes.
