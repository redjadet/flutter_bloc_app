# Authority scope register (Phase 0–1)

**Date:** 2026-09-24  
**Owner:** Human (İlker Sevim)  
**Evidence:** [`changes/2026-09-24_authority_phase_0_evidence_baseline.md`](changes/2026-09-24_authority_phase_0_evidence_baseline.md)

This register freezes what Phase 0–1 **will not** open. Feature tier tags live in
[`feature_overview.md`](feature_overview.md). Interview spine policy:
[ADR-0005](adr/0005-interview-showcase-scope.md).

## Non-goals (active window)

See plan Non-goals. Highlights:

- No Riverpod / BlocSignal rewrite.
- No Mixpanel / Patrol / Sentry *only* for JD keywords.
- No first-class Linux/Windows consumer desktop.
- No full role/claims IAM.
- No home-screen widgets or background-OS product without Archive swap.
- No FastAPI/Render dual-deploy hardening (Phase 3+/W12).
- No public ≤15 min architecture tour (Phase 4).
- No migrate-every-Depth-to-gold; no Hive → Isar/Drift.

## Phase 2 (opened)

Teaching pack shipped under [`platforms/README.md`](platforms/README.md)
(capability + fidelity matrices, iOS/Android notes, typed stub statuses,
adaptive chrome pointer). Background OS demo and home-screen widgets remain
**non-goals** unless Archive swap + ADR.

## Deferred Phase 3–4 (do not start without a new plan slice)

| Phase | Deferred work |
| --- | --- |
| 3 | Sync diagnostics decision; measured spine perf; Sentry go/no-go; role/claims spike; sanitized AIDLC sample; FastAPI/Render ops (W12) |
| 4 | Public architecture tour; Contributing Spine-first + HITL expectations; keep `llms.txt` + CODEMAP accurate |

## Dated decisions (defaults current)

| Item | Default | Owner | Trigger | Artifact |
| --- | --- | --- | --- | --- |
| Background OS demo | Non-goal | Human | Product need + Archive swap | ADR / change note |
| Home-screen widgets | Non-goal | Human | Archive swap | ADR |
| Sync diagnostics E2E | Document gap; no fake PR-smoke | Human | Interview need | ADR *or* PR-smoke + script |
| Sentry | No JD-only add | Human | Real observability gap | Go/no-go ADR |
| Role/claims IAM | Defer | Human | Product auth need | Spike note |
| FastAPI/Render dual targets | Defer (Phase 3+/W12) | Human | Public tour includes chat backend | Ops plan |
| Native bridge tests beyond telemetry | Defer to Phase 2 | Human | Platform doc pack | Swift/Kotlin smoke |

## Archive rule reminder

No **net-new** demo modules unless an Archive-tier feature is replaced or
promoted. Acknowledge on the PR checklist when adding a demo route.
