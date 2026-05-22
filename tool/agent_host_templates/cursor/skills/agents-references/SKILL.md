---
name: agents-references
description: External references and key file paths for this repo. Use when locating theme, DI, lifecycle, sync, HTTP, or Supabase code.
---

# References

Thin pointer skill. **Do not duplicate** long path lists here.

## Open (order)

1. [`docs/agent_project_context.md`](../../../../../docs/agent_project_context.md) — topic table
2. [`CODEMAP.md`](../../../../../CODEMAP.md) — feature/layout map
3. [`docs/README.md`](../../../../../docs/README.md) — doc index
4. `agents-repo-context` — stack snapshot
5. `agents-canonical-rules` (+ scoped children) — coding rules

## Find code

- Prefer `rg` / structural graph (`./tool/refresh_code_review_graph.sh --status-only`) over loading this skill.
- Theme/DI/sync/HTTP: see project context + `lib/core/`, `lib/shared/`.

## External links (stable)

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter AI rules](https://raw.githubusercontent.com/flutter/flutter/refs/heads/master/docs/rules/rules.md)
