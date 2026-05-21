# AI-first engineering — agent runtime

**Agents:** [`PLAN.md`](../../PLAN.md) (index) → this file (status) → [`ai_first_engineering_executive_summary.md`](ai_first_engineering_executive_summary.md) (metrics). Build spec archive only when auditing history.

## Status (2026-05-21)

| Item | State |
| --- | --- |
| Waves 1A–2 + Phase 1–3 docs | **Done** — [PR #239](https://github.com/redjadet/flutter_bloc_app/pull/239) |
| ARCH-003 barrels | **Done** — PR #239 |
| Phase 5 `check_feature_brief_linked.sh` | **Done** — warn default |
| ARCH-001 / ARCH-002 | **Done** — [PR #240](https://github.com/redjadet/flutter_bloc_app/pull/240) (`c703b9b5`) |
| [`FINAL_OPTIMIZATION_REPORT.md`](../../ai/reports/FINAL_OPTIMIZATION_REPORT.md) | **Done** |
| Plan execution | **Complete** |

## Backlog

- Full 31-feature [`CONTRACTS.md`](../../CONTRACTS.md) bodies (5 pilots only)
- ARCH-004+ — [`audits/ai_architecture_audit.md`](../audits/ai_architecture_audit.md) (`git add -f`)
- Refresh [`ai/reports/`](../../ai/reports/README.md) after large features: `bash tool/modular_metrics.sh`

## Gates (operators)

| Gate | Command |
| --- | --- |
| Full validation | `./bin/checklist` |
| Integration | `./bin/integration_tests` |
| Feature brief (feature diffs) | `bash tool/check_feature_brief_linked.sh` |
| Land PR | [`changes/2026-05-21_agent_automated_delivery_loop.md`](../changes/2026-05-21_agent_automated_delivery_loop.md) |

## Doc validation

```bash
npx markdownlint-cli2 "PLAN.md" "CODEMAP.md" "docs/plans/**/*.md" "ai/**/*.md"
./tool/check_agent_knowledge_base.sh
```
