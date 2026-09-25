# Contributing

Contributions are welcome. The repo favors small, validated changes that keep
architecture boundaries, tests, and documentation aligned with behavior.

## Spine-first contribution rule

Before adding a demo route or expanding a Depth/Archive module, prefer work on
the **interview spine** (Counter, Todo, Chat, Settings sync diagnostics, agent
harness) and tagged **Spine** features in
[`feature_overview.md`](../feature_overview.md).

| Tier | Expectation |
| --- | --- |
| **Spine** | Default investment: contracts, tests, docs, honesty |
| **Depth** | Touch only when the PR’s goal needs that signal |
| **Archive** | No net-new investment unless promoted or swapped ([ADR 0005](../adr/0005-interview-showcase-scope.md)) |

Acknowledge Archive / ADR-0005 on the PR checklist when adding a demo route.
Scope freeze: [`scope_register.md`](../scope_register.md).

## HITL review expectations

Human–AI collaboration is a first-class pillar. Reviewers and agents should
treat ownership as enforceable, not theatrical:

| Topic | Expectation |
| --- | --- |
| Decision ownership | Follow [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) — human-only for secrets, deploy, IAM, architecture forks |
| Proof | Finish-gate / SAFETY-REPORT shape; sample: [`ai/sanitized_aidlc_safety_report_sample.md`](../ai/sanitized_aidlc_safety_report_sample.md) |
| Safety | [`agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md) (SAFETY-01…06) |
| Review protocol | [`ai_code_review_protocol.md`](../ai_code_review_protocol.md) + [`review/code_review_playbook.md`](../review/code_review_playbook.md) |
| Validation lane | Narrowest honest lane — [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md) |

Agents must not broaden write-set, invent out-of-scope phases, or claim green
without commands. Humans approve merge / production auth / secret rotation.

## Before opening a PR

1. Run the right validation scope for your change.
2. Add or extend tests when behavior changes.
3. Update the owning docs when setup, workflow, or feature behavior changes.
4. Keep changes inside the established `Presentation -> Domain <- Data`
   structure.
5. Follow [Git and Branching Strategy](../git_and_branching_strategy.md) for
   branch, worktree, PR, merge, and cleanup rules.

## Validation commands

| Command | When to use it |
| --- | --- |
| `./bin/checklist` | Default local quality gate before opening a PR. |
| `./bin/integration_tests` | When integration-covered flows changed or you need device-level confidence. |
| `dart run build_runner build --delete-conflicting-outputs` | When touching generated models, APIs, or annotations. |

For validator coverage and script behavior, see
[Validation Scripts](../validation_scripts.md). For testing structure and suite
layout, see [Testing Overview](../testing_overview.md).

## Documentation expectations

Update docs in the same change when you modify:

- Feature behavior or visible routes
- Setup or secrets requirements
- Validation or testing workflow
- Release or deployment steps (including Fastlane lanes under `fastlane/Fastfile` and wrappers in `tool/`)
- Architecture or layering rules

Prefer updating one source-of-truth doc instead of copying the same explanation
into several files.

## Where to start

- [Architecture tour (≤15 min)](../architecture_tour.md)
- [New Developer Guide](../new_developer_guide.md)
- [Git and Branching Strategy](../git_and_branching_strategy.md)
- [Security and Secrets](../security_and_secrets.md) (templates: [`envrc.example`](../envrc.example), [`.env.example`](../../.env.example))
- [Feature Overview](../feature_overview.md)
- [Case studies](../case_studies/README.md) (product briefs; **Case Study Demo** feature)
- [Feature Delivery Guide](../feature_implementation_guide.md)
- [Clean Architecture](../clean_architecture.md)
- [Tech Stack](../tech_stack.md)

## Pull request quality bar

- The diff should be understandable without hidden context.
- New abstractions should earn their keep; reuse existing shared code first.
- User-facing or cross-cutting changes should include doc updates.
- Validation should be run before requesting review.
- Behavior-changing PRs include tests that would catch refactor regressions in adjacent flows, or document **Tests: N/A — reason** in the linked feature brief or `docs/changes/` note.
- Consequential behavior or design changes include a **Decision note** (or `N/A — reason`) per [`git_and_branching_strategy.md`](../git_and_branching_strategy.md) § Pull request contract.
- Spine-first + HITL ownership checked (sections above).
