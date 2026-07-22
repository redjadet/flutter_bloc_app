---
ai_snapshot:
  generated_at: "2026-07-22T21:07:00Z"
  git_head: "4946d984b89f9328ba2cd3e93fb6eefec21fa061"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---

# AI discovery reports

Evidence snapshots for agents and audits. **Not** behavior canon—update [`docs/`](../../docs/README.md) when product rules change.

| Report | Purpose |
| --- | --- |
| [architecture_overview.md](architecture_overview.md) | Layers, boot path, links to architecture docs |
| [dependency_map.md](dependency_map.md) | Feature LOC, barrels, fan-in, cross-feature edges |
| [anti_patterns.md](anti_patterns.md) | Repo-specific smells with file pointers |
| [data_flow_map.md](data_flow_map.md) | Offline-first and remote paths |
| [feature_map.md](feature_map.md) | Curated per-feature context plus generated inventory |
| [context_hotspots.md](context_hotspots.md) | Generated largest-file ranking for context sizing |
| [ai_recommendations.md](ai_recommendations.md) | Prioritized `REC-###` actions |
| [FINAL_OPTIMIZATION_REPORT.md](FINAL_OPTIMIZATION_REPORT.md) | **Historical** — ARCH-001/002 closure (PR #240); not current discovery guidance |

## Audits (ranked findings)

Curated audit indexes remain tracked under `docs/audits/`; generated snapshots
may be local-only. See [`docs/audits/README.md`](../../docs/audits/README.md) for
retention policy.

- [`docs/audits/architecture_review_2026-06.md`](../../docs/audits/architecture_review_2026-06.md) — Build Readiness program outcomes (2026-06)
- [`docs/audits/maintainability_baseline_review_2026-07-10.md`](../../docs/audits/maintainability_baseline_review_2026-07-10.md) — current maintainability baseline and follow-up status

**Refresh:** `bash tool/refresh_ai_reports.sh` then `bash tool/check_ai_snapshot_freshness.sh`.

**Ship/land:** [`docs/changes/2026-05-21_agent_automated_delivery_loop.md`](../../docs/changes/2026-05-21_agent_automated_delivery_loop.md).

**Generated:** 2026-07-22 via `bash tool/refresh_ai_reports.sh` and `bash tool/modular_metrics.sh` (HEAD `4946d984b89f9328ba2cd3e93fb6eefec21fa061`).
