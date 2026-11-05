# Docs: ADR retrieval for coding agents and AI reviewers

## Problem

The repo already records durable architecture and scope decisions in nine
**Accepted** ADRs (layering, offline-first, deferred routes, type-safe Cubit
access, interview spine, production-readiness demo, BlocSignal rejection,
Sentry no-go, sync-diagnostics honesty). Each ADR includes alternatives,
trade-offs, and review triggers, and `tool/check_adr_quality.sh` keeps format
honest.

Agent entry maps and review checklists emphasized *how* (Clean Architecture
guides, import guards) but not a mandatory **retrieve ADRs → flag conflict →
ask to supersede** loop. That matches the failure mode where an agent locally
“fixes” code back to a rejected alternative while tests and import checks still
pass.

## Scope

- In: [`docs/adr/README.md`](../adr/README.md) agent/reviewer section; pointers in [`AGENTS.md`](../../AGENTS.md),
  [`context_loading.md`](../ai/context_loading.md), [`architecture_checklist.md`](../review/architecture_checklist.md),
  [`ai_code_review_protocol.md`](../ai_code_review_protocol.md);
  `RISK-ADR-CONFLICT` in [`ai_failure_risks.md`](../ai/ai_failure_risks.md).
- Out: new ADRs for decisions already covered; app code or dependency changes;
  Claude/Anthropic-specific files.

## Decision

Wire existing ADRs into generation-time and review-time context with explicit
non-silent conflict handling. Keep ADRs challengeable only via supersede flow
already documented in `docs/adr/README.md`.

## Verification

- `bash tool/check_adr_quality.sh`
- `bash tool/check_ai_failure_risk_register.sh`
- Docs gardening on the touched paths (see change note index in [`README.md`](README.md))
