# GitHub MCP operating guide

Read-only-first workflow for PR, CI, issue, and release inspection. Mutations
require explicit user approval in the same turn.

## Read operations (no approval)

| Operation | Tool pattern | Notes |
| --- | --- | --- |
| PR status / checks | `gh pr view`, `gh pr checks`, GitHub MCP read | Prefer MCP when configured; `gh` CLI fallback |
| Issue triage | `gh issue view`, list/search | Summarize evidence back to user |
| Diff / files | `gh pr diff`, MCP file list | Use for review scope, not canon |

## Write operations (approval required)

| Operation | Examples | Rule |
| --- | --- | --- |
| Comment / review / merge | `gh pr review`, merge, close issue | **Explicit user approval same turn** |
| Push / branch / release | remote-changing commands | Same |

## Setup

- Configure GitHub MCP in the host when available.
- Fallback: [`gh`](https://cli.github.com/) authenticated locally.
- Orchestration policy: [`agent_kb/tool_orchestration.md`](../agent_kb/tool_orchestration.md).

## Context ladder

For PR/CI evidence during implementation, load after [`context_loading.md`](context_loading.md) Tier 1:

1. `gh pr view` / checks output
2. Owning feature brief under `docs/changes/`
3. Narrow validation from [`agents_quick_reference.md`](../agents_quick_reference.md)

## Non-recommendations

| MCP | Decision | Why |
| --- | --- | --- |
| Filesystem MCP | Do not add | Workspace-scoped file access already available |
| SQLite MCP | Do not add | Local code-review graph covers narrow graph use case |
| Memory MCP | Do not add | Repo docs/ADRs/tests are reviewable, versioned memory |

See [`validation_scripts/ai_snapshot_freshness.md`](../validation_scripts/ai_snapshot_freshness.md) for program context.
