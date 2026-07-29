# Code Review Graph for Codex

This repo can use [`code-review-graph`](https://pypi.org/project/code-review-graph/)
as a local MCP-backed code graph for Codex. It builds a persistent SQLite graph
of the repo so Codex can resolve related files more selectively instead of
rescanning the whole tree.

This is local developer tooling. It does not affect the Flutter app runtime.

## Context ladder fit

Canonical discovery: [`ai/context_loading.md`](context_loading.md) and
[`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md).
`code-review-graph` is an **optional structural** layer before **targeted
raw-file reads**. Maps + `rg` remain the default hot path (2026-07-29 pilot
**FAIL**ed graph-first winner gate — see
[`../../ai/reports/2026-07-29_code_review_graph_pilot.md`](../../ai/reports/2026-07-29_code_review_graph_pilot.md)).

Source and tests remain authority. Treat graph hits as leads only.

## When agents should use it

Use only when all are true:

- non-trivial existing-code work with unknown multi-file blast radius
- local graph installed, **built**, and fresh (`./tool/refresh_code_review_graph.sh --status-only` ≠ `not built`)
- named question with a narrow query (callers/callees/importers/tests) and an output cap

Skip graph when cheaper:

- exact-path / one-file edits
- brand-new files or docs-only work
- missing/stale graph (fall back to `CODEMAP` + `rg`)

Missing tooling must never block normal repo work or CI.

## What it adds

- Local cache under `.code-review-graph/` (gitignored; absolute paths inside DB)
- Optional Codex MCP entry in `~/.codex/config.toml`

## Current repo status

Do **not** trust historical index counts in older docs. Live stats come from a
local build:

```bash
./tool/refresh_code_review_graph.sh --status-only
# or, after install:
~/.codex/venvs/code-review-graph/bin/code-review-graph status --repo "$PWD"
```

Pilot rebuild (worktree, 2026-07-29): ~2556 files / ~15645 nodes / ~95327 edges
in ~11s — correctness still below default-promotion bar.

## Install

Needs Python `3.10+` (Homebrew `python3.13` on this machine):

```bash
mkdir -p ~/.codex/venvs
/opt/homebrew/bin/python3.13 -m venv ~/.codex/venvs/code-review-graph
~/.codex/venvs/code-review-graph/bin/python -m pip install --upgrade pip
~/.codex/venvs/code-review-graph/bin/python -m pip install code-review-graph
~/.codex/venvs/code-review-graph/bin/code-review-graph install \
  --platform codex --repo "$PWD" -y
./tool/refresh_code_review_graph.sh --build
```

Pin absolute venv `command` in `~/.codex/config.toml` if `code-review-graph` is
not on `PATH`. Verify: `codex mcp get code-review-graph`.

## Daily usage / freshness

```bash
./tool/refresh_code_review_graph.sh --status-only
./tool/refresh_code_review_graph.sh --if-needed
./tool/refresh_code_review_graph.sh --build
bash tool/check_code_review_graph_contract.sh
```

Wrapper rules (best-effort, local-only):

- `--status-only` prints `not built` when no real index exists; does **not**
  create a cache
- `--if-needed` refreshes when HEAD changed, graph missing, **or worktree dirty**
  (never skip solely because `HEAD` matches)
- rename/delete transitions force a full rebuild
- refresh metadata: `.code-review-graph/refresh_meta` (revision, dirty, mode,
  timestamp, reason)
- missing binary → exit 0 with skip message

**Rebuild-before-trust** for shared refactors, renames/moves, and merge review.

## Agent pattern (narrow)

1. Freshness check → narrow named query with output cap.
2. Read returned source/tests; verify critical edges in raw files.
3. Fall back to maps/`rg` on miss, ambiguity, or coarse impact dumps.
4. PR review: propose affected symbols/likely tests only; never dump whole-repo
   graphs into context.

## Host-neutral agent path

| Host | Default exploration | Refresh |
| --- | --- | --- |
| Cursor | `rg` + [`CODEMAP.md`](../../CODEMAP.md) / [`llms.txt`](../../llms.txt); graph optional lead | After large moves; `--if-needed` when using graph |
| Codex | Maps/`rg` default; optional narrow graph when built+fresh | `./tool/refresh_code_review_graph.sh --if-needed` |
| Any | Direct reads when path known | Full `--build` after renames/deletes/shared refactors |

## Files and locations

- Cache: `.code-review-graph/graph.db`, `refresh_meta`, `last_head`
- Wrapper: [`../../tool/refresh_code_review_graph.sh`](../../tool/refresh_code_review_graph.sh)
- Contract: [`../../tool/check_code_review_graph_contract.sh`](../../tool/check_code_review_graph_contract.sh)
- Codex MCP: `~/.codex/config.toml`

## Related docs

- [New Developer Guide](../new_developer_guide.md), [Tech Stack](../tech_stack.md)
- Pilot evidence: [`../../ai/reports/2026-07-29_code_review_graph_pilot.md`](../../ai/reports/2026-07-29_code_review_graph_pilot.md)
- Reference: [`code_graph.pdf`](../code_graph.pdf)
