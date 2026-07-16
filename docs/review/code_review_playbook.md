# Code Review Playbook: AI and Human Reviewers

Use this playbook to turn a proposed change into an evidence-backed decision.
It defines the review workflow; [`../ai_code_review_protocol.md`](../ai_code_review_protocol.md)
defines AI-code risks and deterministic checklists define topic-specific
acceptance criteria. For networking/contract PRs, also use
[`../contributing/PR_REVIEW_CHECKLIST.md`](../contributing/PR_REVIEW_CHECKLIST.md).

## Outcomes

A review ends in one of four states:

| State | Meaning | Required next action |
| --- | --- | --- |
| Approve | Change meets scope and proof requirements. | Record validation and residual risk. |
| Approve with follow-up | Non-blocking debt is explicit and owned. | Link an issue, plan, or change note. |
| Request changes | A concrete defect, contract breach, or missing proof exists. | Cite file, impact, required change, and proof. |
| Block | Review cannot make a safe decision. | State missing access, reproducible evidence, or product decision. |

Do not approve from a green diff, a generated summary, or a passing happy-path
test alone.

## Roles and Independence

| Role | AI may do | Human must own | Guardrail |
| --- | --- | --- | --- |
| Author | Implement, test, summarize assumptions and trade-offs. | Confirm scope and user-owned product decisions. | Smallest reversible diff. |
| AI reviewer | Inspect diff, trace data flow, run deterministic checks, propose findings. | Never silently waive a failed gate or invent execution evidence. | Treat generated code as a draft. |
| Human reviewer | Challenge assumptions, inspect behavior and risk, decide acceptability. | Approval, risk acceptance, external-impact decisions, and exceptions. | Review evidence, not AI confidence. |
| Maintainer | Resolve findings and choose validation lane. | Merge only after required proof and unresolved-risk decision. | Keep review and validation records discoverable. |

For high-risk changes, keep author and final reviewer independent. High risk
includes auth, security, PII, payments, destructive actions, data migration,
offline sync, routing, dependency/DI changes, and broad shared infrastructure.

## Review Workflow

### 1. Establish review contract

Before reading implementation, capture:

- Intended user outcome and non-goals.
- Changed paths, base branch, and whether unrelated changes exist.
- Acceptance criteria, known constraints, and rollback/recovery path.
- Risk classification: low, medium, or high.
- Required validation lane from
  [`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).

For non-trivial feature work, require a feature brief with executable test rows;
use [`../architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md)
and [`../testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md).

### 2. Read context before diff

Start with [`../../AGENTS.md`](../../AGENTS.md), then load only relevant owner
docs through [`../ai/context_loading.md`](../ai/context_loading.md). Read the
current implementation, adjacent tests, and caller/callee seams before
commenting. For AI-authored changes, also apply
[`../ai_code_review_protocol.md`](../ai_code_review_protocol.md).

Questions to answer:

- What contract changed, and who consumes it?
- Which state, failure, cancellation, retry, offline, or lifecycle paths exist?
- What existing feature establishes the local convention?
- Could this change alter platform, accessibility, localization, or persistence
  behavior outside the visible happy path?

### 3. Review in risk order

Review correctness and safety before style. Do not let formatting discussion hide
a behavioral defect.

1. Scope and public contract — solves requested problem; no unrelated rewrite.
2. Architecture and ownership — apply
   [`architecture_checklist.md`](architecture_checklist.md):
   `Presentation -> Domain <- Data`, pure domain, no feature leakage.
3. State and async behavior — apply [`bloc_checklist.md`](bloc_checklist.md):
   explicit visible states, request freshness, disposal, no stale completion.
4. Security and privacy — apply [`security_checklist.md`](security_checklist.md):
   authz, input boundaries, secrets, logging, storage, replay/idempotency.
5. UI and platform behavior — use [`../../DESIGN.md`](../../DESIGN.md) and
   [`../design_system.md`](../design_system.md): loading/error/empty states,
   responsive layouts, keyboard/accessibility, supported-platform paths.
6. Performance and reliability — apply
   [`performance_checklist.md`](performance_checklist.md): rebuild scope, list
   identity, repeated I/O, cancellation, cache bounds, large-data behavior.
7. Tests and operations — tests assert contracts and edge cases; logs/errors
   preserve stable, non-sensitive recovery signals.

### 4. Write actionable findings

Each finding contains:

```text
[severity] title
Location: path:line
Impact: concrete failure or violated contract.
Evidence: code path, test result, or owner rule.
Request: smallest required correction.
Proof: command or test that must pass after correction.
```

Use severity consistently:

| Severity | Meaning | Merge status |
| --- | --- | --- |
| Blocker | Security, data loss/corruption, crash, broken primary flow, or certain contract violation. | Must fix. |
| Major | Likely production defect, missing required proof, or architecture/lifecycle breach. | Must fix or maintainer records explicit risk acceptance. |
| Minor | Real maintainability, resilience, or UX issue with bounded impact. | Fix or track before/after merge by agreement. |
| Nit | Optional clarity/style improvement. | Never block. |

Avoid vague comments such as “consider refactoring.” State the failure mode and
smallest change that removes it. Do not create findings for pre-existing code
unless the proposed change makes the risk worse or the task includes it.

### 5. Validate independently

Author command output is input, not final proof. Re-run narrowest honest checks
from repository root and inspect output. Minimum lanes:

| Change surface | Minimum independent proof |
| --- | --- |
| Docs-only | `bash tool/check_docs_gardening.sh`, `./bin/checklist-fast --no-reuse`, `./bin/agent-maintain closeout` |
| Cubit/BLoC | Focused `flutter test <paths>` and `./tool/analyze.sh` |
| Routing/auth | `./bin/router_feature_validate`; escalate to `./bin/checklist` when broad |
| UI/design | Focused widget proof; `./tool/run_mix_lint.sh` when Mix changes; responsive proof where layout changes |
| Feature architecture | Feature contract checks plus focused tests; full checklist when shared/cross-layer |
| Security/auth/PII | Secret/smell scans and denial-path tests; full checklist for repository, sync, DI, or cross-feature changes |
| Sync, lifecycle, DI, shared infrastructure | `./bin/checklist` plus focused regression proof |
| Integration journey | `./bin/integration_tests` plus supporting focused lane |

Validation routing, platform-specific gates, and escalation rules remain owned by
[`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).
If a command is unavailable or a test is flaky, report that fact; do not
substitute an unrelated green command.

