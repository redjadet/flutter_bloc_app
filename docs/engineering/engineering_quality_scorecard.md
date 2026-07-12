# Engineering Quality Scorecard (Portfolio-Honest)

This scorecard is the **measured** contract for claiming **portfolio top-tier engineering quality** for the Flutter app.

It is **not** the same thing as the Cursor/Codex **Harness 10/10** score (agent tooling + docs wiring).

## Scoring rule

- Visible badge: `Engineering X/10`.
- **Overall score = minimum** of all area scores.
- Each area is **binary** for now: `10` when proof passes, otherwise `0`.
- **Top-tier claim allowed only when:** Engineering is **10/10** AND
  `bash tool/check_engineering_quality_scorecard_gate.sh` passes.

## Scorecard family (do not conflate)

| Scorecard | Measures | Badge |
| --- | --- | --- |
| Harness | Agent harness wiring + maintenance | `Harness` |
| Engineering (this) | App/portfolio engineering proof | `Engineering` |
| Agent output v1 | Agent run telemetry | none |

## Rollout policy

- Wave 0–1 land measurement + doc honesty; badge may be < 10.
- Waves 2–5 close remaining areas to reach 10/10.

## Areas

| Area | Score | Proof command(s) | Pass criteria |
| --- | ---: | --- | --- |
| Delivery gate | 10/10 | `./bin/checklist` | exit 0 on clean tree |
| Coverage | 10/10 | `COVERAGE_THRESHOLD=85 dart run tool/update_coverage_summary.dart --enforce-threshold` + `bash tool/check_engineering_core_coverage.sh` | filtered ≥85% AND app shell (bootstrap/DI/router) aggregate ≥75% (unit baseline `coverage/lcov.base.info` from `tool/test_coverage.sh`; if integration merge left `coverage/lcov.info` below 85%, restore from that baseline—do not lower the gate) |
| Architecture / modularity | 10/10 | `bash tool/check_clean_architecture_imports.sh && bash tool/check_feature_modularity_leaks.sh && bash tool/modular_metrics.sh --cross-feature-only` | all exit 0; 0 cross-feature edges |
| Quality gates honesty | 10/10 | `bash tool/check_engineering_quality_scorecard_gate.sh` | [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md) has no bare `defer` rows: every item is `promoted`, `reject`, or `ADR-deferred` with an owning link |
| Pattern program | 10/10 | Update [`audits/senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) + `bash tool/check_engineering_quality_scorecard_gate.sh` | Tier A has no R; Tier B **in scorecard** has no R; exceptions are explicitly listed |
| Doc honesty | 10/10 | `bash tool/check_engineering_quality_scorecard_gate.sh` | [`interview_showcase.md`](../interview_showcase.md) has no stale hardcoded “~399 tests” / “60% gate”; docs point to current enforcement |
| Validation honesty | 10/10 | `bash tool/check_engineering_quality_scorecard_gate.sh` | README + showcase docs explicitly state PR lane vs dispatch/local integration lane |
| Portfolio scope | 10/10 | `bash tool/check_engineering_quality_scorecard_gate.sh` | README badges/claims match ADR-0005 (Crashlytics only when Firebase; analytics SDKs plan-only) |

## Exceptions (explicit out-of-scorecard items)

| Item | Why excluded | Evidence |
| --- | --- | --- |
| `staff_app_demo` P3 boundary grade | Firestore-map adapters are intentionally not worth refactoring inside ADR-0005 interview scope | [`docs/audits/senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md), [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md) |

## Claim Gate

Do **not** claim “portfolio top-tier engineering” unless:

1. README Engineering badge is **10/10** (derived from this table via `tool/update_engineering_quality_badge.sh`).
2. `bash tool/check_engineering_quality_scorecard_gate.sh` exits 0 (wiring +, when Coverage=10/10, measured coverage proofs).
3. Harness remains a separate claim (`docs/ai/harness_scorecard.md`); never substitute Harness for Engineering.

## Proof Commands

```bash
bash tool/check_engineering_quality_scorecard_gate.sh
bash tool/update_engineering_quality_badge.sh --check
COVERAGE_THRESHOLD=85 dart run tool/update_coverage_summary.dart --enforce-threshold
bash tool/check_engineering_core_coverage.sh
./bin/checklist
```

CI / checklist still enforce a **75%** filtered floor by default. Engineering Coverage **10/10** requires the **85%** threshold above plus app-shell **≥75%**.

## Out of Scope

Per [`docs/adr/0005-interview-showcase-scope.md`](../adr/0005-interview-showcase-scope.md):

- Production auth roles/claims hardening
- Sentry / Mixpanel / Patrol as shipped product
- Full PR iOS integration on every push (dispatch/local lane remains)
- Non-showcase demo pattern debt listed under Exceptions
