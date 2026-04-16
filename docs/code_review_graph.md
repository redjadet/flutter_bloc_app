# Code Review Graph for Codex

This repo can use [`code-review-graph`](https://pypi.org/project/code-review-graph/)
as a local MCP-backed code graph for Codex. It builds a persistent SQLite graph
of the repo so Codex can resolve related files more selectively instead of
rescanning the whole tree.

This is local developer tooling. It does not affect the Flutter app runtime.

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
