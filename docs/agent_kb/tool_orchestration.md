# Tool Orchestration

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_environment_setup.md`](../agent_environment_setup.md)

Use capabilities as an execution system, not decoration.

- Prefer direct repo scripts/tests/fixtures, code-review-graph, browser/app proof, and available MCP/connectors over model memory when they can observe the real system.
- Use external MCP/connectors only for state they own (GitHub/CI, browser runtime, databases, docs); keep secrets out of prompts and artifacts.
- Tool docs/templates should name what tool does, when to use it, required inputs, side effects, retry safety, and common failure modes.
- Semantic search/code graph finds likely files; targeted raw reads still confirm before edits.
- Faster/mechanical tools or models may do repetitive edits only after the owner has fixed scope, write set, and validation; final judgment stays with the coordinating agent.
- Protocol: `dart mcp-server` uses **newline-delimited JSON-RPC** (NDJSON), not `Content-Length` framing.
- After Flutter app-code, UI, route, asset, or localization edits, trigger hot reload for any already-running controllable debug session before manual inspection; use hot restart when reload cannot apply (init, DI, codegen, native, `dart-define`), and report when no session was available instead of silently starting one.
- For runtime bugs or before claiming a UI fix on an active debug session, connect DTD and call `get_runtime_errors` (then `lsp` at the failing site); verify with hot reload + a second `get_runtime_errors`. Full loop: [`devtools_runtime_errors.md`](devtools_runtime_errors.md).
- Before using unfamiliar or version-sensitive **package APIs**, read pinned dependency source and current docs via MCP — do not guess from model memory. Full loop: [`package_docs_mcp.md`](package_docs_mcp.md).
- More agents/tools are not automatically better. Add them when they reduce uncertainty, isolate context, or verify a risky decision.
- Setup details live in [`agent_environment_setup.md`](../agent_environment_setup.md).
- Host upkeep automation (when agents run `preflight` / `closeout` / `after-host-edit`): [`host_maintenance_automation.md`](host_maintenance_automation.md).
