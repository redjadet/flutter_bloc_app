# Scope register

**Date:** 2026-09-24  
**Owner:** Human (İlker Sevim)  
**Evidence:** [`changes/2026-09-24_authority_phase_0_evidence_baseline.md`](changes/2026-09-24_authority_phase_0_evidence_baseline.md)  
**Phase 3 delivery:** [`changes/2026-09-24_authority_phase_3_reliability_observability.md`](changes/2026-09-24_authority_phase_3_reliability_observability.md)  
**Phase 4 delivery:** [`changes/2026-09-24_authority_phase_4_architecture_tour.md`](changes/2026-09-24_authority_phase_4_architecture_tour.md)

This register freezes what the active scope window **will not** open.
Feature tier tags live in [`feature_overview.md`](feature_overview.md).
Interview spine policy: [ADR-0005](adr/0005-interview-showcase-scope.md).

## Non-goals (active window)

See plan Non-goals. Highlights:

- No Riverpod / BlocSignal rewrite.
- No Mixpanel / Patrol / Sentry *only* for JD keywords ([ADR 0008](adr/0008-sentry-go-no-go.md)).
- No first-class Linux/Windows consumer desktop.
- No full role/claims IAM ([defer note](changes/2026-09-24_role_claims_iam_defer.md)).
- No home-screen widgets or background-OS product without Archive swap.
- FastAPI/Render dual-deploy ops shipped as **W12** ([`integrations/render_chat_ops.md`](integrations/render_chat_ops.md)).
- No migrate-every-Depth-to-gold; no Hive → Isar/Drift.

## Phase 2 (shipped)

Teaching pack under [`platforms/README.md`](platforms/README.md).

## Phase 3 (shipped)

| Work | Artifact |
| --- | --- |
| Sentry go/no-go | [ADR 0008](adr/0008-sentry-go-no-go.md) — **no-go** |
| Sync diagnostics proof boundary | [ADR 0009](adr/0009-sync-diagnostics-interview-coverage.md) |
| Role/claims IAM | [Defer note](changes/2026-09-24_role_claims_iam_defer.md) |
| Measured spine perf vs budgets | Fixture gate (live device capture deferred) |
| Sanitized AIDLC / SAFETY-REPORT sample | [`ai/sanitized_aidlc_safety_report_sample.md`](ai/sanitized_aidlc_safety_report_sample.md) |
| FastAPI/Render ops (W12) | **Shipped** — [`integrations/render_chat_ops.md`](integrations/render_chat_ops.md) |

## Phase 4 (shipped)

| Work | Artifact |
| --- | --- |
| Public ≤15 min architecture tour | [`architecture_tour.md`](architecture_tour.md) |
| Contributing Spine-first + HITL | [`contributing/contributing.md`](contributing/contributing.md) |
| `llms.txt` + CODEMAP accuracy | Root [`llms.txt`](../llms.txt), [`CODEMAP.md`](../CODEMAP.md) |

## Still deferred

None from the quality plan after W12. Claim-ledger SHA refresh +
visitor P2 polish shipped earlier; `authority_*` filenames renamed to
[`scope_register.md`](scope_register.md) and [`offline_first/invariants.md`](offline_first/invariants.md).

## Dated decisions (defaults current)

| Item | Default | Owner | Trigger | Artifact |
| --- | --- | --- | --- | --- |
| Background OS demo | Non-goal | Human | Product need + Archive swap | ADR / change note |
| Home-screen widgets | Non-goal | Human | Archive swap | ADR |
| Sync diagnostics E2E | Document gap; no fake PR-smoke | Human | Interview need | [ADR 0009](adr/0009-sync-diagnostics-interview-coverage.md) |
| Sentry | No-go (Crashlytics-first) | Human | Real observability gap | [ADR 0008](adr/0008-sentry-go-no-go.md) |
| Role/claims IAM | Defer | Human | Product auth need | [Spike note](changes/2026-09-24_role_claims_iam_defer.md) |
| FastAPI/Render dual targets | Dual intentional; FastAPI Cloud canonical ([ops](integrations/render_chat_ops.md)) | Human | Tour cites chat backend | Ops + hardening table |
| Native bridge tests beyond telemetry | Defer / optional follow-up | Human | Platform teaching need | Swift/Kotlin smoke |

## Archive rule reminder

No **net-new** demo modules unless an Archive-tier feature is replaced or
promoted. Acknowledge on the PR checklist when adding a demo route.
