# Meterless context-layer guidance

Date: 2026-07-23

## Research evidence

Reviewed [`Meterless/Meterless`](https://github.com/Meterless/Meterless) at
`main`:

- Root [`AGENTS.md`](https://github.com/Meterless/Meterless/blob/main/AGENTS.md)
  routes each task to one self-contained folder and forbids unrelated engine
  loading.
- [H-MEM](https://github.com/Meterless/Meterless/blob/main/engines/hmem/AGENTS.md)
  keeps source, confidence, provenance, and supersession data; retrieval emits
  relevance trace metadata.
- [Markovian](https://github.com/Meterless/Meterless/blob/main/engines/markovian/AGENTS.md)
  bounds continuation state with structured completed/remaining/decisions/context
  carryover and injects heavy context only at the first step.
- [Scout Intent](https://github.com/Meterless/Meterless/blob/main/engines/scout-intent/AGENTS.md)
  separates intent interpretation, risk guards, tool routing, execution
  contracts, and eval gates.
- The
  [memory-compounding demo](https://github.com/Meterless/Meterless/blob/main/examples/memory-compounding-research/README.md)
  demonstrates cold versus retrieved-context execution with deterministic
  output and labeled estimates.

## Repo comparison

This project already owns intent/tool routing, `Goal / Context / Boundaries /
Verification`, safety contracts, compiled repo memory, progressive disclosure,
and executable validation gates. Copying Meterless engines, scoring formulas, or
nested [`AGENTS.md`](../../AGENTS.md) files would duplicate stronger current owners.

Confirmed gaps:

1. Context loading did not state a strict task-boundary isolation rule.
2. Compiled-memory guidance did not define provenance, authority, freshness,
   relevance, supersession, and uncertainty as one retrieval contract.
3. Long-session recovery lacked one bounded, structured carryover shape.

## Decision

- Keep root [`AGENTS.md`](../../AGENTS.md) map-only.
- Add task isolation to the canonical context ladder.
- Add context packet and bounded continuation contracts to
  [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md).
- Extend the existing memory-compounding guard with exact anchors.
- Do not add runtime dependencies, a separate RAG service, host templates,
  memory scoring formulas, signed execution contracts, or another agent canon.

## Verification

Owning checks:

```bash
bash tool/check_agent_memory_compounding.sh
bash tool/check_agent_knowledge_base.sh
bash tool/check_docs_gardening.sh --paths docs/ai/context_loading.md docs/agent_kb/memory_and_context_ladder.md docs/agent_knowledge_base.md docs/changes/2026-07-23_meterless_context_layer_guidance.md
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```

Results:

- Memory-compounding, knowledge-base, docs-gardening, safety, risk-register,
  harness-scorecard, engineering-scorecard, and closeout gates passed.
- Agent scorecard summary rebuilt; freshness passed with 70 inputs.
- Fresh checklist reached harness fixtures, then stopped on pre-existing AI
  snapshot metadata: snapshot `git_head` `4946d984` versus current
  `99ec803a`. This change did not meet the snapshot refresh triggers in
  `ai/README.md`, so generated discovery snapshots were not rewritten.
