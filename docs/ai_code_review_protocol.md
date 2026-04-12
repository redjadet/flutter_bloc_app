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

## The Eight Checks

1. **Draft first**
   Treat the first output as a draft. Do not confuse plausible code, comments,
   or naming with correctness.
2. **Problem fit**
   Check production behavior, not just the local function body. Include auth,
   retries, cancellation, lifecycle, offline behavior, and failure handling.
   Reject happy-path-only widget changes that move shared state into callback
   chains or place side effects in `build()`.
3. **Simplify**
   Prefer the smallest change that solves the task. Remove speculative
   abstractions, redundant helpers, and avoidable nesting.
4. **Security**
   Review auth/session handling, request replay, retries, background sync, file
   access, logging, secrets, and `--dart-define` usage explicitly.
5. **Performance**
   Check for repeated I/O, wide rebuilds, large synchronous parsing on the UI
   isolate, unnecessary listeners/timers/polling, avoidable allocations, and
   static subtrees that should stay `const`.
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

## Before Accepting AI-Written Code

1. Apply the eight checks.
2. For non-trivial tasks, confirm the active plan and verification are recorded
   in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or
   [`tasks/codex/todo.md`](../tasks/codex/todo.md) per
   [`AGENTS.md`](../AGENTS.md).
3. For presentation-layer changes, confirm styling uses shared theme/design
   tokens unless the file is intentionally defining tokens.
4. If subagents or sidecars were used, review their output as draft input and
   validate the integrated result yourself.
5. Review the diff manually.
6. Run the smallest matching repo validation command.
   Use [`AGENTS.md`](../AGENTS.md) plus
   [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
   for routing.
7. For medium/high-risk work, prefer one extra review pass before finalizing.
   From non-Codex hosts, that can include
   `./tool/request_codex_feedback.sh`. From Codex itself, use that helper only
   when the user explicitly asks for a second opinion or cross-host review.
   Keep `./bin/checklist` for broad or pre-ship sweeps, or when the user
   explicitly asks for the full validation pass.

## Before Marking The Task Done

1. Prove behavior with scope-matched evidence such as tests, logs, screenshots,
   or behavior diffs.
2. When plan-first workflow was used, record verification outcome and short
   review notes in the host-specific task tracker.
3. For docs-only or agent-guidance changes, still validate the touched docs,
   links, and any affected host-template drift path instead of treating the
   change as proof-free.
4. If the user corrected a mistake during the task, add a prevention note to
   [`tasks/lessons.md`](../tasks/lessons.md).

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
