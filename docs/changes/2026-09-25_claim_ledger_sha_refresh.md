# Claim ledger SHA refresh

**Date:** 2026-09-25  
**Base:** `main` @ `512a09c2a1272ea55b6840c67eac4788697d76fb` (`512a09c2`, post-#911)  
**Owner ledger:** [`2026-09-24_authority_phase_0_evidence_baseline.md`](2026-09-24_authority_phase_0_evidence_baseline.md)

## Intent

Re-stamp existing Phase 0A claims to current `main` without inventing new
claims. Historical Phase 0A gate rows stay as written; the ledger SHA column is
the live “last verified” pointer.

## Re-verification (no new claims)

| Check | Result | Notes |
| --- | --- | --- |
| Feature Cubits | **57** | `find apps/mobile/lib/features -name '*_cubit.dart' \| wc -l` |
| Feature Blocs | **0** | No `*_bloc.dart` under features (Cubit-first) |
| Feature modules | **40** | `find … -mindepth 1 -maxdepth 1 -type d` |
| Toolchain pins | Flutter **3.47.5** / Dart **3.13.4** | [`../toolchain_versions.env`](../toolchain_versions.env) |
| Harness scorecard gate | Pass | `bash tool/check_harness_scorecard_gate.sh` |
| Engineering scorecard gate | Pass | `bash tool/check_engineering_quality_scorecard_gate.sh` (filtered **86.80%**, app-shell **83.54%**) |
| Evidence paths | Present | Same paths as Phase 0A ledger rows |

`#910` / `#911` were docs/ops only — app claim surfaces above unchanged vs the
Phase 0A measurement window.

## Honesty notes updated on owner ledger

- Platforms teaching pack: **shipped** (Phase 2) — no longer “deferred”.
- FastAPI/Render dual-deploy ops: **shipped** as W12 — no longer “deferred”.

## Tests

Docs + existing scorecard gates only (no app runtime change).
