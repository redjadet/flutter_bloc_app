# DevTools / DTD runtime errors (agents)

Back: [Tool orchestration](tool_orchestration.md) · [Agent quick reference](../agents_quick_reference.md)

Agents read **live runtime errors** from the running Flutter debug app through Dart MCP (server commonly named `dart`; some hosts expose it as `user-dart`). Route by the stable DTD tools, not the display label. This is the programmatic equivalent of DevTools **Logging** and error overlays — no browser UI required.

## When to use

- User reports a crash, red/yellow screen, wrong UI, or “it broke at runtime”.
- You changed Dart/Flutter app code and a debug session is already running.
- Before claiming a UI/runtime fix is verified (pair with hot reload; see below).

Do **not** guess stack traces from memory when a controllable debug session exists.

## Prerequisites

- App running in **debug** (`flutter run`, IDE Run/Debug, integration driver with VM service).
- Dart MCP enabled with `dtd`, `get_runtime_errors`, and hot-reload tools ([`agent_environment_setup.md`](../agent_environment_setup.md)).
- Same machine/workspace as the running app (DTD URI `workingDirectory` should match this repo when possible).

## Workflow

Copy and execute in order:

1. **Connect DTD**
   - `dtd` → `listDtdUris`
   - `dtd` → `connect` (pick URI whose working dir matches this repo / IDE session)
   - `dtd` → `listConnectedApps` → note `appUri` when multiple apps

2. **Read errors**
   - `get_runtime_errors` with `clearRuntimeErrors: true` once if old errors may be stale
   - Reproduce the bug in the running app if needed (tap route, action, etc.)
   - `get_runtime_errors` again (pass `appUri` if multiple apps)

3. **Ground the fix in evidence**
   - Open the top stack frame file at the reported line/column.
   - `lsp` → `hover` at that position for types/docs when the cause is unclear.
   - Layout/render issues: `widget_inspector` and skill `flutter-fix-layout-issues` (after errors are read).

4. **Propose and apply**
   - State **observed error text + frame** before suggesting a fix.
   - Smallest reversible change; match surrounding architecture (Cubit/BLoC, DI, routes).

5. **Verify on the live session**
   - `hot_reload` (or `hot_restart` when init/DI/codegen/native blocks reload)
   - Re-run the user flow
   - `get_runtime_errors` — confirm no new relevant errors before “fixed”

## Shell preflight (no MCP in host)

When Node and `dart` are on PATH but the agent is not using MCP directly:

```bash
# Skip (exit 0) if no DTD / no connected debug app
bash tool/check_runtime_errors.sh

# Fail when no controllable session (agents that require runtime proof)
bash tool/check_runtime_errors.sh --strict

# Smoke DTD list/connect only
bash tool/check_runtime_errors.sh --self-test
```

Implementation: `script/mcp_runtime_errors.js` (NDJSON `dart mcp-server`, same tools as MCP).
Not part of `./bin/checklist` — run only when a debug app may be active.

## Fallback (no DTD / no running app)

Report **“no active controllable session”**, then use the narrowest static lane:

- `dart analyze` / `./tool/analyze.sh`
- Focused `flutter test` for the touched area
- Skill `systematic-debugging` for reproduction without live VM

Do not claim runtime verification without DTD evidence.

## Related MCP tools

| Tool | Role |
| --- | --- |
| `dtd` | Discover/connect apps |
| `get_runtime_errors` | Recent VM exceptions/assertions |
| `lsp` | Hover/symbols at failure site |
| `hot_reload` / `hot_restart` | Apply fix to running app |
| `widget_inspector` | Layout/semantics when error is render-related |
| `analyze_files` | Static analysis when no debug session |

## Skills

- `dart-fix-runtime-errors` — follow this doc for **runtime**; use `dart-run-static-analysis` only for compile-time issues.
- `systematic-debugging` — when reproduction or root cause is unclear.
- `flutter-fix-layout-issues` — overflow/unbounded constraints with inspector proof.

Cursor command: `/runtime-errors` (template under `tool/agent_host_templates/cursor/commands/`).
