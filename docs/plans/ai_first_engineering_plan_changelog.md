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
| `ARCHITECTURE_AUDIT` at root | Merge | docs/audits/ai_architecture_audit (force-add) | Audits folder gitignored by default | Evidence tracked when `-f` | Low |
| `DOMAIN_LANGUAGE_REPORT` at root | Merge | docs/audits/ai_domain_language_report_v1 | v1 findings; glossary SoT in Wave 2 | Phased language work | Medium |
| `CONTRACTS.md` at root | Keep | Global rules + pilot stubs (Wave 2) | Single contract source | `docs/ai/contracts.md` links only | Low |
| `FEATURE_TEMPLATE` at root | Merge | `docs/plans/FEATURE_TEMPLATE.md` | Aligns with other plans | Feature guide gets one link | Low |
| Copy `testing_overview` | Remove | `docs/testing/testing_strategy.md` router only | Avoid duplicate canon | Shorter agent context | Low |
| 32 full feature contracts | Remove | 5 pilot stubs only | Cost vs value | Incremental adoption | Low |
| Mechanical Feature Brief CI | Keep | `tool/check_feature_brief_linked.sh` (warn default) | Not in full checklist by default | Agents reminded on feature diffs | Low |
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

## Phase 4–5 exit (2026-05-21)

| Item | Status |
| --- | --- |
| ARCH-003 feature barrels | Done — merged via PR #239 |
| Barrel regression tests | Done — `test/features/*/*_barrel_test.dart` |
| PR #239 merge | Done — squash to `main` |
| ARCH-001 / ARCH-002 | **Done** — merged [PR #240](https://github.com/redjadet/flutter_bloc_app/pull/240) (`c703b9b5`) |
| FINAL_OPTIMIZATION_REPORT | Done — `ai/reports/` |
| `check_feature_brief_linked.sh` | Done — warn default; `FEATURE_BRIEF_CHECK_STRICT=1` optional |
| Agent delivery loop doc | Done — [`changes/2026-05-21_agent_automated_delivery_loop.md`](../changes/2026-05-21_agent_automated_delivery_loop.md) |
| Plan split (runtime / build spec) | Done — slim [`2026-05-21_ai_first_engineering_plan.md`](2026-05-21_ai_first_engineering_plan.md); build-spec archive deleted 2026-07-17 (see [`changes/2026-07-17_docs_aggressive_prune.md`](../changes/2026-07-17_docs_aggressive_prune.md)) |

## Evidence captured (preflight 2026-05-21)

- `bash tool/modular_metrics.sh` → per-feature LOC, barrels, fan-in.
- `bash tool/modular_metrics.sh --cross-feature-only` → 11 cross-feature import edges (sample).
- Hotspot `wc` → largest part files under `apps/mobile/lib/features/`.
- Term frequency `rg` → Cubit/Repository/State naming histogram.
