# Critical Human Engineering Skills

Human judgment remains accountable for problem choice, product intent, risk
acceptance, and production outcomes. AI agents can accelerate exploration,
implementation, and verification; they do not replace these responsibilities.

Use this guide to make critical engineering skills observable in briefs, design
records, reviews, tests, and operational evidence. It synthesizes the practices;
linked owner documents remain authoritative for detailed repository rules.

## Shared evidence standard

A skill is demonstrated by a decision and its evidence, not by naming a tool or
technology. Strong work records:

1. Context and desired user or business outcome.
2. Constraints, assumptions, non-goals, and uncertainty.
3. Options considered, chosen path, and rejected path.
4. Risks, failure behavior, and recovery or rollback.
5. Scope-matched proof and remaining limitations.
6. Owner and trigger for revisiting the decision.

Separate observed facts from inference. Never invent metrics, validation output,
production behavior, or individual ownership.

## 1. Problem decomposition

- Frame work as an outcome, not a file list or technology migration.
- Split by user-visible vertical slices, contracts, risks, and dependencies.
  Prefer a small end-to-end slice that can fail and be verified independently.
- Identify the critical path, parallel-safe work, integration seams, and explicit
  deferrals. Avoid layers of tasks that produce no usable behavior until the end.
- Evidence: scoped brief with acceptance criteria, dependency order, test owner,
  stop conditions, and rollback. Use [Feature Template](FEATURE_TEMPLATE.md) and
  [Task Tracker Template](task_tracker_template.md).

## 2. Clear technical communication

- Lead with outcome or decision, then explain evidence and consequences.
- State audience, context, assumptions, and requested action. Define unfamiliar
  terms; prefer precise examples over abstract claims.
- Separate fact, inference, proposal, and unresolved question. Report failed or
  skipped checks as clearly as passing checks.
