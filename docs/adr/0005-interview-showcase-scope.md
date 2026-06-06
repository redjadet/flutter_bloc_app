# ADR 0005: Interview showcase scope and doc-only analytics

| Field | Value |
| --- | --- |
| Status | Accepted |
| Scope | Portfolio / interview curation |
| Source docs | [interview_showcase.md](../interview_showcase.md), [future_observability.md](../plans/future_observability.md) |

## Context

The repo contains many demo routes. Interviewers need a **short, repeatable walk** without implying every module is production-critical. Separately, job descriptions often mention Mixpanel, Sentry, or Patrol — adding SDKs solely for portfolio optics increases maintenance and privacy review cost without a second product consumer.

## Decision drivers

- Time-boxed interviewer experience (~30 minutes)
- Honest claims vs. shipped code
- Keep hero polish bounded (counter, todo, chat presentation only)
- PR smoke must cover spine automation where flows already exist

## Decision

1. **Frozen interview spine:** Counter → Todo → Chat list → Settings sync diagnostics (manual) → agent harness. Documented in [`interview_showcase.md`](../interview_showcase.md).
2. **Doc-only product analytics:** No Mixpanel/Sentry/Patrol in `pubspec.yaml` until a real product requires them. Future seams documented in [`plans/future_observability.md`](../plans/future_observability.md).
3. **PR smoke alignment:** `registerPrSmokeIntegrationFlows()` includes guest sign-in (anonymous → Home), counter persistence, and chat list alongside launch/charts/search/settings/todo flows.
4. **No Melos split** for showcase purposes; modular monolith narrative remains accurate.

## Alternatives considered

| Alternative | Why not now |
| --- | --- |
| Add Mixpanel + Sentry for JD keywords | No second consumer; interview can reference plan doc |
| Case study on spine | Auth/Firebase friction for cold clone |
| New sync-diagnostics E2E | Out of scope; manual step 4 |

## Consequences

### Benefits

- Clear interviewer script and proof commands
- Smaller, reviewable diffs for hero a11y
- Truth-aligned observability docs

### Costs

- Manual demo for sync diagnostics
- Longer PR smoke runtime on macOS

## Implementation notes

- Tracker: [`tasks/job_demo_showcase/todo.md`](../../tasks/job_demo_showcase/todo.md)
- Outcome brief: [`features/counter_outcome_brief.md`](../features/counter_outcome_brief.md)

## Review triggers

- Second feature needs shared analytics port
- Patrol adopted with CI budget approval
- Spine routes change (GoRouter)

## Verification

- `./bin/checklist-fast`
- `bash tool/validate_task_trackers.sh`
- `./bin/integration_tests integration_test/pr_smoke_flows_test.dart` (macOS, when available)
