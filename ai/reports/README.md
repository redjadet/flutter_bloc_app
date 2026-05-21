# AI discovery reports

Evidence snapshots for agents and audits. **Not** behavior canon—update [`docs/`](../../docs/README.md) when product rules change.

| Report | Purpose |
| --- | --- |
| [architecture_overview.md](architecture_overview.md) | Layers, boot path, links to architecture docs |
| [dependency_map.md](dependency_map.md) | Feature LOC, barrels, fan-in, cross-feature edges |
| [anti_patterns.md](anti_patterns.md) | Repo-specific smells with file pointers |
| [data_flow_map.md](data_flow_map.md) | Offline-first and remote paths |
| [feature_map.md](feature_map.md) | Per-feature context (16 full + 15 stub) |
| [context_hotspots.md](context_hotspots.md) | Largest files; Phase 4 candidates |
| [ai_recommendations.md](ai_recommendations.md) | Prioritized `REC-###` actions |
| [FINAL_OPTIMIZATION_REPORT.md](FINAL_OPTIMIZATION_REPORT.md) | ARCH-001/002 closure + metrics (shipped PR #240) |

## Audits (ranked findings)

Tracked under `docs/audits/` (directory is `.gitignore`d—use `git add -f` when committing):

- [`docs/audits/ai_architecture_audit.md`](../../docs/audits/ai_architecture_audit.md) — `ARCH-###` issues
- [`docs/audits/ai_domain_language_report_v1.md`](../../docs/audits/ai_domain_language_report_v1.md) — naming v1

**Generated:** 2026-05-21 via `tool/modular_metrics.sh` and repository scans.

**Ship/land:** [`docs/changes/2026-05-21_agent_automated_delivery_loop.md`](../../docs/changes/2026-05-21_agent_automated_delivery_loop.md).
