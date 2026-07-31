# ADR 0005: Interview showcase scope and doc-only analytics

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-05-20 |
| Amended | 2026-07-31 |
| Scope | Portfolio / interview curation |
| Source docs | [interview_showcase.md](../interview_showcase.md), [future_observability.md](../plans/future_observability.md), [ADR 0006](0006-production-readiness-demo.md) |

## Context

The repo contains many demo routes. Interviewers need a **short, repeatable walk** without implying every module is production-critical. Separately, job descriptions often mention Mixpanel, Sentry, or Patrol — adding SDKs solely for portfolio optics increases maintenance and privacy review cost without a second product consumer.

Some JDs emphasize **production ownership** (consent, kill-switch, FCM safety, frame budgets, release dry-run) more than the Counter → Todo → Chat narrative. That path needs a registered alternate without freezing a second “everything is critical” story.

## Decision drivers

- Time-boxed interviewer experience (~30 minutes general, ~12 minutes job-focused)
- Honest claims vs. shipped code
- Keep hero polish bounded (counter, todo, chat presentation only)
- PR smoke must cover spine automation where flows already exist
- Consent-gated Firebase Analytics only when a demo port has a real consumer (`/production-readiness`)

## Decision

1. **Frozen interview spine:** Counter → Todo → Chat list → Settings sync diagnostics (manual) → agent harness. Documented in [`interview_showcase.md`](../interview_showcase.md) §3.
2. **Alternate job-focused spine:** Production readiness → (optional) offline sync / native telemetry → CI/release dry-run evidence. Documented in [`interview_showcase.md`](../interview_showcase.md) §3b (“12-minute production ownership walkthrough”) and [ADR 0006](0006-production-readiness-demo.md). Does **not** replace §3.
3. **Doc-only Mixpanel / Sentry / Patrol:** No Mixpanel, Sentry product SDK, or Patrol in `pubspec.yaml` until a real product requires them. Future seams remain in [`plans/future_observability.md`](../plans/future_observability.md).
4. **Consent-gated Firebase Analytics exception:** A typed product-analytics port with SharedPreferences consent (default off), allowlisted params (`mode`, `source`, `result`, `variant`), in-memory buffer, and Firebase adapter that swallows platform-channel failures is **allowed** for the production-readiness demo. This does **not** authorize Mixpanel/Sentry/Patrol or unscoped event taxonomies. Policy detail: [ADR 0006](0006-production-readiness-demo.md).
5. **PR smoke alignment:** `registerPrSmokeIntegrationFlows()` includes guest sign-in, counter persistence, chat list, launch/charts/search/settings/todo, and **production readiness (J6)**.
6. **Workspace packaging does not change the architecture story:** Melos separates reusable capabilities into `packages/*`; `apps/mobile` remains a modular-monolith composed through one app shell.

## Alternatives considered

| Alternative | Why not now |
| --- | --- |
| Add Mixpanel + Sentry for JD keywords | No second consumer; interview can reference plan doc |
| Case study on primary spine only | Auth/Firebase friction for cold clone; ownership story needs dual-mode demo |
| New sync-diagnostics E2E | Out of scope; manual step 4 on general spine |
| Replace Counter→Todo→Chat with production readiness | General walk still best for offline-first + chat narrative |

## Consequences

### Benefits

- Clear interviewer scripts (general + job-focused) with proof commands
- Smaller, reviewable diffs for hero a11y
- Truth-aligned observability docs (Mixpanel/Sentry deferred; Firebase Analytics consent-gated)
- Credential-free clone can still demo ownership via simulation mode

### Costs

- Manual demo for sync diagnostics on general spine
- Longer PR smoke runtime on macOS (extra J6 flow)
- Two documented spines require agents/humans to pick the right one for the JD

## Implementation notes

- Tracker: [`tasks/job_demo_showcase/todo.md`](../../tasks/job_demo_showcase/todo.md)
- Outcome brief: [`features/counter_outcome_brief.md`](../features/counter_outcome_brief.md)
- Production readiness case study: [`changes/2026-07-31_production_readiness_case_study.md`](../changes/2026-07-31_production_readiness_case_study.md)
- Analytics code: [`apps/mobile/lib/app/analytics/`](../../apps/mobile/lib/app/analytics/)

## Review triggers

- Second feature needs shared analytics port beyond allowlisted demo events
- Patrol adopted with CI budget approval
- Spine routes change (GoRouter)
- Workspace packaging changes the app-shell or feature ownership boundaries
- Production-readiness dual-mode or consent policy changes (also review ADR 0006)

## Verification

- `./bin/checklist-fast`
- `bash tool/validate_task_trackers.sh`
- `./bin/integration_tests integration_test/pr_smoke_flows_test.dart` (macOS, when available)
- `bash tool/check_docs_gardening.sh`
