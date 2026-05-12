# Tool Orchestration

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_environment_setup.md`](../agent_environment_setup.md)

Use capabilities as an execution system, not decoration.

- Prefer direct repo scripts/tests/fixtures, code-review-graph, browser/app proof, and available MCP/connectors over model memory when they can observe the real system.
- Use external MCP/connectors only for state they own (GitHub/CI, browser runtime, databases, docs); keep secrets out of prompts and artifacts.
- Tool docs/templates should name what tool does, when to use it, required inputs, side effects, retry safety, and common failure modes.
- Semantic search/code graph finds likely files; targeted raw reads still confirm before edits.
- Faster/mechanical tools or models may do repetitive edits only after the owner has fixed scope, write set, and validation; final judgment stays with the coordinating agent.
- More agents/tools are not automatically better. Add them when they reduce uncertainty, isolate context, or verify a risky decision.
- Setup details live in [`agent_environment_setup.md`](../agent_environment_setup.md).
