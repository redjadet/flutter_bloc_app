# Code Review Graph for Codex

This repo can use [`code-review-graph`](https://pypi.org/project/code-review-graph/)
as a local MCP-backed code graph for Codex. It builds a persistent SQLite graph
of the repo so Codex can resolve related files more selectively instead of
rescanning the whole tree.

This is local developer tooling. It does not affect the Flutter app runtime.

## Context ladder fit

This repo's Codex memory model is:

1. map docs ([`AGENTS.md`](../AGENTS.md),
   [`agent_knowledge_base.md`](agent_knowledge_base.md), [`README.md`](README.md))
2. durable memory (`docs/changes/`, `docs/plans/`, [`tasks/lessons.md`](../tasks/lessons.md),
   current host tracker)
3. structural graph (`code-review-graph`)
4. targeted raw-file reads for edits and proof

Use the graph as the structural layer, not as a replacement for source docs or
code. If the graph cannot answer a question cheaply, fall back to `rg` and
focused file reads.

## When agents should use it

Treat `code-review-graph` as the default low-token repo-exploration path for
Codex when all of these are true:

- the task is non-trivial existing-code work
- likely blast radius is more than one file or symbol
- the exact implementation file is not already obvious

In those cases, use the graph first to narrow likely files, symbols,
callers/callees, or impact before broad `rg`, `sed`, or many-file reads.

Skip graph-first exploration when direct reads are cheaper:

- trivial single-file edits
- exact-path edits where the target file is already known
- brand-new files or isolated docs-only work
- stale/missing local graph where direct reads would be faster

This is best-effort acceleration only. Missing tooling must not block normal
repo work.

Important: the graph does not save tokens just because it exists. The savings
come from starting non-trivial repo exploration with graph queries that narrow
the file/symbol set before opening files broadly.

## What it adds

- A local graph cache under `.code-review-graph/`
- A Codex MCP server entry in `~/.codex/config.toml`
- Repo `.gitignore` coverage for `.code-review-graph/`

The graph cache is intentionally ignored because `graph.db` includes absolute
paths and code-structure metadata.

## Current repo status

On this repo, a successful full build produced:

- `1618` indexed files
- `10535` nodes
- `64888` edges

Rebuild the graph after large refactors, or use incremental update/watch mode
during active development.

## Install

`code-review-graph` requires Python `3.10+`. On this machine the default
`python3` was `3.9`, so the working setup used Homebrew Python `3.13`.

Recommended local install:

```bash
mkdir -p ~/.codex/venvs
/opt/homebrew/bin/python3.13 -m venv ~/.codex/venvs/code-review-graph
~/.codex/venvs/code-review-graph/bin/python -m pip install --upgrade pip
~/.codex/venvs/code-review-graph/bin/python -m pip install code-review-graph
```

Register only the Codex integration:

```bash
~/.codex/venvs/code-review-graph/bin/code-review-graph install \
  --platform codex \
  --repo "$PWD" \
  -y
```

Then build the graph from the repo root:

```bash
~/.codex/venvs/code-review-graph/bin/code-review-graph build --repo "$PWD"
```

Repo-native wrapper:

```bash
./tool/refresh_code_review_graph.sh --build
```

Restart Codex after the install so it picks up the new MCP server.

After install + build, the graph is available automatically through MCP.
That does not mean every task should hit it first; it means agents should
default to graph-first exploration for non-trivial existing-code tasks where
scope is not already obvious.

## Repo-specific caveat

The installer may write this MCP server entry using `command = "code-review-graph"`:

```toml
[mcp_servers.code-review-graph]
command = "code-review-graph"
args = ["serve"]
type = "stdio"
```

If the binary is not on your shell `PATH`, Codex will not be able to start the
server. In that case, pin the absolute venv binary instead:

```toml
[mcp_servers.code-review-graph]
command = "/Users/<you>/.codex/venvs/code-review-graph/bin/code-review-graph"
args = ["serve"]
type = "stdio"
```

Verify the registration with:

```bash
codex mcp get code-review-graph
```

## Daily usage

From the repo root:

```bash
./tool/refresh_code_review_graph.sh
./tool/refresh_code_review_graph.sh --status-only
~/.codex/venvs/code-review-graph/bin/code-review-graph status --repo "$PWD"
~/.codex/venvs/code-review-graph/bin/code-review-graph update --repo "$PWD"
~/.codex/venvs/code-review-graph/bin/code-review-graph watch --repo "$PWD"
```

For agents in this repo, prefer `./tool/refresh_code_review_graph.sh` after
broad multi-file refactors or shared-surface changes. It is best-effort:
missing local tooling should not block the task.

Recommended agent pattern:

1. On non-trivial existing-code tasks, query the graph first to narrow scope.
2. Read only the files and symbols the graph makes likely.
3. Fall back to direct repo scans when the graph is missing, stale, or too
   coarse for the question.
4. After broad multi-file refactors, refresh with
   `./tool/refresh_code_review_graph.sh`.

This matches the reference article in [`code_graph.pdf`](code_graph.pdf): the
point is not "always read the graph first no matter what", but "avoid rereading
the tree when the graph can narrow the relevant slice".

Useful commands:

- `status` shows indexed file/node/edge counts plus branch and commit metadata
- `update` reparses only changed files
- `watch` keeps the graph current while you edit
- `visualize` generates an HTML graph view if you want architecture exploration

## Files and locations

- Repo graph cache: `.code-review-graph/graph.db`
- Repo graph ignore file: `.code-review-graph/.gitignore`
- Repo ignore rule: `.gitignore`
- User Codex MCP config: `~/.codex/config.toml`

## Related docs

- [New Developer Guide](new_developer_guide.md)
- [Tech Stack](tech_stack.md)
- [Documentation index](README.md)
- Reference article captured in this repo: [`code_graph.pdf`](code_graph.pdf)
