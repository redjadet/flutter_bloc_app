---
name: package-docs
description: Read package docs via MCP before using dependency APIs. Usage /package-docs
---

# package-docs

Follow [`docs/agent_kb/package_docs_mcp.md`](../../../../docs/agent_kb/package_docs_mcp.md).

Before writing or changing code against a pub dependency:

1. Pin version from `pubspec.yaml` / lockfile; grep `lib/` for existing usage.
2. Dart MCP (`dart`; host may display `user-dart`) → `read_package_uris` / `rip_grep_packages` for resolved source.
3. Read current official docs: Context7 when installed, otherwise available ref/browser/web tools.
4. Use specific questions and targeted pages; do not load whole package sites.
5. Implement; `analyze_files` or `./tool/analyze.sh` on touched paths.

Do not guess APIs from training data when MCP is available.
