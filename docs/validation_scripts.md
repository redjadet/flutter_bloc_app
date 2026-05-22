# Validation Scripts Documentation

**Policy:** Agent-facing docs in this tree stay **≤200 lines** per file. Shards live under [`validation_scripts/`](validation_scripts/).

This document describes all validation scripts in the `tool/` directory, their purposes, and when to use them.

## Agent-oriented checks

Catalog entries (including **memory-compounding** and **closed-loop invariants**):
[`check_agent_knowledge_base.sh`](validation_scripts/catalog.md),
[`check_design_md.sh`](validation_scripts/catalog.md),
[`check_agent_memory_compounding.sh`](validation_scripts/catalog.md).

## Quick Reference

- **Run all checks**: `./bin/checklist` (or `./tool/run_validation.sh`)
- **Run specific check**: `./tool/check_<name>.sh`
- **Fix auto-fixable issues**: `./tool/fix_validation_docs.sh` (updates checklist index)
- **Validate docs**: `./tool/validate_validation_docs.sh`

## Contents

| Shard | Topic |
| --- | --- |
| [`validation_scripts/overview.md`](validation_scripts/overview.md) | Running checks, checklist, fix/validate tools |
| [`validation_scripts/catalog.md`](validation_scripts/catalog.md) | Full script catalog by category |
| [`validation_scripts/checklist_index.md`](validation_scripts/checklist_index.md) | Auto-generated checklist script list |
| [`validation_scripts/guides_context_async.md`](validation_scripts/guides_context_async.md) | Context, async, navigation |
| [`validation_scripts/guides_theme_l10n.md`](validation_scripts/guides_theme_l10n.md) | Theme, colors, localization |
| [`validation_scripts/guides_state_layout.md`](validation_scripts/guides_state_layout.md) | State, layout, lifecycle, offline-first |
| [`validation_scripts/guides_performance_lists.md`](validation_scripts/guides_performance_lists.md) | Const, lists, repaint boundary |
| [`validation_scripts/guides_performance_rebuilds.md`](validation_scripts/guides_performance_rebuilds.md) | Rebuilds, concurrent modification |
| [`validation_scripts/guides_memory_typography.md`](validation_scripts/guides_memory_typography.md) | Memory, typography |
| [`validation_scripts/operations_running.md`](validation_scripts/operations_running.md) | Running scripts, CI, troubleshooting |
| [`validation_scripts/operations_host_skills.md`](validation_scripts/operations_host_skills.md) | Host skills, agent assets |
| [`validation_scripts/operations_manual.md`](validation_scripts/operations_manual.md) | Manual validation, related docs |
| [`validation_scripts/upgrade_pr_triage_validate.md`](validation_scripts/upgrade_pr_triage_validate.md) | Upgrade PR triage + `upgrade_validate_all` lane |

## Related Documentation

- [`CODE_QUALITY.md`](CODE_QUALITY.md) - Code quality standards
- [`agents_quick_reference.md`](agents_quick_reference.md) - Agent command reference
- [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) - Fast vs full validation routing
