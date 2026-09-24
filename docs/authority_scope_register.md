# Authority scope register

**Date:** 2026-09-24  
**Owner:** Human (İlker Sevim)  
**Evidence:** [`changes/2026-09-24_authority_phase_0_evidence_baseline.md`](changes/2026-09-24_authority_phase_0_evidence_baseline.md)  
**Phase 3 delivery:** [`changes/2026-09-24_authority_phase_3_reliability_observability.md`](changes/2026-09-24_authority_phase_3_reliability_observability.md)

This register freezes what the active authority window **will not** open.
Feature tier tags live in [`feature_overview.md`](feature_overview.md).
Interview spine policy: [ADR-0005](adr/0005-interview-showcase-scope.md).

## Non-goals (active window)

See plan Non-goals. Highlights:

- No Riverpod / BlocSignal rewrite.
- No Mixpanel / Patrol / Sentry *only* for JD keywords ([ADR 0008](adr/0008-sentry-go-no-go.md)).
- No first-class Linux/Windows consumer desktop.
- No full role/claims IAM ([defer note](changes/2026-09-24_role_claims_iam_defer.md)).
- No home-screen widgets or background-OS product without Archive swap.
- No FastAPI/Render dual-deploy hardening (**W12 still deferred**).
- No public ≤15 min architecture tour (Phase 4).
- No migrate-every-Depth-to-gold; no Hive → Isar/Drift.

## Phase 2 (shipped)

Teaching pack under [`platforms/README.md`](platforms/README.md)
(capability + fidelity matrices, iOS/Android notes, typed stub statuses,
adaptive chrome pointer). Background OS demo and home-screen widgets remain
**non-goals** unless Archive swap + ADR.

## Phase 3 (opened this slice)

| Work | Artifact |
| --- | --- |
| Sentry go/no-go | [ADR 0008](adr/0008-sentry-go-no-go.md) — **no-go** |
| Sync diagnostics proof boundary | [ADR 0009](adr/0009-sync-diagnostics-interview-coverage.md) — document gap |
| Role/claims IAM | [Defer note](changes/2026-09-24_role_claims_iam_defer.md) |
| Measured spine perf vs budgets | Fixture gate via `tool/testdata/perf/pass_trace.json` + `analyze_perf_trace` (live device capture deferred) |
| Sanitized AIDLC / SAFETY-REPORT sample | [`ai/sanitized_aidlc_safety_report_sample.md`](ai/sanitized_aidlc_safety_report_sample.md) |
| FastAPI/Render ops (W12) | **Still deferred** — not opened |

## Deferred Phase 4 (do not start without a new plan slice)

| Phase | Deferred work |
| --- | --- |
| 4 | Public architecture tour; Contributing Spine-first + HITL expectations; keep `llms.txt` + CODEMAP accurate |
| W12 | Render/FastAPI chat ops — provenance, threat-model hardening table, pytest/Pyright smoke, secret rotation |

## Dated decisions (defaults current)

| Item | Default | Owner | Trigger | Artifact |
| --- | --- | --- | --- | --- |
| Background OS demo | Non-goal | Human | Product need + Archive swap | ADR / change note |
| Home-screen widgets | Non-goal | Human | Archive swap | ADR |
| Sync diagnostics E2E | Document gap; no fake PR-smoke | Human | Interview need | [ADR 0009](adr/0009-sync-diagnostics-interview-coverage.md) |
| Sentry | No-go (Crashlytics-first) | Human | Real observability gap | [ADR 0008](adr/0008-sentry-go-no-go.md) |
| Role/claims IAM | Defer | Human | Product auth need | [Spike note](changes/2026-09-24_role_claims_iam_defer.md) |
| FastAPI/Render dual targets | Defer (W12) | Human | Public tour includes chat backend | Ops plan |
| Native bridge tests beyond telemetry | Defer / optional follow-up | Human | Platform teaching need | Swift/Kotlin smoke |

## Archive rule reminder

No **net-new** demo modules unless an Archive-tier feature is replaced or
promoted. Acknowledge on the PR checklist when adding a demo route.
