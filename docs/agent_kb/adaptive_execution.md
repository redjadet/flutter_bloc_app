# Adaptive Execution

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_project_context.md`](../agent_project_context.md), [`agents_quick_reference.md`](../agents_quick_reference.md)

Scale effort to task value; default to one small loop.

1. Classify complexity/risk/scope/uncertainty; local/mechanical stays light.
2. Plan once (<=10 lines), then execute end-to-end.
3. Ask only hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confident, or user-owned decision.
4. Do not edit until 95% confident in goal/scope/approach.
5. Vague/risky => assumptions, success criteria, boundaries, data flow, failure handling, smallest verifiable slice.
6. Broad/codegen work => name modules, ownership, I/O, persistence/sync, logs, dry-run/test seams, rollback.
7. Debug => reproduce/reason, isolate, fix cause, verify.
8. Before report, run finish gate: edge cases, failure paths, readability, operational clarity, breakage impact.
9. Stop when value met, material risks handled, proof matches scope.

## Search budget

- Single loop: plan -> tool -> observe -> revise. No disconnected plans.
- Branch only when risk pays: architecture, security, sync, migrations, CI, performance, or unclear root cause. Compare 2-3 candidate approaches with evidence, then continue one; do not produce multiple full diffs unless asked.
- Verifier/critique rejects => retry with concrete evidence once or twice, then replan/escalate. Do not turn prompting into a job.
- “Almost correct” output => switch tactics fast: stop regenerating whole files; patch minimal diff against real repo seams.
- Empty/truncated/malformed tool output = failed observation; retry narrower, inspect raw output, or mark blocker.
- Keep stable/cacheable instructions before task-specific context in agent-facing docs/templates.