### 6. Resolve and close

After a patch, review final diff again. Confirm no finding was fixed by moving
the failure across a layer, hiding an error, weakening a test, or adding an
unbounded retry. Re-run checks affected by the fix.

Review record:

```markdown
## Review record

- Scope: <paths and outcome>
- Risk: <low|medium|high>; rationale: <one sentence>
- Reviewers: <AI tool/model and human names or roles>
- Findings: <resolved links/count>; exceptions: <owner and expiry>
- Validation: `<command>` — <pass/fail/date>; <known skipped check + reason>
- Residual risk: <none or concrete behavior>
- Decision: <approve|approve with follow-up|request changes|block>
```

For risk acceptance, record owner, rationale, mitigation, and revisit trigger.
“AI said it is safe” is not risk acceptance.

## AI Review Operating Rules

- Separate evidence from inference. Quote paths, commands, and observed output;
  label any unverified conclusion.
- Search for existing repository helpers, contracts, and tests before suggesting
  a new abstraction or dependency.
- Inspect success and failure paths: empty/malformed input, repeated tap,
  concurrent request, cancellation, offline/resume, app restart, and large data
  where relevant.
- Never expose credentials, tokens, PII, or full sensitive payloads in review
  comments or logs.
- Keep AI suggestions non-authoritative until a human accepts them; human
  reviewer remains accountable for merge decision.
- After repeated failure class, propose a durable guardrail—test fixture,
  validation script, template, or owner-doc update—rather than another prompt
  instruction.

## Fast Checklist

Before approval, reviewer can answer yes to all:

- Requested outcome and boundaries understood.
- Diff has no unrelated changes or each exception is justified.
- Layering, state, security, UI, and performance checks relevant to paths ran.
- Tests prove behavior and failure paths, not only implementation details.
- Validation is fresh, scope-matched, and independently inspected.
- Findings have disposition; accepted risks have owner and revisit trigger.
- Final decision and residual risks are recorded.

## Related

- [`../ai_code_review_protocol.md`](../ai_code_review_protocol.md) — AI-code
  risk matrix and specialized review rules.
- [`architecture_checklist.md`](architecture_checklist.md),
  [`bloc_checklist.md`](bloc_checklist.md),
  [`security_checklist.md`](security_checklist.md),
  [`performance_checklist.md`](performance_checklist.md) — deterministic
  topic checks.
- [`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
  — authoritative validation routing.
- [`../git_and_branching_strategy.md`](../git_and_branching_strategy.md) —
  branch, PR, merge, and worktree safety.
