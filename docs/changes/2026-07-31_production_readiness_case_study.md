# Case study: Production readiness ownership demo

| Field | Value |
| --- | --- |
| Date | 2026-07-31 |
| Feature | `/production-readiness` |
| ADR | [0006-production-readiness-demo.md](../adr/0006-production-readiness-demo.md) |
| Brief | [2026-07-31_production_readiness_feature_brief.md](2026-07-31_production_readiness_feature_brief.md) |

## Requirement

Show **production ownership** in ~12 minutes on a cold clone: analytics consent,
Remote Config kill-switch, safe FCM handling, Crashlytics status, frame budgets,
and a credential-free release dry-run — without implying store publish or
shipping Mixpanel/Sentry/Patrol.

## Decision

Dual-mode demo ([ADR 0006](../adr/0006-production-readiness-demo.md)):

- **Live** when Firebase is initialized; **simulated** otherwise (same UI).
- Consent via SharedPreferences, **default false**.
- Allowlisted analytics params only: `mode`, `source`, `result`, `variant`.
- Simulated FCM when Firebase absent (not a silent no-op).
- Manual CI workflow for dry-run builds + fixture perf gate — **not** store upload.
- Registered as **alternate** interview spine ([ADR 0005](../adr/0005-interview-showcase-scope.md)); general Counter → Todo → Chat spine stays primary.

## Implementation

| Layer | Location |
| --- | --- |
| Feature | [`apps/mobile/lib/features/production_readiness/`](../../apps/mobile/lib/features/production_readiness/) |
| Analytics port | [`apps/mobile/lib/app/analytics/`](../../apps/mobile/lib/app/analytics/) |
| Frame timing | [`apps/mobile/lib/app/diagnostics/frame_timing_monitor.dart`](../../apps/mobile/lib/app/diagnostics/frame_timing_monitor.dart) |
| FCM sim + redaction | [`fcm_demo/data/`](../../apps/mobile/lib/features/fcm_demo/data/) |
| RC keys | `production_demo_enabled`, `production_demo_variant` |
| Perf budgets | [`tool/perf_budgets.json`](../../tool/perf_budgets.json), [`tool/analyze_perf_trace.py`](../../tool/analyze_perf_trace.py) |
| Dry-run CI | [`.github/workflows/mobile_release_dry_run.yml`](../../.github/workflows/mobile_release_dry_run.yml) |
| Integration | `flow_scenarios_production_readiness.dart` (J6 in PR smoke) |

## Failure paths handled

| Failure | Behavior |
| --- | --- |
| Firebase not initialized | Simulated mode; FCM emit still works |
| Analytics platform channel throws | Adapter swallows; DI/bootstrap continues |
| Consent off | No product events forwarded |
| RC kill-switch / fetch fail | Banner + retry; UI stays usable |
| Token / notification body in logs | Redaction: source, presence, key count only |
| Dry-run mistaken for publish | Workflow comments + deployment.md warning |

## Proof

```bash
cd apps/mobile && flutter test test/features/production_readiness test/app/analytics test/app/diagnostics
python3 -m unittest tool/analyze_perf_trace_test.py
./bin/integration_preflight
./bin/integration_tests integration_test/pr_smoke_flows_test.dart
```

Manual: README [12-minute walkthrough](../../README.md#12-minute-production-ownership-walkthrough).

## Rollback

- Feature is additive: remove route + Example entry + DI registrations.
- Consent keys in SharedPreferences are harmless if left behind.
- Dry-run workflow is `workflow_dispatch` only — disable or delete without affecting PR CI.

## Honest gaps

- Frame budgets on dry-run use **fixture** traces, not live simulator capture in CI.
- Firebase Performance / Sentry / Mixpanel / Patrol remain deferred.
- Live FCM still needs a configured Firebase project for full end-to-end push.
- General spine sync-diagnostics step remains manual (not this feature’s E2E).
