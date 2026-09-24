# Architecture tour (≤15 minutes)

**Audience:** Visitors who need the **four pillars** without a full interview
demo. **Not** a substitute for the 30-minute spine
([`interview_showcase.md`](interview_showcase.md) §3) or the 12-minute
production-ownership walk (§3b).

**Date:** 2026-09-24  
**Scope:** Read paths + open one code folder per pillar. No product SDK adds.

| Min | Pillar | Do | Open |
| --- | --- | --- | --- |
| 0–1 | Four pillars | Name all **four** pillars; point at README Four pillars + Scope register | [`README.md`](../README.md#four-pillars), [`authority_scope_register.md`](authority_scope_register.md) |
| 1–4 | Flutter / Cubit / CA | Feature module shape + sealed Cubit state; modularity gate | [`apps/mobile/lib/features/counter/`](../apps/mobile/lib/features/counter/), [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md), [`engineering/engineering_quality_scorecard.md`](engineering/engineering_quality_scorecard.md) |
| 4–7 | Offline-first | Sync honesty + W3 invariants; one offline feature | [`offline_first/adoption_guide.md`](offline_first/adoption_guide.md), [`offline_first/authority_invariants.md`](offline_first/authority_invariants.md), Counter or Todo |
| 7–11 | Native interop | Teaching pack matrices; live showcase ports (not “every API wrapped”) | [`platforms/README.md`](platforms/README.md), [`apps/mobile/lib/features/native_platform_showcase/`](../apps/mobile/lib/features/native_platform_showcase/) |
| 11–15 | Human–AI HITL | Collaboration map → safety → finish gate; one SAFETY-REPORT sample | [`ai/human_ai_collaboration.md`](ai/human_ai_collaboration.md), [`agent_kb/agent_safety_contracts.md`](agent_kb/agent_safety_contracts.md), [`ai/sanitized_aidlc_safety_report_sample.md`](ai/sanitized_aidlc_safety_report_sample.md) |

## Optional one-liners (if asked)

| Follow-up | Point here |
| --- | --- |
| “Prove validation” | `./bin/checklist-fast` / [`validation_scripts.md`](validation_scripts.md) |
| “Where do agents start?” | [`AGENTS.md`](../AGENTS.md), [`CODEMAP.md`](../CODEMAP.md) |
| “Longer demo?” | [`interview_showcase.md`](interview_showcase.md) §3 / §3b |

## Honesty

- Claims still cite the dated ledger under [`changes/`](changes/README.md).
- Archive modules are frozen unless promoted ([ADR 0005](adr/0005-interview-showcase-scope.md)).
- Sentry is **no-go** this window ([ADR 0008](adr/0008-sentry-go-no-go.md)).
- Sync diagnostics UI is **manual**, not fake PR-smoke ([ADR 0009](adr/0009-sync-diagnostics-interview-coverage.md)).
