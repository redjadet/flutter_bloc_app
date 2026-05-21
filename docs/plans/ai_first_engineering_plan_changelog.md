# AI-first engineering plan — changelog

Classification of prior operability / AI-agent ideas against this repo (2026-05-21).

| Item | Class | Decision | Reasoning | Impact | Migration risk |
| --- | --- | --- | --- | --- | --- |
| `AGENTS.md` as long playbook | Keep | Stay map-only (≤120 lines) | Repo gate `check_agent_knowledge_base.sh`; canon in `docs/` | Agents load less noise; stable host sync | Low |
| `docs/agent_knowledge_base.md` harness | Keep | System of record for operator prefs | Already owns durable learnings | No duplicate prefs in AGENTS | Low |
| Duplicate architecture prose in root | Merge | `docs/architecture_details.md` + `ai/reports/architecture_overview.md` | Root stays routers/audits only | One narrative + one agent snapshot | Low |
| `/ai` hybrid tree | Keep | `ai/reports/` evidence; `docs/ai/` governance (Wave 2) | Separates snapshots from canon | Agents get stable entry | Low |
| `CODEMAP.md` at root | Keep | Task → path router | Faster than scanning AGENTS Map | New file; linked from AGENTS | Low |
| `PLAN.md` at root | Rewrite | Index only (~120 lines) | Full plan in `docs/plans/` | Operators + agents share entry | Low |
| `EXECUTIVE_SUMMARY` at root | Merge | `docs/plans/ai_first_engineering_executive_summary.md` | Matches plans/ convention | Less root sprawl | Low |
| `ARCHITECTURE_AUDIT` at root | Merge | `docs/audits/ai_architecture_audit.md` (force-add) | Audits folder gitignored by default | Evidence tracked when `-f` | Low |
| `DOMAIN_LANGUAGE_REPORT` at root | Merge | `docs/audits/ai_domain_language_report_v1.md` | v1 findings; glossary SoT in Wave 2 | Phased language work | Medium |
| `CONTRACTS.md` at root | Keep | Global rules + pilot stubs (Wave 2) | Single contract source | `docs/ai/contracts.md` links only | Low |
| `FEATURE_TEMPLATE` at root | Merge | `docs/plans/FEATURE_TEMPLATE.md` | Aligns with other plans | Feature guide gets one link | Low |
| Copy `testing_overview` | Remove | `docs/testing/testing_strategy.md` router only | Avoid duplicate canon | Shorter agent context | Low |
| 32 full feature contracts | Remove | 5 pilot stubs only | Cost vs value | Incremental adoption | Low |
| Mechanical Feature Brief CI | Missing | Phase 5 | Honor system until script exists | No false gates | N/A |
| `lib/` refactors in doc PR | Remove | Phase 4 only | Smallest reversible change | No behavior change in Waves 1–2 | N/A |
| Seven reports in one PR | Rewrite | Waves 1A / 1B / 1C (+ Wave 2) | Reviewable slices | Slower merge count, safer review | Low |
| Agent role table in AGENTS | Remove | `docs/ai/governance.md` | Map-only policy | AGENTS line budget | Low |
| Report refresh policy | Missing | `ai/README.md` frontmatter | Prevents stale evidence | Manual refresh until script | Low |

## Locked decisions

1. **`docs/`** owns behavior, validation, and engineering canon.
2. **`ai/reports/`** owns dated discovery snapshots cited by audits.
3. **`PLAN.md`** is an index; narrative lives under **`docs/plans/`**.
4. **No `lib/` or `test/`** changes in Waves 1–2.
5. **Feature map:** 16 full + 15 stub entries (31 feature modules).

## Evidence captured (preflight 2026-05-21)

- `bash tool/modular_metrics.sh` → per-feature LOC, barrels, fan-in.
- `bash tool/modular_metrics.sh --cross-feature-only` → 11 cross-feature import edges (sample).
- Hotspot `wc` → largest part files under `lib/features/`.
- Term frequency `rg` → Cubit/Repository/State naming histogram.