- Make disagreements actionable: name the affected contract, concrete impact,
  smallest correction, and proof needed. Review format:
  [Code Review Playbook](../review/code_review_playbook.md#write-actionable-findings).

## 3. System design and architecture

- Start from constraints: scale, latency, consistency, privacy, offline behavior,
  supported platforms, team ownership, delivery horizon, and failure tolerance.
- Define boundaries, data and control flow, source of truth, lifecycle, trust
  boundaries, and operational signals before selecting components.
- Check normal, degraded, recovery, migration, and rollback paths. Architecture
  that only explains the happy path is incomplete.
- Record cross-cutting decisions and rejected alternatives in an
  [ADR](../adr/README.md). Repository boundaries remain owned by
  [Clean Architecture](../clean_architecture.md) and the
  [Feature Structure Contract](../architecture/feature_structure_contract.md).

## 4. Code review

- Establish intended outcome, scope, risk, and required proof before judging the
  diff. Read relevant contracts, callers, tests, and failure paths.
- Review in risk order: correctness, data/security, architecture, async state,
  operations, tests, then maintainability and style.
- Findings must include location, impact, evidence, requested correction, and
  verification. Distinguish blockers from optional improvements.
- Re-run the narrowest honest checks independently. Human reviewers own approval,
  exceptions, and risk acceptance. Full workflow:
  [Code Review Playbook](../review/code_review_playbook.md).

## 5. Debugging and root-cause analysis

- Write the observed symptom, expected behavior, environment, first bad boundary,
  and reproducible trigger before proposing a fix.
- Form competing hypotheses; choose the next observation that best separates
  them. Change one variable at a time and preserve raw evidence.
- Trace cause across time and ownership boundaries. Restarting, retrying, or
  suppressing an error may remove the symptom without removing the cause.
- Prove the cause by reproducing before the fix, failing a focused regression
  guard, fixing the smallest causal boundary, and passing the guard afterward.
  Runtime route: [DevTools runtime errors](../agent_kb/devtools_runtime_errors.md);
  post-ship route: [Crashlytics triage](../observability/crashlytics_triage_runbook.md).

## 6. Security judgment

- Identify assets, actors, trust boundaries, entry points, abuse cases, and blast
  radius. Treat the Flutter client and all embedded configuration as untrusted.
- Put authorization and sensitive decisions at the server boundary. Apply least
  privilege, secure defaults, bounded retention, log redaction, and denial tests.
- Distinguish risk reduction from risk elimination. Document residual risk,
  compensating controls, detection signals, incident recovery, and human owner.
- High-risk exceptions need explicit human acceptance. Use
  [Security and Secrets](../security_and_secrets.md) and the
  [Security Review Checklist](../review/security_checklist.md).

## 7. Requirements clarification

- Ask who has the problem, what changes for them, why now, and how success will
  be observed. Capture current behavior before prescribing new behavior.
- Convert intent into examples and acceptance criteria covering success, empty,
  invalid, denied, slow, repeated, concurrent, offline, and recovery cases when
  relevant.
- Record scope, non-goals, constraints, assumptions, terminology, and unresolved
  decisions. Stop when two materially different interpretations remain.
- Human stakeholders own product preference and policy decisions. Engineers own
  exposing ambiguity and consequences before implementation. Start from the
  [Feature Template](FEATURE_TEMPLATE.md).

## 8. Trade-off evaluation

- Compare at least the current approach, the smallest change, and a credible
  alternative. Include “do nothing” when delay is viable.
- Evaluate user value, correctness, security, complexity, cost, delivery time,
  reversibility, operational burden, and future constraints. Weight criteria;
  a technology feature list is not analysis.
- Record chosen option, rejected option, accepted cost, proof, decision owner,
  revisit trigger, and exit path. Avoid “it depends” without a decision boundary.
- Use an [ADR](../adr/README.md) for lasting cross-cutting decisions and
  [engineering decision stories](../case_studies/README.md) for evidence-backed
  reflection.

## 9. Testing and validation

- Derive proof from risk and contract, not implementation shape. Test the
  smallest stable boundary that can disprove the intended behavior.
- Cover important success, failure, boundary, race, lifecycle, and recovery
  paths. A happy-path test or high coverage percentage alone is insufficient.
- Keep testing and validation distinct: tests exercise behavior; analysis,
  builds, linters, scripts, runtime checks, and manual evidence validate other
  risks. Never substitute an unrelated green command.
- Record exact commands, results, environment limits, skipped lanes, and residual
  risk. Route through the [Testing Matrix](../testing/matrix_required_by_change.md)
  and [Validation Routing](validation_routing_fast_vs_full.md).

## 10. Product and business-context understanding

- Connect work to a user segment, problem, desired behavior change, and business
  constraint. Ask what value increases and what cost or risk decreases.
- Define a hypothesis, success signal, guardrails, and ship/iterate/stop decision
  before optimizing implementation. Separate available telemetry from metrics
  that would require future instrumentation.
- Consider adoption, accessibility, support load, privacy, platform policy,
  operational cost, and opportunity cost alongside technical quality.
- Evidence should link product intent to implemented behavior and proof. See the
  [Counter outcome brief](../features/counter_outcome_brief.md) and
  [Case studies](../case_studies/README.md).

## 11. Accountability for production outcomes

- Ownership continues after merge: rollout, observability, support, incident
  response, rollback, and learning belong in the delivery design.
- Before release, name blast radius, leading failure signal, alert/triage owner,
  safe rollback or containment path, data repair needs, and user communication
  responsibility.
- During incidents, protect users first, preserve evidence, communicate known and
  unknown state, then repair root cause. Follow with regression proof and a
  durable guardrail where the failure class can recur.
- A passing pipeline proves only its tested contracts. Use
  [Observability](../observability.md), [Crashlytics triage](../observability/crashlytics_triage_runbook.md),
  and the [Finish Gate](../agent_kb/legibility_and_finish_gate.md).

## 12. Agent orchestration and supervision

- Human coordinator owns goal, scope, product decisions, risk class, task graph,
  and final verdict. Agent output remains untrusted until inspected and verified.
- Delegate only bounded work with inputs, output contract, write boundary, and
  proof. Use independent review for high-risk work; do not let one agent both
  invent and waive its acceptance criteria.
- Parallelize independent discovery or validation. Serialize conflicting edits,
  shared design decisions, migrations, and final integration.
- Inspect artifacts and raw evidence, reconcile contradictions, stop duplicate or
  low-value work, and keep one accountable owner for final integration. Rules:
  [AI Agent Governance](../ai/governance.md) and
  [Tool Orchestration](../agent_kb/tool_orchestration.md). Task-fit guidance:
  [Best Areas for AI Agents](../ai/best_areas_for_ai_agents.md).

## Practical self-review

Before calling work complete, answer:

- Can another engineer state the problem, chosen design, key trade-off, and
  failure model without the original conversation?
- Does proof map to acceptance criteria and highest risks?
- Are product, security, and production decisions owned by named humans or roles?
- Are uncertainty, limitations, rollback, and revisit triggers explicit?
- Did agent assistance improve evidence quality without weakening human accountability?
