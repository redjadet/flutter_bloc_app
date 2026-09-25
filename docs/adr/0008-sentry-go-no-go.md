# ADR 0008: Sentry Go / No-Go (Crashlytics-first)

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-09-24 |
| Scope | Error monitoring / observability product SDK |
| Source docs | [`observability.md`](../observability.md), [ADR 0005](0005-interview-showcase-scope.md), [ADR 0006](0006-production-readiness-demo.md), [`scope_register.md`](../scope_register.md) |

## Context

The portfolio already ships Crashlytics handlers, structured `AppLogger`, and a
production-readiness FrameTiming demo. [`observability.md`](../observability.md)
describes a possible Crashlytics + Sentry dual-stack plan, but **Sentry is not
installed or initialized**. Phase 3 asked for an explicit go/no-go.

## Decision Drivers

- Do not add JD-keyword SDKs without a measured observability gap.
- Prefer one crash source of truth for the interview spine.
- Keep client secrets / DSN out of Flutter artifacts (HITL human-only).

## Decision

**No-go for shipping Sentry in this window.** Remain Crashlytics-first.
Keep the dual-stack plan in `observability.md` as **aspirational / not
implemented** — not as a shipped claim.

## Alternatives considered

| Option | Why not now |
| --- | --- |
| Add Sentry SDK immediately | JD-only pressure; no measured gap vs Crashlytics |
| Crashlytics + Sentry dual-stack now | Extra DSN/secrets surface; dual triage without operator need |
| Remove Crashlytics | Breaks existing production-readiness / triage docs |

## Consequences

### Benefits

- Honest portfolio claims; smaller secret surface.
- ADR 0005 doc-only Mixpanel/Sentry/Patrol stance preserved.

### Costs

- No Sentry breadcrumbs/tracing until a superseding ADR.

## Review triggers

- Real incident triage shows Crashlytics insufficient (missing context/perf).
- Human requests dual-stack with DSN ownership and retention plan.
- Public tour requires Sentry as a named pillar (then supersede this ADR).

## Verification

- `rg -n "sentry_flutter|SentryFlutter" apps/mobile packages` → no product SDK wiring.
- [`observability.md`](../observability.md) still labels Sentry as not installed.
