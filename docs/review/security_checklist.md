# Security Review Checklist

Use before accepting Cursor/Codex code that touches auth, storage, networking,
sync, or configuration. Findings must cite files and the violated rule.

Primary protocol: [`ai_code_review_protocol.md`](../ai_code_review_protocol.md)
(AI-Generated-Code Risk Matrix). This checklist is the deterministic agent pass.

## Secrets and Configuration

- No API keys, JWTs, DSNs, `sk-`, `AKIA`, or private key blocks in tracked
  source, tests, or docs.
- Secrets load from secure storage, env, or `--dart-define` — not hardcoded.
- Demo-open endpoints are explicit in feature brief or change note.
- Run `bash tool/check_tracked_secret_literals.sh` and
  `bash tool/check_ai_generated_code_smells.sh` when auth or config changed.

## Auth and Ownership

- Mutations require auth gate or documented demo exception.
- User-scoped data reads/writes include ownership checks in repository or use
  case — not only in UI.
- Token/session refresh and revocation paths match existing auth feature
  patterns.
- Route/auth gates updated together with repository changes.

## Input and Injection

- No string-built SQL, GraphQL, shell, or HTML from untrusted input.
- User-facing rendering avoids raw HTML unless sanitized/escaped.
- Deep links and URI parsers validate shape before navigation.
- File paths and external URLs use allowlists where applicable.

## Logging and Observability

- Logs and telemetry exclude credentials, tokens, PII, and full payloads.
- Error messages exposed to UI use stable contracts — not raw stack traces.
- Crashlytics/analytics hooks follow [`observability.md`](../observability.md).

## Storage and Sync

- Sensitive values use Keychain/secure storage abstractions — not
  `SharedPreferences` or plain Hive without review.
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
