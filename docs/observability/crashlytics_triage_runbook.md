# Crashlytics triage runbook

Operational loop for post-ship crash ownership (target Senior Flutter JD proof).

## Flow

1. **Alert** — Crashlytics (or console) surfaces a new fatal/non-fatal cluster.
2. **Classify** — Map to [`AppErrorCode`](../../packages/utilities/lib/src/errors/error_codes.dart) / short reason strings already on the report. Prefer `flavor`, `app_version`, `firebase_ready` custom keys (allowlisted only).
3. **Sanitize** — Confirm no PII, tokens, or request bodies are attached. Redaction lives in bootstrap handlers via `LogRedaction`.
4. **Reproduce** — Prefer a focused unit/widget/integration test over ad-hoc device-only debugging.
5. **Fix** — Smallest reversible change; keep domain pure Dart.
6. **Regress** — Add or extend an automated test in the same change series.
7. **Release note** — Record outcome in `docs/changes/` when the fix ships.

## In-app proof

`/production-readiness` exposes **Emit test non-fatal**:

- Simulated mode records local status only (no Firebase call).
- Live mode calls `FirebaseCrashlyticsBootstrap.recordCrash(..., fatal: false)` with a fixed sanitized reason `production_readiness_test_nonfatal`.

## Related

- [Observability](../observability.md)
- Bootstrap: `apps/mobile/lib/app/bootstrap/firebase_bootstrap_service.dart`
