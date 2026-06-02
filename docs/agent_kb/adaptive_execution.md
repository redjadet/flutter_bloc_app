# Adaptive Execution

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_project_context.md`](../agent_project_context.md), [`agents_quick_reference.md`](../agents_quick_reference.md)

Scale effort to task value; default to one small loop.

1. Classify complexity/risk/scope/uncertainty; local/mechanical stays light.
2. Define `Goal / Context / Boundaries / Verification`; add side effects or stop/report shape only when useful.
   Keep intent, spec, and implementation separate: intent says why/constraints/success; spec says measurable contract/eval; implementation follows repo architecture.
3. Plan once (<=10 lines), then execute end-to-end.
4. Ask only hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confident, or user-owned decision.
5. Do not edit until 95% confident in goal/scope/approach.
6. Vague/risky => state uncertainty before code; call out assumptions, data flow, failure handling, smallest verifiable slice.
   Ask: what assumptions about this codebase may be false?
7. Broad/codegen => modules, ownership, I/O, persistence/sync, logs, dry-run/test seams, rollback.
8. Debug => reproduce/reason, isolate, fix cause, verify.
9. Before report: edge cases, failure paths, readability, operational clarity, breakage impact.
10. Stop when value met, material risks handled, proof matches scope.

## Scope And Safety

- Use the approved repo stack and tools from [`../agent_project_context.md`](../agent_project_context.md), [`../tech_stack.md`](../tech_stack.md), and [`../agents_quick_reference.md`](../agents_quick_reference.md). If a requested tool conflicts, flag conflict and continue with repo-approved stack unless user explicitly overrides.
- Modify only task-owned files/functions. Do not rename, refactor, or redesign unrelated code; report unrelated issues separately.
- Use the simplest solution that solves the verified problem. Avoid speculative abstractions, package swaps, and extra boilerplate.
- Before destructive or external-side-effect actions, stop, list affected items, and request explicit confirmation in the current conversation. This includes deleting files, overwriting generated/user code, dropping data, running migrations, deploys, and remote writes.

## Search budget

- Single loop: plan -> tool -> observe -> revise. No disconnected plans.
- Branch only when risk pays: architecture, security, sync, migrations, CI, performance, or unclear root cause. Compare 2-3 candidate approaches with evidence, then continue one; do not produce multiple full diffs unless asked.
- Verifier/critique rejects => retry with concrete evidence once or twice, then replan/escalate. Do not turn prompting into a job.
- “Almost correct” output => switch tactics fast: stop regenerating whole files; patch minimal diff against real repo seams.
- Empty/truncated/malformed tool output = failed observation; retry narrower, inspect raw output, or mark blocker.
- Keep stable/cacheable instructions before task-specific context.
- Re-evaluate effort before escalating; low/medium often beats high when scope + stop rules are clear.
- Trust senior-agent judgment inside boundaries; constrain outcomes/safety, not folder counts/order unless repo canon requires them.
- Do not lock architecture in the prompt/spec unless repo canon or user constraint requires it; derive tactics from current code, history, and validation.
