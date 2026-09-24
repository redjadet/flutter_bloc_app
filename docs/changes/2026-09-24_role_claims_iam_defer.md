# Role / claims IAM — spike-or-defer (Phase 3)

**Date:** 2026-09-24  
**Decision:** **Defer** full role/claims IAM.  
**Owner:** Human (İlker Sevim)  
**Related:** [`authority_scope_register.md`](../authority_scope_register.md),
[`authentication.md`](../authentication.md), Collaboration map security table.

## Why defer

- No product requirement for fine-grained claims in the interview spine.
- Auth already covers session / gated routes; role expansion is high blast-radius.
- HITL: production auth / IAM design is human-only.

## Spike outline (if revisited)

1. Map current auth session claims vs needed roles.
2. Decide claim source (Firebase custom claims vs app profile).
3. Router + repository enforcement matrix; no UI-only gating.
4. ADR before implementation.

## Non-goal this window

Do not ship role/claims middleware or claim UI without a superseding ADR.
