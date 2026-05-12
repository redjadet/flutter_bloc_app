# Adaptive Execution

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_project_context.md`](../agent_project_context.md), [`agents_quick_reference.md`](../agents_quick_reference.md)

Scale effort to task value; default to one small loop.

1. Classify complexity/risk/scope/uncertainty; local/mechanical stays light.
2. Define `Goal / Context / Boundaries / Verification`; add side effects or stop/report shape only when useful.
3. Plan once (<=10 lines), then execute end-to-end.
4. Ask only hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confident, or user-owned decision.
5. Do not edit until 95% confident in goal/scope/approach.
6. Vague/risky => assumptions, data flow, failure handling, smallest verifiable slice.
7. Broad/codegen => modules, ownership, I/O, persistence/sync, logs, dry-run/test seams, rollback.
8. Debug => reproduce/reason, isolate, fix cause, verify.
9. Before report: edge cases, failure paths, readability, operational clarity, breakage impact.
10. Stop when value met, material risks handled, proof matches scope.

## Search budget

- Single loop: plan -> tool -> observe -> revise. No disconnected plans.
- Branch only when risk pays: architecture, security, sync, migrations, CI, performance, or unclear root cause. Compare 2-3 candidate approaches with evidence, then continue one; do not produce multiple full diffs unless asked.
- Verifier/critique rejects => retry with concrete evidence once or twice, then replan/escalate. Do not turn prompting into a job.
- “Almost correct” output => switch tactics fast: stop regenerating whole files; patch minimal diff against real repo seams.
- Empty/truncated/malformed tool output = failed observation; retry narrower, inspect raw output, or mark blocker.
- Keep stable/cacheable instructions before task-specific context.
- Re-evaluate effort before escalating; low/medium often beats high when scope + stop rules are clear.
- Trust senior-agent judgment inside boundaries; constrain outcomes/safety, not folder counts/order unless repo canon requires them.
