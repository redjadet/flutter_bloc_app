# Authority Phase 0–1 delivery note

**Date:** 2026-09-24  
**Branch:** `cursor/authority-phase-0`  
**SHA baseline:** `77150a6d` (see evidence change note)

## Why

Publish claim-honest four-pillar Authority Thesis, Archive curation, and HITL
visitor legibility without opening Phase 2–4 paths.

## Shipped

- Phase 0A ledger + gates: [`2026-09-24_authority_phase_0_evidence_baseline.md`](2026-09-24_authority_phase_0_evidence_baseline.md)
- Spine/Depth/Archive tags: [`../feature_overview.md`](../feature_overview.md)
- Scope register + ADR-0005 Decision 7 + PR checklist reminder
- Thesis + HITL landing on README; mirrored in interview showcase
- Collaboration map + new-dev “Working with agents”
- Intentional Yellow disposition; grown `CONTRACTS.md`; offline W3 invariants
- Deep-link auth matrix + matrix unit test; tradeoffs gap closed

## Must remain true

Thesis claims match the 0A ledger. No Phase 2 `docs/platforms/*` or net-new
demos without Archive swap.

## Tests

```bash
cd apps/mobile && flutter test test/app/router/app_route_auth_gate_test.dart test/app/router/auth_redirect_test.dart
./bin/checklist-fast
bash tool/check_engineering_quality_scorecard_gate.sh
bash tool/check_harness_scorecard_gate.sh
```
