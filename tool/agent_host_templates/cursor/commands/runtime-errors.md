---
name: runtime-errors
description: Read Flutter runtime errors via Dart MCP (DTD) and propose fixes. Usage /runtime-errors
---

# runtime-errors

Follow [`docs/agent_kb/devtools_runtime_errors.md`](../../../../docs/agent_kb/devtools_runtime_errors.md).

If a Flutter debug app is running for this repo:

- `dtd` → `listDtdUris` → `connect` → `listConnectedApps`
- `get_runtime_errors` (optional `clearRuntimeErrors: true` first)
- Reproduce the bug; `get_runtime_errors` again
- Fix from stack evidence; `lsp` → `hover` at failure site if needed
- `hot_reload` or `hot_restart`; re-check `get_runtime_errors`

If no app running, say so and use static analysis/tests instead.

Shell fallback (no MCP in host): `bash tool/check_runtime_errors.sh` (add `--strict` when runtime proof is required).
