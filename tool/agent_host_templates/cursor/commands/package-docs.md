---
name: package-docs
description: Read package docs via MCP before using dependency APIs. Usage /package-docs
---

# package-docs

Follow [`docs/agent_kb/package_docs_mcp.md`](../../../../docs/agent_kb/package_docs_mcp.md).

Before writing or changing code against a pub dependency:

1. Pin version from `pubspec.yaml` / lockfile; grep `lib/` for existing usage.
2. `user-dart` → `read_package_uris` / `rip_grep_packages` for resolved source.
3. Context7 → `resolve-library-id` → `query-docs` (specific question).
4. Optional: `ref_search_documentation` → `ref_read_url`.
5. Implement; `analyze_files` or `./tool/analyze.sh` on touched paths.

Do not guess APIs from training data when MCP is available.
