
# AI-First Software Engineering Execution Plan (build-ready)

**Cursor draft:** this file.  
**Repo canon (on build):** [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](docs/plans/2026-05-21_ai_first_engineering_plan.md) — full narrative.  
**Operator index:** [`PLAN.md`](PLAN.md) — **short** entry only (~120 lines max).  
**Change log:** [`docs/plans/ai_first_engineering_plan_changelog.md`](docs/plans/ai_first_engineering_plan_changelog.md).

## Execution status (2026-05-21)

| Step | Status | Proof |
| --- | --- | --- |
| Waves 1A–1C + Wave 2 | **Shipped** | PR [#239](https://github.com/redjadet/flutter_bloc_app/pull/239), branch `docs/ai-first-engineering` |
| Phase 1–3 doc exits | **Met** | 16+15 feature map, CONTEXT_MAP pilots, audits, governance |
| Phase 4 code | **Pending** | After PR merge |
| Phase 5 automation | **Backlog** | Feature Brief honor system only |

---

## Critique of prior plan version

| Issue | Severity | Fix in this revision |
| --- | --- | --- |
| Wave 1 still ~18 files / one PR | **High** | Split **1A → 1B → 1C** (3 reviewable PRs) |
| Seven root-level `.md` files | **High** | Only `CODEMAP.md` + `PLAN.md` at root; audits/reports under `docs/plans/` or `ai/reports/` |
| `PLAN.md` “shorten from Cursor plan” undefined | **High** | `PLAN.md` = **index only**; long body lives in `docs/plans/` |
| `feature_map.md` × 32 features manual | **High** | **15 full + 17 stub** required; list of 15 named below |
| `DOMAIN_LANGUAGE_REPORT` via one `rg` | **Medium** | v1 = top-50 terms + overload list; full glossary **Wave 2** |
| `CONTRACTS.md` × 32 stubs “optional” | **Medium** | Wave 2 = **global rules + 5 pilot** features only |
| `docs/ai/contracts.md` + root `CONTRACTS.md` | **Medium** | **Single rules file:** `CONTRACTS.md`; `docs/ai/contracts.md` = link stub only |
| `ARCHITECTURE_AUDIT` vs `ai/reports/architecture_audit` | **Medium** | **One file:** `ARCHITECTURE_AUDIT.md`; `ai/reports/README` links it |
| `AGENTS.md` new `## AI Engineering` section | **Low** | **Map bullets only** (no new H2); 64→~75 lines, under 120 cap |
| FEATURE_TEMPLATE gate | **Low** | **Doc-only honor system** until Phase 5; labeled **not enforced yet** |
| Five agent roles | **Low** | Doc convention only; not CI-enforceable — OK |
| No staleness / ownership on reports | **Medium** | Frontmatter + “refresh when” in `ai/README.md` |
| KPIs without numeric baselines | **Low** | Baselines captured in Wave 1A preflight |

**Philosophy kept:** AI multiplies good architecture; `docs/` stays source of truth; no `lib/` until Phase 4.

---

## Readiness matrix (honest)

### Ready to build now (Wave 1A)

| Item | Owner path | Done when |
| --- | --- | --- |
| Preflight + `/tmp` evidence | commands in plan | 4 artifact files exist locally |
| `docs/plans/ai_first_engineering_plan_changelog.md` | docs | Table from §1 complete |
| `ai/README.md` + `ai/reports/README.md` | ai | Authority + index + refresh policy |
| `architecture_overview.md` | ai/reports | Mermaid + layer table; links canon |
| `dependency_map.md` | ai/reports | modular_metrics output cited |
| `anti_patterns.md` | ai/reports | ≥8 repo-specific rows |
| `data_flow_map.md` | ai/reports | ≥3 paths + offline-first link |
| `CODEMAP.md` | root | ≤80 lines; task → paths |

### Ready after 1A merges (Wave 1B) — needs evidence + time

| Item | Blocker | Done when |
| --- | --- | --- |
| `feature_map.md` | Manual effort ~4–6h | 15 full + 17 stub sections |
| `ai/CONTEXT_MAP.md` | Depends on feature_map | Table matches minimal_context |
| `context_hotspots.md` | Needs hotspot file | Top 20 table with phase4 column |
| `ai_recommendations.md` | Needs audit + map | ≥5 `REC-###` with evidence paths |
| `ARCHITECTURE_AUDIT.md` | Needs cross-feature + hotspots | ≥10 `ARCH-###` ranked |
| `DOMAIN_LANGUAGE_REPORT.md` v1 | Needs rg terms file | Top-50 + overload; not full glossary |

### Not ready until Wave 2

| Item | Why |
| --- | --- |
| `docs/domain/domain_glossary.md` | Requires curated terms from v1 report + human pass |
| `docs/testing/testing_strategy.md` | Must be **router** (~80 lines); canon stays `testing_overview.md` |
| `FEATURE_TEMPLATE.md` | Ready to **author** in W2; **not enforced** by CI yet |
| `CONTRACTS.md` full stubs (32) | Only **5 pilots** in W2: `counter`, `chat`, `auth`, `settings`, `todo_list` |
| `docs/ai/*` + `governance.md` | Depends on stable `CODEMAP` + `PLAN` index |
| `AGENTS.md` pointer edits | After `docs/ai/governance.md` exists; verify ≤120 lines |

### Not ready until Phase 4+

| Item | Why |
| --- | --- |
| Code refactors | Needs `ARCH-###` + Feature Brief + RED test |
| `ai/reports/FINAL_OPTIMIZATION_REPORT.md` | After first refactor PR |
| Mechanical Feature Brief / contract guards | Phase 5; no script spec yet |
| 32/32 contract bodies | Incremental after pilots prove format |

---

## Doc authority (fix sprawl)

```text
docs/                          # behavior & engineering canon (unchanged)
docs/plans/                    # long PLAN + changelog + FEATURE_TEMPLATE (W2)
docs/ai/                       # governance & prompts (W2)
docs/domain/                   # glossary SoT (W2)

ai/reports/                    # evidence snapshots (W1)
ai/CONTEXT_MAP.md              # minimal context (W1B)

CODEMAP.md                     # root task router (W1A)
PLAN.md                        # short index only (W1C)
EXECUTIVE_SUMMARY.md           # docs/plans/ (preferred) OR root if user insists

ARCHITECTURE_AUDIT.md          # root OR docs/audits/ — pick one: docs/audits/ai_architecture_audit.md
DOMAIN_LANGUAGE_REPORT.md      # docs/audits/ai_domain_language_report.md (preferred over root)
CONTRACTS.md                   # root (W2) — single rules source
```

**Decision:** Prefer new audits under [`docs/audits/`](docs/audits/) and link from `ai/reports/README.md`. Keeps repo root clean. If user requires root filenames from original spec, copy or symlink in Wave 1C only.

---

## 1. `PLAN_CHANGELOG` (build first)

Path: [`docs/plans/ai_first_engineering_plan_changelog.md`](docs/plans/ai_first_engineering_plan_changelog.md)

Use classification table from prior plan §1 (Keep/Merge/Rewrite/Remove/Missing) — already drafted there; copy verbatim on build.

---

## 2. Alignment — `FEATURE_TEMPLATE.md` (Wave 2)

Path: [`docs/plans/FEATURE_TEMPLATE.md`](docs/plans/FEATURE_TEMPLATE.md) (not root — matches [`docs/plans/README.md`](docs/plans/README.md) convention).

Sections: Feature Brief + AI Alignment Checklist + trivial-fix quick path.

Link from [`docs/feature_implementation_guide.md`](docs/feature_implementation_guide.md) (one paragraph, Wave 2).

**Enforcement:** **Not ready** — honor system only until Phase 5 (e.g. PR template or `tool/check_feature_brief_linked.sh` TBD).

---

## 3. Ubiquitous language (split v1 / SoT)

| Deliverable | Wave | Content |
| --- | --- | --- |
| `docs/audits/ai_domain_language_report_v1.md` | 1B | Top-50 terms, overloads, duplicates, “do not rename” |
| `docs/domain/domain_glossary.md` | 2 | Curated SoT table; migrate terms from v1 |

**v1 extraction command** (bounded):

```bash
rg -o '\b([A-Z][a-zA-Z0-9]*(?:Cubit|Bloc|Repository|Service|UseCase|Failure|Exception|State|Event|Dto))\b' lib \
  --glob '*.dart' --glob '!**/*.freezed.dart' --glob '!**/*.g.dart' \
  | sort | uniq -c | sort -nr | head -80 > /tmp/ai_first_terms_freq.txt
```

Human curates top 50 into report — **not** auto-written glossary.

---

## 4. Test-first — `docs/testing/testing_strategy.md` (Wave 2)

**Max ~80 lines.** Structure:

- RED / GREEN / REFACTOR (5 lines each)
- Layer table (link `testing_overview.md` for detail)
- AI test rules (5 bullets)
- Flaky prevention (3 bullets)
- Validation links

**Rule:** No copy-paste from [`docs/testing_overview.md`](docs/testing_overview.md).

---

## 5. `ARCHITECTURE_AUDIT.md` (Wave 1B)

Path: [`docs/audits/ai_architecture_audit.md`](docs/audits/ai_architecture_audit.md) (preferred).

Minimum bar for merge:

- ≥10 `ARCH-###` issues with evidence path
- ≥3 cross-feature import examples (from modular_metrics)
- ≥5 hotspot rows referenced
- Each issue: problem, impact, recommendation, migration difficulty, tests needed

Target module shape (reference only — link `docs/clean_architecture.md`).

---

## 6. `CONTRACTS.md` (Wave 2)

**Wave 2 minimum:**

1. Global AI contract rules (1 page)
2. Empty template section
3. **Pilot stubs only:** `counter`, `chat`, `auth`, `settings`, `todo_list`

[`docs/ai/contracts.md`](docs/ai/contracts.md): ≤15 lines linking to root `CONTRACTS.md` — **not** duplicate rules.

---

## 7. Governance (Wave 2)

[`docs/ai/governance.md`](docs/ai/governance.md): full roles, handoff, stop conditions.

[`AGENTS.md`](AGENTS.md) — **Map bullets only** (current 64 lines):

```markdown
- AI engineering: [`PLAN.md`](PLAN.md), [`CODEMAP.md`](CODEMAP.md), [`docs/ai/governance.md`](docs/ai/governance.md)
```

Optional **Start** line 2: `PLAN.md` (index). Re-run `wc -l AGENTS.md` — must stay ≤120.

**Not ready:** `## AI Engineering` table in AGENTS — risks map-only drift; use governance doc anchors instead.

---

## 8. `docs/ai/` (Wave 2)

| File | Max lines |
| --- | --- |
| `repo_map.md` | 60 |
| `decision_log.md` | seed 5 decisions from this plan |
| `prompt_patterns.md` | 6 patterns × ~15 lines |
| `context_loading.md` | 50; link agent KB ladder |

---

## 9. Five phases (unchanged intent, tighter exits)

| Phase | Objective | Exit criterion (measurable) |
| --- | --- | --- |
| 1 Stabilisation | Legible architecture | 1A+1B+1C merged; agent KB pass; 15+17 feature map |
| 2 Workflow | Alignment + contracts + TDD doc | Template + 5 pilots + testing_strategy router |
| 3 Velocity | Context minimisation | CONTEXT_MAP ≤8 files for 5 pilots |
| 4 Scalability | Code debt | 1 ARCH merged with tests + checklist |
| 5 Continuous | No rot | decision_log + refresh note in ai/README |

---

## 10. `PLAN.md` + executive summary (Wave 1C)

### `PLAN.md` (root, **index only**)

Sections only:

1. Philosophy (5 bullets)
2. Doc authority diagram (text)
3. Phase table → links to `docs/plans/...`
4. Wave 1A/1B/1C checklist (links)
5. What is **not enforced yet**
6. Validation commands

**Not ready** until 1B done: final ARCH count, REC list, feature coverage stats for executive summary.

### `EXECUTIVE_SUMMARY.md`

Path: [`docs/plans/ai_first_engineering_executive_summary.md`](docs/plans/ai_first_engineering_executive_summary.md) (preferred over root).

Fill after 1B with real metrics from preflight (feature count, cross-import count, top hotspot).

---

## Wave 1A — first PR (ready now)

**Branch:** `docs/ai-first-w1a`

| # | File |
| --- | --- |
| 1 | `docs/plans/ai_first_engineering_plan_changelog.md` |
| 2 | `ai/README.md` |
| 3 | `ai/reports/README.md` |
| 4 | `ai/reports/architecture_overview.md` |
| 5 | `ai/reports/dependency_map.md` |
| 6 | `ai/reports/anti_patterns.md` |
| 7 | `ai/reports/data_flow_map.md` |
| 8 | `CODEMAP.md` |

**Preflight** (required before writing #4–7):

```bash
git status --short
bash tool/modular_metrics.sh > /tmp/ai_first_modular_metrics.txt
bash tool/modular_metrics.sh --cross-feature-only > /tmp/ai_first_cross_feature.txt
```

**Validate 1A:**

```bash
npx markdownlint-cli2 "docs/plans/ai_first_engineering_plan_changelog.md" "ai/**/*.md" "CODEMAP.md"
git diff --check
./tool/check_agent_knowledge_base.sh
```

---

## Wave 1B — second PR (after 1A merge)

**Branch:** `docs/ai-first-w1b`

**15 features — full entries** (from [`docs/feature_overview.md`](docs/feature_overview.md)):

`counter`, `auth`, `settings`, `example`, `chat`, `todo_list`, `profile`, `search`, `case_study_demo`, `chart`, `graphql_demo`, `iot_demo`, `staff_app_demo`, `online_therapy_demo`, `google_maps`, `walletconnect_auth`

**17 features — stub** (`status: stub` + purpose one-liner only):

All other `lib/features/*` dirs.

| File |
| --- |
| `ai/reports/feature_map.md` |
| `ai/reports/context_hotspots.md` |
| `ai/reports/ai_recommendations.md` |
| `docs/audits/ai_architecture_audit.md` |
| `docs/audits/ai_domain_language_report_v1.md` |
| `ai/CONTEXT_MAP.md` |

---

## Wave 1C — third PR (after 1B merge)

| File |
| --- |
| `docs/plans/2026-05-21_ai_first_engineering_plan.md` (this plan body) |
| `PLAN.md` (index) |
| `docs/plans/ai_first_engineering_executive_summary.md` |
| `docs/plans/README.md` (index line) |

---

## Wave 2 PR (not ready until 1C merged)

`FEATURE_TEMPLATE`, `CONTRACTS`+pilots, `domain_glossary`, `testing_strategy`, `docs/ai/*`, `governance`, `AGENTS` Map line.

Update [`docs/validation_scripts.md`](docs/validation_scripts.md) if new checks added (Phase 3).

---

## Validation (all doc waves)

```bash
npx markdownlint-cli2 "PLAN.md" "CODEMAP.md" "docs/plans/**/*.md" "docs/audits/ai_*.md" "docs/ai/**/*.md" "ai/**/*.md"
git diff --check
./tool/check_agent_knowledge_base.sh
```

AGENTS/host template change → `sync_agent_assets.sh --dry-run` + `check_agent_asset_drift.sh`.

---

## Build order (execute)

1. ~~Wave 1A–1C + Wave 2~~ — **done** in PR #239  
2. **Now:** merge PR #239 (`bash tool/commit_push_pr_watch_merge_cleanup.sh 239`)  
3. **Next:** Phase 4 — one `ARCH-###` with Feature Brief + RED test (see audit)  
4. **Later:** Phase 5 refresh automation  

**commit-push-pr:** rebase on `origin/main`; no AI in commit messages.

---

## Assumptions

- 32 feature directories; 15+17 map acceptable for Phase 1 exit.
- Audits under `docs/audits/` unless user requires root audit filenames.
- `docs/` canon; new files route/constrain.
- No `lib/`/`test/` in Waves 1–2.
