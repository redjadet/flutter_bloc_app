# ADR 0006: Production readiness demo (dual-mode, privacy, budgets)

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-07-31 |
| Scope | Portfolio production-ownership walkthrough |
| Source docs | [feature brief](../changes/2026-07-31_production_readiness_feature_brief.md), [observability](../observability.md), [ADR 0005](0005-interview-showcase-scope.md) |

## Context

Flutter developers often require end-to-end ownership evidence: Firebase Analytics,
Remote Config kill-switches, FCM safety, Crashlytics, performance budgets, and
CI release proof. The repo already has Clean Architecture demos and Firebase
wiring, but product analytics were deferred (ADR 0005), FCM falls back to a
no-op when Firebase is absent, and release proof is Fastlane-local rather than a
credential-free workflow.

Interviewers need one runnable `/production-readiness` route on a fresh clone
(including web / missing Firebase) without secrets or store credentials.

## Decision drivers

- Honest, evidence-backed claims only
- Consent-default-off telemetry privacy
- Fresh-clone and no-Firebase must still demo the story
- Release CI proves build readiness, not store publishing
- Keep Mixpanel / Sentry / Patrol deferred (ADR 0005)

## Decision

1. **Dual-mode runtime:** `live` when Firebase is initialized; otherwise
   `simulated` with deterministic adapters (FCM simulation, in-memory analytics
   buffer). The `/production-readiness` route never redirects away for missing
   Firebase.
2. **Consent-gated Firebase Analytics:** App-level `ProductAnalytics` with
   named `AppAnalyticsEvent` factories only. Persist consent in SharedPreferences
   (`analytics_collection_enabled`; missing → `false`). Disable Firebase
   collection until opt-in. Allowlist params: `mode`, `source`, `result`,
   `variant`. Reject tokens, IDs, message content, email, arbitrary maps.
   Platform manifests default collection off (`firebase_analytics_collection_enabled`
   / `FIREBASE_ANALYTICS_COLLECTION_ENABLED`); Dart bootstrap also disables
   Analytics immediately after `Firebase.initializeApp` (and on reused apps)
   before DI loads consent. Settings and the walkthrough share
   `AnalyticsConsentRepository.changes` so toggles stay in sync.
3. **Composite analytics:** In-memory ring buffer (max 50) always records for
   demo UI counts; Firebase adapter participates only when Firebase is available
   and consent is on.
4. **Remote Config keys:** `production_demo_enabled` (default true) and
   `production_demo_variant` (default `control`) via existing offline-first RC.
5. **FCM safety:** Logs carry source, presence flags, and data-key count only.
   Release UI masks tokens; reveal/copy only in `dev`/`qa`. Simulated adapter
   replaces no-op when Firebase is absent.
6. **Frame budgets:** `FrameTimingMonitor` from Flutter `FrameTiming`. Checked-in
   budgets: ≥100 frames; p90 ≤ 8.3 ms; p99 ≤ 16.7 ms; >16.7 ms ≤ 1%; p90
   regression vs 3-run median ≤ 25%. If 3-run variance > 20%, report-only and
   withhold gate claim.
7. **Release dry-run workflow:** Manual `mobile_release_dry_run.yml` builds iOS
   (`--no-codesign`), Android AAB (ephemeral CI keystore), runs Functions tests /
   checklist / perf gate, uploads artifacts. Never TestFlight, Play upload,
   Firebase deploy, or production credentials.
8. **ADR 0005 relationship:** Alternate job-focused interview spine is registered
   alongside the frozen Counter→Todo→Chat spine. Firebase Analytics typed events
   are allowed under this ADR; Mixpanel/Sentry/Patrol remain deferred.

## Alternatives considered

| Alternative | Why not |
| --- | --- |
| Hive for consent | Settings prefs already use SharedPreferences |
| Mixpanel/Sentry for JD keywords | No second consumer; privacy/review cost |
| Auto store publish in CI | Secrets + irreversible side effects |
| Redirect no-Firebase users to Counter | Breaks fresh-clone portfolio demo |

## Consequences

### Benefits

- One walkthrough proves ownership without scattered demos
- Privacy defaults safe for clones and screenshots
- CI proves mobile release readiness without store risk

### Costs

- Dual-mode surface area (live + simulated adapters)
- Manual workflow_dispatch for dry-run (not every PR)
- ADR 0005 analytics wording must stay aligned when amended

## Implementation notes

- Feature: `apps/mobile/lib/features/production_readiness/` (presentation
  orchestration over existing Firebase / RC / FCM / analytics seams — intentional
  portfolio scope, not a full domain-layer reference feature)
- Analytics: `apps/mobile/lib/app/analytics/`
- Plan (local): `docs/plans/improvement_PLAN.md` (gitignored working plan)

## Review triggers

- Second analytics consumer or new vendor SDK
- Store upload automation requested
- Frame budget thresholds change
- FCM payload logging policy change

## Verification

```bash
cd apps/mobile && flutter test test/features/production_readiness test/app/analytics test/app/diagnostics
python3 -m unittest tool/analyze_perf_trace_test.py
bash tool/check_feature_brief_linked.sh
bash tool/check_feature_folder_contract.sh --strict
./bin/router_feature_validate
```
