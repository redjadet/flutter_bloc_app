# Audits (local snapshots)

Machine-generated inventories and one-off reviews live here. **Git tracks** this README and `dedup_matrix_*.md`; JSON and other snapshots are gitignored (see root `.gitignore`).

## Regenerate

```bash
dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
dart run tool/skill_rank.dart docs/audits/skill_inventory_latest.json docs/audits/skill_rank_latest.json
bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json report
```

Publish summaries in [`docs/changes/`](../changes/), not bulk JSON. Optional local-only audits (e.g. `ai_architecture_audit.md`, `ai_domain_language_report_v1.md`) may exist for cross-links — regenerate or `git add -f` only when promoting findings.
