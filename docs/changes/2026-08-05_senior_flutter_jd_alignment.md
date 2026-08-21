# Flutter judgment guidance alignment — 2026-08-05

## Summary

Credential-safe ownership proof for Flutter judgment guidance:

- Crashlytics allowlisted custom keys (`flavor`, `app_version`, `firebase_ready`)
  plus production-readiness **Emit test non-fatal** (simulated = local only)
- Auth-gated Functions diagnostic for `issueRenderChatDemoHfReadToken` with
  `hf_read_token`/`token` never rendered (presence + length only); App Check
  preview removed from the diagnostic page; non-`Exception` failures now map
  to the same safe localized error without crashing the page
- Staff demo inbox Firestore mapping extracted and unit-tested; feature P3 stays **R**
- Arabic RTL widget coverage strengthened for production-readiness + Counter
- Showcase §3b/§4 and triage runbook updated; dry-run remains non-publishing

## Files changed (high level)

- Bootstrap Crashlytics metadata + public non-fatal helper
- `production_readiness` cubit/page/state + l10n
- `firebase_functions_test_page` + router auth gate
- `staff_demo_inbox_firestore_map` + repository delegation
- Docs: observability runbook, interview showcase, audit note, this change log
- Tracker: [`tasks/senior_flutter_jd_alignment/todo.md`](../../tasks/senior_flutter_jd_alignment/todo.md)

## Residuals

- No live Firebase credentials required for automated proof
- Full `staff_app_demo` P3 typed-contract program remains deferred
- Mixpanel / Sentry / Patrol / Firebase Performance still out of scope (ADR 0005)

## Validation

Focused suites for Waves 1–3 passed; router/feature validate passed; full
checklist and PR smoke run at closeout.
