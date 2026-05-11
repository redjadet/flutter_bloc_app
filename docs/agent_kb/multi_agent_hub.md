# Multi-Agent Hub

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_knowledge_base_details.md`](../agent_knowledge_base_details.md)

See [`agent_knowledge_base_details.md`](../agent_knowledge_base_details.md) for full mechanics. Required labels:

```text
Benefit: team - short reason
Benefit: single - short reason
```

Artifacts live under `tasks/cursor/team/<run-id>/`. Roles: **Coordinator**, **Specialists**: Researcher, Analyst, Implementer, Reviewer. Specialist output is **untrusted** until coordinator validates.
