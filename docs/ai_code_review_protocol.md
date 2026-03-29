# AI Code Review Protocol

This repository treats AI-generated code as draft output that must pass an
explicit review gate before it is accepted.

Pinned repo toolchain: Flutter 3.41.6 / Dart 3.11.4.

This protocol adapts Vinod Pal’s March 8, 2026 checklist into repo policy:
<https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8>

The review gate comes before normal repo validation. It complements automated
checks; it does not replace them.

## The eight checks

### 1. Treat the first output as a draft

- Assume the first answer may miss business logic or hidden constraints.
- Do not confuse plausible naming, comments, or formatting with correctness.
- Review generated code with the same skepticism you would apply to a weak
  human draft.

### 2. Confirm it solves the real problem

- Check production behavior, not only the immediate function body.
- Include retries, auth, cancellation, lifecycle, offline behavior, and failure
  handling in the review.
- Reject changes that only solve an idealized or narrowed version of the task.

### 3. Simplify aggressively

- Prefer the smallest change that satisfies the requirement.
- Remove speculative abstractions, redundant helpers, and avoidable nesting.
- If the code cannot be explained quickly, simplify it before accepting it.

### 4. Review security-sensitive paths explicitly

Focus extra attention on:

- auth, token refresh, and session handling
- request replay, retries, and background sync
- file access, uploads, and storage
- logging, crash reporting, and secret handling
- `--dart-define`, environment, and credential usage

### 5. Look for hidden performance costs

Check for:

- repeated network or database work
- wide widget rebuilds
- large synchronous parsing on the UI isolate
- unnecessary listeners, timers, polling, or async churn
- avoidable allocations and list copies

### 6. Break the change with edge cases

Deliberately test or reason about:

- empty values and nulls
- malformed or partial payloads
- large inputs
- repeated taps and concurrent calls
- resumed app state, interrupted flows, and offline recovery

### 7. Question every dependency

Before accepting a new dependency, ask:

- do we already have a repo utility or package that covers this
- does the dependency materially improve the solution
- what maintenance, upgrade, and security cost does it add

If the answer is weak, do not add it.

### 8. Require focused tests or an explicit reason not to add them

Expected by default:

- targeted test updates for behavior changes
- regression guards for bug fixes when practical
- scope-matched repo validation commands

If no new test is added, record why existing coverage is already enough.

## Repo-specific defaults

### Before accepting AI-written code

1. Apply the eight checks.
1. Review the diff manually.
1. Run the smallest matching repo validation command.
1. For medium/high-risk work, prefer a bounded pass via
   `./tool/request_codex_feedback.sh`.

### Dependency changes

When `pubspec.yaml` or `pubspec.lock` changes:

- justify the new package or upgrade
- verify whether an existing repo dependency already solves the problem
- run scope-matched validation instead of relying only on `flutter pub get`

### Bug-fix expectation

Prefer this sequence:

1. reproduce or reason clearly about the failure
1. add a focused guard
1. implement the fix
1. validate the narrowed scope

## Relationship to repo validation

This protocol complements, but does not replace:

- `./bin/router_feature_validate`
- `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs

The review gate answers, "Should we trust this change enough to validate it?"
The validation scripts answer, "Does the implementation satisfy the repo’s
delivery checks?"
