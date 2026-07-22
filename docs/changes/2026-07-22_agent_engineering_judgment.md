# Agent engineering judgment guidance

## Why

Correct syntax and passing happy-path tests do not prevent recurring engineering mistakes. Agents also need a compact decision loop for clarifying the real problem, resisting unnecessary complexity, handling failures, and leaving code understandable to future maintainers.

## Decision

[`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) owns the detailed engineering judgment loop. It requires agents to:

- define requirements, boundaries, done, and edge cases before implementation;
- prefer direct readable code and evidence-backed abstractions;
- design relevant failure, null, timing, cancellation, and partial-completion behavior;
- refactor maintainability problems deliberately within declared scope;
- understand copied or generated solutions and pinned API contracts before reuse;
- communicate context, assumptions, trade-offs, and requirement changes; and
- inspect the result for clarity, necessity, simplicity, resilience, and six-month readability.

Root [`AGENTS.md`](../../AGENTS.md) carries one universal pointer so every repo agent discovers the owner without duplicating its rules across hot-path or host-specific files.

The same pass removes repeated pre-coding and pointer prose from the operating manual, combines overlapping safety rows, and routes quick-reference host/workspace detail to existing specialist owners. Canonical validation and risk tables remain intact.

Measured hot-path reduction: [`agent_operating_manual.md`](../ai/agent_operating_manual.md) plus [`agents_quick_reference.md`](../agents_quick_reference.md) moved from 158 lines / 1,401 words to 144 lines / 1,242 words (159 fewer words, 11.3%) while retaining required mechanical anchors. The quick reference also now points to the live [`engineering/FEATURE_TEMPLATE.md`](../engineering/FEATURE_TEMPLATE.md) owner.

## Scope

Documentation only. No application behavior, validation tooling, generated AI snapshots, or host templates changed.
