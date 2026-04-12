# AI Code Review Protocol

Treat AI-generated code as draft output that must pass a review gate before it
is trusted.

Pinned repo toolchain: Flutter 3.41.6 / Dart 3.11.4.

Adapted from Vinod Pal’s March 8, 2026 checklist:
<https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8>

This review gate comes before normal repo validation. It complements automated
checks; it does not replace them.

If [`AGENTS.md`](../AGENTS.md) is unavailable in the current host context,
combine this document with
[`agents_quick_reference.md`](agents_quick_reference.md) as the repo-visible
fallback.

## The Nine Checks

1. **Draft first**
   Treat the first output as a draft. Do not confuse plausible code, comments,
   or naming with correctness.
2. **Problem fit**
   Check business and production fit, not just the local function body.
   Include the user outcome, auth, retries, cancellation, lifecycle, offline
   behavior, and failure handling. Reject happy-path-only widget changes that
   move shared state into callback chains or place side effects in `build()`.
3. **Simplify**
   Prefer the smallest change that solves the task. Remove speculative
   abstractions, redundant helpers, and avoidable nesting.
4. **Security**
   Review auth/session handling, request replay, retries, background sync, file
   access, logging, secrets, and `--dart-define` usage explicitly.
5. **Performance**
   Check for repeated I/O, wide rebuilds, large synchronous parsing on the UI
   isolate, unnecessary listeners/timers/polling, avoidable allocations,
   scalability bottlenecks, and static subtrees that should stay `const`.
6. **Edge cases**
   Deliberately reason about empty values, malformed payloads, large inputs,
   repeated taps, concurrent calls, resumed app state, interrupted flows, and
   offline recovery.
7. **Dependencies**
   Before accepting a new dependency, ask whether the repo already has a
   suitable utility, whether the dependency materially improves the solution,
   and what upgrade/security cost it adds.
8. **Focused tests**
   Expect targeted test updates, regression guards when practical,
   scope-matched validation, and for async flows either coverage or explicit
   reasoning for loading, empty, and error states.
9. **Judgment and ownership**
   Make the tradeoff explicit when more than one reasonable path exists, and
   treat production failures in the changed surface as your responsibility to
   understand, contain, and follow through on.

## Before Accepting AI-Written Code

Work through the following; order matters where noted.

- **Checks:** Apply **The Nine Checks** above.
- **Tracker:** For non-trivial tasks, confirm the active plan and verification are recorded
  in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or
  [`tasks/codex/todo.md`](../tasks/codex/todo.md) per
  [`AGENTS.md`](../AGENTS.md).
- **Presentation:** For presentation-layer changes, confirm styling uses shared theme/design
  tokens unless the file is intentionally defining tokens.
- **Delegates:** If subagents or sidecars were used, review their output as draft input and
  validate the integrated result yourself.
- **Diff:** Review the diff manually.
- **Validate:** Run the smallest matching repo validation command.
  Use [`AGENTS.md`](../AGENTS.md) plus
  [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
  for routing.
- **Extra review:** For medium/high-risk work, prefer one extra review pass before finalizing.
  From non-Codex hosts, that can include
  `./tool/request_codex_feedback.sh` (git diff) or
  `./tool/run_codex_plan_review.sh PATH/TO/plan.md` (tracked template + Codex delegate).
  From Codex itself, use that helper only
  when the user explicitly asks for a second opinion or cross-host review.
  Keep `./bin/checklist` for broad or pre-ship sweeps, or when the user
  explicitly asks for the full validation pass.
- **Goal fit:** Confirm the solution still aligns with the business goal and does not defer
  obvious production-risk ownership to an unspecified later cleanup.
- **Tradeoffs:** If the change makes an operational judgment call, record why this path was
  chosen and why simpler or safer-looking alternatives were rejected.

## Before Marking The Task Done

- **Evidence:** Prove behavior with scope-matched evidence such as tests, logs, screenshots,
  or behavior diffs.
- **Tracker wrap-up:** When plan-first workflow was used, record verification outcome and short
  review notes in the host-specific task tracker.
- **Docs and drift:** For docs-only or agent-guidance changes, still validate the touched docs,
  links, and any affected host-template drift path instead of treating the
  change as proof-free.
- **Lessons:** If the user corrected a mistake during the task, add a prevention note to
  [`tasks/lessons.md`](../tasks/lessons.md).
- **Incidents:** If the task involved a production failure or reliability defect, document
  the root cause, guard, or residual risk in the verification notes.
- **Decisions:** If the task involved a material tradeoff, document the chosen path briefly
  enough that the next engineer can understand the decision without redoing
  the entire analysis.

## Special Cases

Dependency changes:

- Justify the new package or upgrade.
- Check whether an existing repo dependency already covers the need.
- Do not rely on `flutter pub get` as validation.

Bug-fix path:

1. reproduce or reason clearly about the failure
2. add a focused guard
3. implement the fix
4. validate the narrowed scope

## Relationship To Validation

This protocol complements, but does not replace:

- `./bin/router_feature_validate`
- `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs
