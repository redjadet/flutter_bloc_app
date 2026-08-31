# Session Closeout Teach-Back

## Why

Build summaries show output but do not prove transferable understanding. Code
can work until a later failure leaves maintainers debugging a system they never
understood. A baseline → test → teach-back → gate loop makes understanding part
of completion, not an optional reflection after delivery.

## Decision

- Every non-trivial session runs the baseline → test → teach-back → gate loop.
- Main question: “After this session, do I know more than I did before it
  started, or am I just further along?” Successful closeout answers “Yes — I
  know more than I did before it started” with 1–3 concepts a teammate,
  interviewer, or future maintainer could explain.
- If the answer cannot be yes, investigation continues or the closeout reports
  the exact understanding gap; working code alone does not satisfy done.
- Purely mechanical work says no reusable concept was learned instead of
  inventing one.

## Related validation repair

- Closeout CLI fixtures use explicit scorecard and empty-scope inputs, so their
  freshness expectations no longer depend on unrelated working-tree changes.
- Host `agent-execution` template lists `What We Learned` in `SAFETY-REPORT`;
  `check_agent_safety_contracts.sh` requires that token in the owner doc,
  finish-gate shape, operating-manual understanding loop, and host template.

## Ownership

The [operating manual](../ai/agent_operating_manual.md#understanding-loop) owns
the loop. [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md)
owns response shape. Other agent docs contain pointers only.
