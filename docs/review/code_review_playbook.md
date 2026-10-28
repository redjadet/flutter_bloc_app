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

#### Scope discipline

Before reading implementation, capture:

- Intended user outcome and non-goals (one primary user/risk story).
- Changed paths, base branch, and whether unrelated changes exist.
- Whether behavior change and opportunistic refactoring are separated; if
  inseparable, explicit justification in the PR body.
- **Pass/fail result checks** the change must meet (command + observable
  evidence each), not implementation how-to. Prefer a short linked brief,
  PR checklist, or feature Tests rows over a prose-only “done” claim.
- Acceptance criteria, known constraints, and rollback/recovery impact.
- Expected behavior from the requirement or domain contract, including an
  invariant, a boundary/invalid case, and failure behavior before comparing tests.
- Risk classification: low, medium, or high — and the matching **human reading
  depth** (see Roles table and
  [`../ai/governance.md`](../ai/governance.md) § Human verdict by risk):
  low → prioritize evidence and findings; medium → one independent human on
  behavior and seams; high → independent reviewer (two when policy requires)
  on security/data/lifecycle paths. Agent approval never counts as a human
  verdict. Product code still needs a human merge decision in this portfolio.
- Required validation lane from
  [`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).
- Size is a review **prompt**, not a merge gate; coherence and reversibility
  decide split.

For non-trivial feature work, require a feature brief with executable test rows;
use [`../architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md)
and [`../testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md).

**Proof before the diff:** for AI-authored work, the author (or implementer
agent) must present evidence against each pass/fail check before the reviewer
opens the implementation diff. A summary that only says “done” or “tests pass”
is not evidence. Reviewers start from that evidence and the contract, then read
code where risk and failed/weak checks demand it.

### 2. Read context before diff

Start with [`../../AGENTS.md`](../../AGENTS.md), then load only relevant owner
docs through [`../ai/context_loading.md`](../ai/context_loading.md). **Read the
current implementation**, adjacent tests, and caller/callee seams before
commenting or approving edits—do not review from the diff alone. Match reading
depth to the risk tier from step 1. For AI-authored changes, also apply
[`../ai_code_review_protocol.md`](../ai_code_review_protocol.md).

Questions to answer:

- What contract changed, and who consumes it?
- Which state, failure, cancellation, retry, offline, or lifecycle paths exist?
- What existing feature establishes the local convention?
- Could this change alter platform, accessibility, localization, or persistence
  behavior outside the visible happy path?
- For consequential behavior, can a teammate find the invariant, relevant
  failure modes, and rejected alternative in the PR decision note or linked
  repo documentation without asking the author? Check each claim against the
  implementation and proof, especially retry and partial-success conditions.

### 3. Review in risk order

Mandatory priority for this portfolio: **security → correctness → architecture**,
then UI/performance polish. Do not let formatting or layering discussion hide a
security or behavioral defect. AI review output is draft evidence only; a human
owns the merge decision.

1. Scope and public contract — solves requested problem; no unrelated rewrite;
   no unrequested Cloud Functions / Edge Functions / backend surface.
2. Security and privacy — apply [`security_checklist.md`](security_checklist.md):
   authz, **auth ≠ ownership** in rules/RLS, input boundaries, secrets,
   logging, storage, replay/idempotency.
3. Correctness — state and async behavior via [`bloc_checklist.md`](bloc_checklist.md)
   (visible states, request freshness, disposal, no stale completion); async
   `for` + `await` (not `forEach`); `context.mounted` after `await`; fail-visible
   missing config; tests not deleted/weakened to green.
4. Architecture and ownership — apply
   [`architecture_checklist.md`](architecture_checklist.md):
   `Presentation -> Domain <- Data`, pure domain, Cubit/BLoC (no feature
   `ChangeNotifier`), no feature leakage.
5. UI and platform behavior — use [`../../DESIGN.md`](../../DESIGN.md) and
   [`../design_system.md`](../design_system.md): loading/error/empty states,
   responsive layouts, keyboard/accessibility, supported-platform paths.
6. Performance and reliability — apply
   [`performance_checklist.md`](performance_checklist.md): rebuild scope, list
   identity, repeated I/O, cancellation, cache bounds, large-data behavior.
7. Tests, readability, and operations — tests assert contracts and edge cases;
   names, focused units, and “why” comments make the next change safe (see
   [`../CODE_QUALITY.md`](../CODE_QUALITY.md) § Clean code in the AI era);
   logs/errors preserve stable, non-sensitive recovery signals.

Inspect every changed file, including tests, lockfiles, dependencies, CI,
configuration, and files outside the expected scope. For changed tests, check
deletions, skips, weaker assertions, and mocks that replace the behavior under
test. Compare expected results with the independent behavior contract; passing
tests alone cannot validate a mistaken contract.

### 4. Write actionable findings

Label each finding as **Spec** (breaks a stated pass/fail check or requested
outcome) or **Standards** (breaks a repo rule, checklist, or named smell). Keep
the two sets apart so a clean Standards pass cannot hide a Spec miss. Treat AI
findings as hypotheses until a human or independent proof confirms them.

Each finding contains:

```text
[severity] [Spec|Standards] title
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

#### Self-verification

Author command output is input, not final proof. Before approving, re-check
conclusions against the request, contract checks, diff, proof, blockers, and
residual risks. Re-run narrowest honest checks from repository root and inspect
output. Minimum lanes:

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
Before merge, verify required checks ran and passed on the submitted PR head;
workflow definitions or an earlier green commit are not merge proof. GitHub
branch protection or rulesets must require those checks to enforce the gate.

### 6. Resolve and close

After a patch, review final diff again. Confirm no finding was fixed by moving
the failure across a layer, hiding an error, weakening a test, or adding an
unbounded retry. Re-run checks affected by the fix.

**Three-round rethink:** after three author↔reviewer fix rounds on the same
change without converging, stop looping. Step back, tighten or correct the
pass/fail contract, and rethink the approach before another AI fix pass. Do not
run AI review in a loop until it comes back clean.

When a finding class repeats, land a durable guardrail (focused test, lint,
script, or owner-doc check) and add it to the pass/fail contract for later work.

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
- Prefer a **fresh-session** AI review (and optional second model) that did not
  author the change; keep Spec and Standards answers apart. Cross-host second
  opinion when useful: `./tool/request_codex_feedback.sh`,
  `./tool/run_codex_plan_review.sh`.
- Search for existing repository helpers, contracts, and tests before suggesting
  a new abstraction or dependency.
- Inspect success and failure paths: empty/malformed input, repeated tap,
  concurrent request, cancellation, offline/resume, app restart, and large data
  where relevant.
- Never expose credentials, tokens, PII, or full sensitive payloads in review
  comments or logs.
- Keep AI suggestions non-authoritative until a human accepts them; human
  reviewer remains accountable for merge decision. An agent’s approval never
  counts as a person’s.
- After repeated failure class, propose a durable guardrail—test fixture,
  validation script, template, or owner-doc update—rather than another prompt
  instruction. Honor the three-round rethink stop in § Resolve and close.

## Fast Checklist

Before approval, reviewer can answer yes to all:

- Requested outcome and boundaries understood; pass/fail checks exist; diff
  tells one coherent story.
- Author evidence for those checks was inspected before deep-diving the diff.
- Diff has no unrelated changes or each exception is justified (including
  inseparable refactor); no unrequested Cloud/Edge Functions.
- Rollback/reversibility impact is clear for risky changes.
- Security (incl. auth≠ownership), correctness (async/`mounted`/config/tests),
  then architecture/layering, UI, and performance checks relevant to paths ran.
- Spec vs Standards findings are separated; AI findings treated as hypotheses.
- Tests prove behavior and failure paths, not only implementation details.
- Changed tests retain meaningful assertions; deleted, skipped, or mocked tests
  have a reviewed reason.
- Validation is fresh, scope-matched, and independently inspected.
- Findings have disposition; accepted risks have owner and revisit trigger;
  three-round rethink applied when looping.
- Final decision and residual risks are recorded; AI review did not substitute
  for human merge judgment.
- LOC/size alone did not decide approve/split.

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
