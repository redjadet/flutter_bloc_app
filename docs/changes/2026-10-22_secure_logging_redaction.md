# Feature: Secure logging redaction gaps

**Date:** 2026-10-22

## Problem

An audit against "Secure Logging in Flutter" found that the existing
`AppLogger` + `LogRedaction` pipeline, `avoid_print`, and the raw-print and
sensitive-logging guards already cover most risks. The audit found these gaps:

- `LogRedaction.isSecretKey` matched exact names, so compound keys such as
  `client_secret`, `x-api-key`, or `set-cookie` passed through `safeFields`.
- The free-text scrub missed JSON-style `"refresh_token":"…"` text and compound
  names inside exception messages, and did not scrub email addresses.
- A release-level warning in the GraphQL demo logged the Supabase user id, and
  a WalletConnect warning echoed a malformed stored wallet value.
- The Render chat demo backend logged `str(e)` from google-auth. For malformed
  tokens, that text includes the token segments.

## Scope

- In: `LogRedaction` key/free-text rules; two app log lines; one backend log
  line; logging guide sections on release sinks and third-party SDKs.
- Out: logger API, Crashlytics wiring, analytics allowlist, new guard scripts.

## Layers touched

- [ ] domain
- [x] data
- [ ] presentation
- [ ] DI
- [ ] routes / l10n

## Contracts

- `LogRedaction.redacted` marker and the `key=[REDACTED]` output shape stay
  the same. Existing redaction tests still pass unchanged.
- Fields such as `maxTokens` or `tokenCount` keep their values.

## Behavior contract (define before implementation)

- Must remain true: every `AppLogger` sink receives text with no secrets.
  Non-secret diagnostic fields are still visible. Owner: `LogRedaction`.
- Inputs: compound secret keys, JSON-style exception text, email addresses,
  numeric counters.
- Failure/recovery: none. This changes only what text gets logged.
- Source of expected results: OWASP MASWE-0001 / Logging Cheat Sheet;
  [`engineering/logging.md`](../engineering/logging.md) redaction contract.

## What changed

- `packages/app_shared_flutter/lib/src/utils/log_redaction.dart`: suffix key
  matching, a compound/quoted assignment regex, and an email scrub.
- `apps/mobile/lib/features/graphql_demo/data/supabase_graphql_demo_repository_impl.part.dart`:
  logs `hasUser=` instead of `userId=`.
- `apps/mobile/lib/features/walletconnect_auth/data/walletconnect_auth_repository_impl_body.part.dart`:
  logs the length of a malformed address, not the value.
- `demos/render_chat_api/auth.py`: `firebase_token_invalid` logs the exception
  type.
- [`engineering/logging.md`](../engineering/logging.md): release-sink table, third-party SDK and
  backend rules, updated redaction contract, and sources.

## Tests (executable contract)

- Unit: `packages/app_shared_flutter/test/utils/log_redaction_test.dart`
  covers compound keys, JSON text, emails, and exception payloads. The new
  cases fail on the previous implementation.
- Data: `apps/mobile/test/features/graphql_demo/data/supabase_graphql_demo_repository_test.dart`
  checks that edge 401 diagnostics log `hasUser=true` and never the raw id.
- Data: `apps/mobile/test/features/walletconnect_auth/data/walletconnect_auth_repository_impl_test.dart`
  checks that a malformed stored address is logged by length only.
- Backend: `demos/render_chat_api/tests/test_auth_logging.py` checks that the
  invalid-token log omits token text.

### Proof command

- `./bin/checklist`
- `cd demos/render_chat_api && .venv/bin/python -m pytest -q`

## Docs

- [x] This note, indexed from [`docs/changes/README.md`](README.md)
- [x] Living practice in [`engineering/logging.md`](../engineering/logging.md)
- [ ] [`feature_overview.md`](../feature_overview.md) — unchanged

## Risks

Broader patterns may over-redact a few log values, for example a field named
`nextToken` or text that looks like an email address. That trade-off is
deliberate.

## depends_on

- None.

## blocks

- None.

## merge_order

- Single PR.

## rollback

- Revert the commit.

## proof_commands

```bash
bash tool/check_feature_brief_linked.sh --base origin/main
bash tool/check_sensitive_logging.sh
bash tool/check_docs_gardening.sh --paths docs/changes/2026-10-22_secure_logging_redaction.md docs/changes/README.md docs/engineering/logging.md
```
