# Best Areas for AI Agents

AI agents create most value on bounded work with accessible repository context,
repeatable transformations, and objective verification. Humans remain
accountable for product intent, architecture direction, risk acceptance,
production authorization, and final approval.

This guide defines where agents fit well in this repository. It links existing
owner documents instead of replacing their detailed procedures.

## Good-fit contract

Before delegating, provide:

- **Goal** — observable outcome, not only an activity.
- **Context** — relevant owner docs, current implementation, constraints, and
  known history.
- **Boundaries** — exact paths, non-goals, forbidden actions, and human-owned
  decisions.
- **Verification** — tests, analysis, scripts, diff review, runtime evidence, or
  explicit manual acceptance.

Agent work fits best when the task is reversible, its blast radius can be
traced, and a reviewer can independently reject incorrect output. Keep work
human-led when requirements remain ambiguous, trade-offs require business or
security acceptance, production access is needed, or success cannot be observed.

## 1. Repetitive implementation and boilerplate

**Best fit:** Repeating an already-approved local pattern across similar models, adapters,
  registrations, serialization types, or small widgets; or using repository templates
  or code generation for deterministic structure.

- **Controls:** Human selects the reference pattern and confirms repetition is real, not
  accidental similarity.
- Agent inventories variations before editing; preserve intentional exceptions.
- Generated files remain generator-owned. Change inputs and rerun the generator
  instead of hand-editing output.

Output: small diff, list of copied conventions and exceptions, focused tests,
and generator/analyzer proof. Owners: [Code Generation](../engineering/code_generation_guide.md)
and [DRY Principles](../architecture/dry_principles.md).

## 2. Multi-file feature scaffolding

**Best fit:** Creating predictable domain, data, presentation, DI, route, localization, and
  test seams after product behavior and contracts are agreed.

- **Controls:** Start with a feature brief and executable test rows.
- Preview repository scaffold commands before applying them.
- Compare against a current reference feature; do not copy legacy folder shapes.
- Treat scaffold output as a starting structure, not completed behavior.

Output: complete file manifest, wired integration seams, tests named by contract,
and validation route. Owners: [Feature Delivery Guide](../feature_implementation_guide.md),
[Feature Structure Contract](../architecture/feature_structure_contract.md), and
[Feature Template](../engineering/FEATURE_TEMPLATE.md).

## 3. Codebase exploration and dependency tracing

**Best fit:** Locating owners, callers, implementations, tests, dependency direction, and
  likely blast radius before a change.

- **Controls:** Start with [`CODEMAP.md`](../../CODEMAP.md), repository maps, `rg`, and targeted raw-file reads.
- Use graph or semantic results as leads; verify important edges in source.
- Set a named question and output cap. Avoid whole-repository context dumps.
- Label observed links, inferred impact, stale evidence, and unresolved gaps.

Output: bounded path/symbol map, dependency chain, affected tests, and confidence
limits. Owners: [Context Loading](context_loading.md),
[Code Review Graph](code_review_graph.md), and [Project Context](../agent_project_context.md).

## 4. Routine debugging and log analysis

**Best fit:** Reproducible failures with accessible logs, stack traces, failing tests, or a
  controllable local runtime.

- **Controls:** Record expected versus observed behavior and environment before proposing fixes.
- Form competing hypotheses; gather evidence that separates them.
- Trace the first bad boundary. Do not equate restart, retry, or error suppression
  with root-cause repair.
- Never request, expose, or infer secrets or production data from logs.

Output: reproduction, causal explanation, smallest repair, regression guard, and
before/after proof. Owners: [Runtime Errors](../agent_kb/devtools_runtime_errors.md),
[Adaptive Execution](../agent_kb/adaptive_execution.md), and
[Crashlytics Triage](../observability/crashlytics_triage_runbook.md).

## 5. Large-scale refactoring and API renaming

**Best fit:** Mechanical, compiler-visible transformations after the semantic target,
  compatibility policy, and migration order are human-approved.

- **Controls:** Inventory definitions, callers, tests, generated code, public exports,
  configuration, docs, and platform-specific references before editing.
- Split work into reviewable batches with intermediate green states.
- Use syntax-aware tooling where available; review every broad search/replace.
- Human owns public API compatibility, deprecation window, rollout, and rollback.

Output: impact inventory, migration sequence, old-symbol absence proof, analyzer
results, focused tests, and residual compatibility risks. Rebuild structural
indexes after moves or renames: [Code Review Graph](code_review_graph.md).

