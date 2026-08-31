# Agent Operating Manual

Senior-engineer operating rules; pointers to canon, not duplicates.

## Mission

Deliver correct, maintainable, verified outcomes: understand first, preserve
architecture, make the smallest practical diff, and escalate only dangerous
actions or genuinely user-owned decisions.

## When to read

T1/T2 coding tasks after [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight and context ladder step 2b.

## Engineering judgment loop

Use this loop for implementation, refactoring, and review:

1. **Define problem and done.** Confirm requirements, boundaries, evidence, edge cases, assumptions, and risks. Stop when two valid interpretations remain — [`adaptive_execution.md`](../agent_kb/adaptive_execution.md) (95% rule). Correct code for the wrong problem fails.
2. **Choose clarity.** Prefer direct, unsurprising code, meaningful names, small functions, and obvious structure over cleverness.
3. **Justify abstractions.** Add indirection only for demonstrated reuse, variation, test seams, or external dependencies—not imagined needs.
4. **Design failure paths.** Define relevant invalid, absent/null, dependency-failure, cancellation, race, stale-result, retry, and partial-completion behavior; test important paths.
5. **Refactor deliberately.** Within the write-set, remove duplication, misleading names, oversized responsibilities, and accidental complexity exposed by the change.
6. **Understand reuse.** Read copied/generated code and package contracts; verify them against current behavior and pinned APIs.
7. **Communicate decisions.** Record context, assumptions, trade-offs, rejected simpler options, and requirement changes where maintainers will find them; comments explain why.
8. **Recheck.** Ask: “Is this clear, necessary, simple, resilient, and understandable six months from now?” Inspect diff and proof before reporting.

## Readable code and useful comments

Make the normal path understandable to human and AI maintainers through precise
names, small cohesive units, explicit data flow, and unsurprising control flow.
Do not use comments to rescue avoidable complexity; rename or extract first
when that makes intent clear.

Add a concise comment or Dart doc comment when important context remains hidden
from the code itself:

- explain **why** a choice exists, including product rules, rejected simpler
  options, compatibility workarounds, or external constraints;
- state invariants, ordering requirements, units, ownership, lifecycle,
  concurrency, retry, cache, security, or offline assumptions that a future
  change could violate;
- document public or reusable contracts when the signature cannot express
  preconditions, side effects, failure behavior, or caller responsibilities;
- describe a non-obvious algorithm at its decision boundary, not every line.

Comments must stay next to the governed code, use project terms, and change or
disappear with the behavior they describe. Never narrate obvious syntax, repeat
the implementation, preserve dead code, add author/tool commentary, or leave an
ownerless `TODO`. If removing a comment makes behavior unclear, either improve
the code or retain the smallest comment that preserves the missing context.

## Understanding loop

For every non-trivial session, AI agent and human operator use this loop:

1. **Baseline** — state the current mental model, important unknowns, and what
   evidence would confirm or change it.
2. **Test** — connect inspection, implementation, and verification results to
   that model. Do not treat forward task motion as understanding.
3. **Teach back** — explain the solution shape, key invariant, trade-off, and
   failure/debugging model without relying on the session transcript.
4. **Gate** — ask: **“After this session, do I know more than I did before it
   started, or am I just further along?”** A successful non-trivial closeout
   must answer **“Yes — I know more than I did before it started”** and support
   that answer with specific concepts. If it cannot, continue investigation or
   report the unresolved understanding gap; working code alone is not done.

Closeout format: [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md).
For medium- and high-risk work, retain the teach-back in PR or task evidence.

## Topic routing

| Manual theme | Canonical owner |
| --- | --- |
| Mission / engineering mindset | This doc § Mission; [`agent_knowledge_base.md`](../agent_knowledge_base.md) Core Beliefs |
| Project context / platforms / existing code | [`agent_project_context.md`](../agent_project_context.md), [`tech_stack.md`](../tech_stack.md), [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) |
| Simplicity / readability / useful comments / resilient design | This doc §§ Engineering judgment loop and Readable code and useful comments; [`agent_kb/adaptive_execution.md`](../agent_kb/adaptive_execution.md) |
| Flutter widgets / composition | [`DESIGN.md`](../../DESIGN.md), [`design_system.md`](../design_system.md) |
| flutter_bloc / state | [`bloc_standards.md`](../bloc_standards.md), [`review/bloc_checklist.md`](../review/bloc_checklist.md) |
| Architecture layers | [`clean_architecture.md`](../clean_architecture.md), [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) |
| Async / errors / performance | [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md), bloc_standards |
| Code style | [`CODE_QUALITY.md`](../CODE_QUALITY.md) |
| Documentation policy | AKM § Doc Gardening; [`feature_implementation_guide.md`](../feature_implementation_guide.md) |
| Testing | [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) |
| Verification commands | [`agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser |
| Security | [`security_and_secrets.md`](../security_and_secrets.md), [`review/security_checklist.md`](../review/security_checklist.md) |
| Git, branches, PRs, and worktrees | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) |
| Stop conditions | [`governance.md`](governance.md) |
| Safety contracts / closeout proof | [`agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md) (`SAFETY-01..06`, `SAFETY-REPORT`) |
| Response / DoD | [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) |

## Verification mapping

When any `.dart` file changed: run format **before finish** (mandatory) — prefer `./bin/format`.

| Manual command | Repo command |
| --- | --- |
| `dart format .` | `./bin/format` or `./bin/format --changed` |
| `flutter analyze` | `./tool/analyze.sh` |
| `flutter test` | Focused `flutter test <paths>`; broad `./bin/checklist-fast` |
| Integration test | `./bin/integration_tests`; `./bin/integration_preflight` when applicable |
| `dart run build_runner build --delete-conflicting-outputs` | Same when codegen touched — [`contributing.md`](../contributing/contributing.md) |
| Default full lane | `./bin/checklist-fast` or `./bin/checklist` per Validation Chooser |

## Dependency gate

Before `pubspec.yaml`: (1) Flutter SDK enough? (2) existing package? (3) actively maintained? Escalate if unclear.

## AI behaviour rules

| Rule | Owner |
| --- | --- |
| No hallucinated APIs/deps | `RISK-STALE-API`; review protocol |
| No placeholders unless asked | AKM AI Productivity Traps |
| Never claim tests passed without evidence | `RISK-VALIDATION-SHORTCUT` |
| No silent destructive/external/Git effects | `RISK-DESTRUCTIVE-SIDE-EFFECT`; [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) § AI agent rules |
| No permission loops for safe in-scope work | [`agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md) `SAFETY-01`, `SAFETY-05` |
| No SDK/framework patches | `RISK-FLUTTER-SDK-MUTATION` |
| No new state mgmt / DI / navigation | `RISK-ARCH-LAYER`, `RISK-BLOC-DIVERGENCE` |
