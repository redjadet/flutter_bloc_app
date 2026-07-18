# Repo map

Thin pointer for agents starting under `docs/ai/`. Prefer [`CODEMAP.md`](../../CODEMAP.md).

| Area | Path |
| --- | --- |
| Compact LLM context | [`llms.txt`](../../llms.txt) — single retrieval path with [`CODEMAP.md`](../../CODEMAP.md) |
| App entry | `apps/mobile/lib/main_*.dart`, `apps/mobile/lib/app/` |
| Features | `apps/mobile/lib/features/<name>/` |
| Shared ownership | `packages/*` (see [`SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md)) |
| App composition / DI | `apps/mobile/lib/app/` |
| Tests | `apps/mobile/test/` |
| Tooling | `tool/`, `bin/checklist` |
| Canon docs | `docs/` |
| Evidence | `ai/reports/` |
| Plans | `docs/plans/` |