## 6. Test generation, including edge cases

**Best fit:** Expanding an agreed behavior contract into unit, Cubit/BLoC, widget,
  integration, and regression scenarios.

- **Controls:** Derive assertions from requirements and public behavior, not current private
  implementation.
- Include relevant empty, malformed, denied, retry, duplicate, concurrent,
  cancellation, lifecycle, offline, stale-result, and recovery paths.
- For bug fixes, show the focused guard fail before the repair when practical.
- Human reviewer checks that generated tests can fail for the intended defect and
  do not merely preserve accidental behavior.

Output: risk-to-test mapping, executable test paths, exact results, and justified
skips. Owners: [Testing Matrix](../testing/matrix_required_by_change.md),
[Testing Overview](../testing_overview.md), and [Code Review Playbook](../review/code_review_playbook.md).

## 7. Documentation and README updates

**Best fit:** Synchronizing documented behavior, navigation, commands, examples, and change
  history after the underlying source of truth is known.

- **Controls:** Inspect current code, tests, and commands before describing behavior.
- Update the canonical owner first; keep indexes and adapters thin.
- Distinguish current behavior, historical evidence, planned work, and unknowns.
- Never invent validation results, production claims, metrics, or ownership.

Output: small owner-doc diff, repaired navigation, link/gardening proof, and an
honest validation report. Owners: [Documentation Index](../README.md) and
[Agent Knowledge Base](../agent_knowledge_base.md#doc-gardening).

## 8. Static analysis and lint-fix iteration

**Best fit:** Resolving deterministic analyzer, formatter, custom-lint, and repository guard
  findings with clear diagnostics.

- **Controls:** Group findings by root rule; repair cause instead of adding broad ignores.
- Apply changes in bounded batches and rerun the narrowest relevant check early.
- Inspect semantics after automated fixes, especially nullability, async,
  lifecycle, equality, generated code, and platform branches.
- Do not weaken lint configuration or tests merely to make output green.

Output: diagnostic inventory, fix categories, remaining findings, exact command
results, and tests for behavior-changing fixes. Owners:
[Linter Rules Review](../engineering/linter_rules_review.md),
[Code Quality](../CODE_QUALITY.md), and [Validation Routing](../engineering/validation_routing_fast_vs_full.md).

## 9. Migration scripts and configuration updates

**Best fit:** Deterministic, reviewable schema/config transformations with fixtures,
  dry-runs, idempotency, and explicit recovery behavior.

- **Controls:** Human approves target environment, compatibility window, rollout, rollback,
  destructive effects, and production execution.
- Agent reads current version, source of truth, generated ownership, and platform
  variants before editing.
- Test fresh install, upgrade, repeated run, partial failure, unknown version,
  downgrade or recovery, and secret-free configuration paths when relevant.
- Never apply remote migrations, deploy, or access credentials without explicit
  authorization for the exact target and action.

Output: versioned migration/config diff, dry-run or fixture proof, rollback plan,
and environment limitations. Owners: [Hive Schema Migrations](../offline_first/hive_schema_migrations.md),
[Supabase Migrations](../offline_first/supabase_migrations.md), and
[Security and Secrets](../security_and_secrets.md).

## 10. Structured research within a repository

**Best fit:** Comparing current implementations, locating conventions, evaluating options,
  or answering a bounded technical question from repository evidence.

- **Controls:** Begin with question, decision it informs, scope, source hierarchy, and stop rule.
- Search indexes first, then owner docs, source, tests, history, and generated
  reports only where relevant.
- Record contradictions and freshness. Current code/tests beat stale plans or
  generated summaries; external facts require current primary sources.
- Keep research read-only until implementation is separately in scope.

Output: question, sources inspected, verified findings, conflicting evidence,
options, recommendation, confidence, and remaining unknowns. Owners:
[Context Loading](context_loading.md), [Memory and Context](../agent_kb/memory_and_context_ladder.md),
and [Project Context](../agent_project_context.md).

## Acceptance checklist

Before accepting agent output:

- Task matched one of these bounded areas; human-owned decisions stayed human-owned.
- Agent used current repository owners and identified exceptions before bulk work.
- Diff remains reviewable and reversible; no unrelated cleanup entered scope.
- Verification can disprove the result and was independently inspected.
- Limitations, skipped checks, compatibility risk, and follow-up ownership are explicit.
