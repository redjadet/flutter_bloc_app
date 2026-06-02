# Legibility and Finish Gate

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`ai_code_review_protocol.md`](../ai_code_review_protocol.md), [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)

## Agent Legibility

Agents reason over inspectable state.

- Prefer app-visible proof: screenshots, widget tests, integration flows, route validators, emulator/browser evidence.
- Runtime evidence needs agent-runnable trigger + stable log/metric/trace/fixture signal; human-only dashboards are not proof.
- Turn unclear goals into inspectable artifacts: acceptance criteria, data-flow sketch, fixture, dry-run, focused proof route.
- Non-trivial risk => define acceptance contract before broad execution; executable specs/tests beat model confidence.
- Non-trivial `lib/features/` work => fill [`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) **Tests** section before broad implementation.
- Spec items must map to deterministic proof: test, fixture, script, lint, screenshot, log/metric, or explicit manual blocker. If not evaluable, treat it as intent/context, not spec.
- For long/tool-heavy work, make stop rules explicit: retry/fallback/ask/abstain/report conditions.
- Keep state inspectable: tracker, task graph/checklist, commands, failures, retries, blocker.
- UI/design chain: [`../DESIGN.md`](../../DESIGN.md) -> [`design_system.md`](../design_system.md) -> `AppTheme` / `buildAppMixScope` / `AppStyles` / `UI`.
- UI proof should cover the real workflow first, complete expected states, and
  mobile/desktop layout stability with no clipped text or incoherent overlap.
- Prefer repo-local schemas/examples/generated clients/test harnesses over chat-only claims.
- For UI/runtime work, expose narrow runnable surface first: route tile, demo control, smoke test, or fixture.

## Finish Gate

Last 20% builds trust. Before report/commit, ask when suitable:

- Edge cases: empty, malformed, duplicate, concurrent, offline/resume, permission-denied, slow/large input.
- Failure paths: how errors surface, retry/rollback/idempotency, cleanup, user-visible state, logs/metrics.
- Readability: names, seams, comments, tests, and docs make the next change obvious.
- Operational clarity: run/verify/debug steps are discoverable from repo artifacts.
- Breakage impact: what fails first, blast radius, detection signal, and safe recovery path.
- Drift: intent/spec/docs still match implementation after the patch.

## Report Shape

For coding tasks, start with outcome/proof and include:

- Files Changed: each changed file plus one-line modification summary.
- Follow-up Actions: required next steps, manual actions, or `None`.

Keep unrelated observations separate from the change summary.
