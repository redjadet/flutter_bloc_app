# Audits (local snapshots)

Machine-generated inventories and one-off reviews live here. **Git tracks** this README, `code_quality_baseline_*.md`, `dedup_matrix_*.md`, and promoted `*_review_*.md` audits; JSON and other snapshots are gitignored (see root `.gitignore`).

## Regenerate

```bash
dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json
bash tool/audit_vendor_plugin_skills.sh docs/audits/vendor_plugin_inventory_latest.json
dart run tool/skill_rank.dart docs/audits/skill_inventory_latest.json docs/audits/skill_rank_latest.json
bash tool/check_skill_budgets.sh docs/audits/skill_inventory_latest.json report
```

Publish **change notes** in [`docs/changes/`](../changes/) for why/what/proof; link to full `*_review_*.md` audits here when scores and evidence tables belong in version control. Bulk JSON stays local — regenerate as needed.

## Habits

Full table: [`validation_scripts/operations_host_skills.md`](../validation_scripts/operations_host_skills.md) § Suggested habits. Short version:

- Regen inventory + budget **report** after global skill install/archive (stale JSON lies about `agentsSkills`).
- Run **vendor plugin audit** after marketplace plugin changes; disable unused plugins in **Cursor → Settings → Plugins** for the largest context win.
- **Reload Cursor** after `trim_duplicate_agent_skills.sh --apply` or `after-host-edit`.
- Monthly (or after plugin churn): vendor audit → plugin toggles → regen inventory → budget report → reload.

## Architecture reviews

| Review | Path |
| --- | --- |
| Staff+ production review (2026-06-15) | [staff_production_review_2026-06-15.md](staff_production_review_2026-06-15.md) |
| Build Readiness program (2026-06) | [architecture_review_2026-06.md](architecture_review_2026-06.md) |

## Code quality baseline (program)

[Code quality baseline and gate promotion (2026-06)](../plans/code_quality_baseline_and_gate_promotion_2026-06.md):

| Artifact | Path |
| --- | --- |
| Baseline snapshot (2026-06-03) | [code_quality_baseline_2026-06-03.md](code_quality_baseline_2026-06-03.md) |
| Phase 0b gate spikes | [code_quality_baseline_spikes_2026-06-03.md](code_quality_baseline_spikes_2026-06-03.md) |
