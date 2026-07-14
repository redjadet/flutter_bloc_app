# Agent Operating Manual

Senior-engineer operating rules; pointers to canon, not duplicates.

## Mission

- Optimize for correct, maintainable, verifiable outcomes — not code volume.
- Understand before coding; preserve architecture; smallest practical diff.
- Verify before claiming success; escalate product/UX/arch decisions.

## When to read

T1/T2 coding tasks after [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight and context ladder step 2b.

## Think before coding

- State understanding; list assumptions, risks, missing information.
- Offer a simpler alternative when one exists.
- Stop if two interpretations exist — [`adaptive_execution.md`](../agent_kb/adaptive_execution.md) (95% rule).

## Topic routing

| Manual theme | Canonical owner |
| --- | --- |
| Mission / engineering mindset | This doc § Mission; [`agent_knowledge_base.md`](../agent_knowledge_base.md) Core Beliefs |
| Project context / platforms | [`agent_project_context.md`](../agent_project_context.md), [`tech_stack.md`](../tech_stack.md) |
| Simplicity / surgical / respect architecture | [`agent_kb/adaptive_execution.md`](../agent_kb/adaptive_execution.md) |
| Flutter widgets / composition | [`DESIGN.md`](../../DESIGN.md), [`design_system.md`](../design_system.md) |
| flutter_bloc / state | [`bloc_standards.md`](../bloc_standards.md), [`review/bloc_checklist.md`](../review/bloc_checklist.md) |
| Architecture layers | [`clean_architecture.md`](../clean_architecture.md), [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) |
| Async / errors / performance | [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md), bloc_standards |
| Existing code first | [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) |
| Code style | [`CODE_QUALITY.md`](../CODE_QUALITY.md) |
| Documentation policy | AKM § Doc Gardening; [`feature_implementation_guide.md`](../feature_implementation_guide.md) |
| Testing | [`testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) |
| Verification commands | [`agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser |
| Security | [`security_and_secrets.md`](../security_and_secrets.md), [`review/security_checklist.md`](../review/security_checklist.md) |
| Git, branches, PRs, and worktrees | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) |
| Stop conditions | [`governance.md`](governance.md) |
| Response / DoD | [`agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) |

## Verification mapping

When any `.dart` file changed: run format **before finish** (mandatory) — prefer `./bin/format`.

| Manual command | Repo command |
| --- | --- |
| `dart format .` | `./bin/format` or `./bin/format --changed` |
| `flutter analyze` | `./tool/analyze.sh` |
| `flutter test` | Focused `flutter test <paths>`; broad `./bin/checklist-fast` |
| `flutter test integration_test` | `./bin/integration_tests`; `./bin/integration_preflight` when applicable |
| `dart run build_runner build --delete-conflicting-outputs` | Same when codegen touched — [`contributing.md`](../contributing.md) |
| Default full lane | `./bin/checklist-fast` or `./bin/checklist` per Validation Chooser |

## Dependency gate

Before `pubspec.yaml`: (1) Flutter SDK enough? (2) existing package? (3) actively maintained? Escalate if unclear.

## AI behaviour rules

| Rule | Owner |
| --- | --- |
| No hallucinated APIs/deps | `RISK-STALE-API`; review protocol |
| No placeholders unless asked | AKM AI Productivity Traps |
| Never claim tests passed without evidence | `RISK-VALIDATION-SHORTCUT` |
| No silent destructive/external effects | `RISK-DESTRUCTIVE-SIDE-EFFECT` |
| No unapproved remote or destructive Git action | [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) § AI agent rules |
| No SDK/framework patches | `RISK-FLUTTER-SDK-MUTATION` |
| No new state mgmt / DI / navigation | `RISK-ARCH-LAYER`, `RISK-BLOC-DIVERGENCE` |

## Pointers

Response tiers: [`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) § Response tiers. Loop: [`AGENTS.md`](../../AGENTS.md) § Loop.
