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
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
to pick validation commands. When present,
[`agents_quick_reference.md`](agents_quick_reference.md) is a compact command
lookup only; it does not replace [`AGENTS.md`](../AGENTS.md) once that file is available.

## The Nine Checks

| Check | What to ask |
| --- | --- |
| Draft first | Am I still treating the first output as draft, not truth? |
| Problem fit | Does the change fit the user outcome and production path, not just the local function body? |
| Simplify | Is this the smallest change that solves the task without speculative abstractions? |
| Security | Did I review auth, replay, retries, logging, secrets, file access, sync, and `--dart-define` handling? |
| Performance | Did I check rebuild scope, repeated I/O, parsing on the UI isolate, polling/listeners, allocations, and scale bottlenecks? |
| Edge cases | Did I reason about empty, malformed, repeated, concurrent, offline, resumed, and interrupted paths? |
| Dependencies | Does the repo already have a suitable utility, and is the new dependency worth its cost? |
| Focused tests | Is there scope-matched proof, regression coverage where practical, and async-state reasoning or coverage? |
| Judgment and ownership | Did I document the tradeoff and keep ownership of failures in the changed surface? |

## Before Accepting AI-Written Code

Work through the following; order matters where noted.

1. **Checks:** Apply **The Nine Checks** above.
2. **Tracker:** For non-trivial tasks, confirm the active plan and verification
   are recorded in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or
   [`tasks/codex/todo.md`](../tasks/codex/todo.md) per
   [`AGENTS.md`](../AGENTS.md).
3. **Presentation:** For presentation-layer changes, confirm styling uses
   shared theme/design tokens unless the file is intentionally defining them.
4. **Delegates:** If subagents or sidecars were used, treat their output as
   draft input and validate the integrated result yourself.
5. **Diff:** Review the diff manually.
6. **Validate:** Run the smallest matching repo validation command. Use
   [`AGENTS.md`](../AGENTS.md) plus
   [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
   for routing.
7. **Extra review:** For medium/high-risk work, prefer one extra review pass
   before finalizing.
   From non-Codex hosts, that can include
   `./tool/request_codex_feedback.sh` (git diff) or
   `./tool/run_codex_plan_review.sh PATH/TO/plan.md` (tracked template + Codex
   delegate). From Codex itself, use that helper only when the user explicitly
   asks for a second opinion or cross-host review. Keep
   `./tool/delivery_checklist.sh` / `./bin/checklist` for broad or pre-ship
   sweeps, or when the user explicitly asks for the full validation pass.
8. **Goal fit:** Confirm the solution still aligns with the business goal and
   does not defer obvious production-risk ownership to an unspecified later
   cleanup.
9. **Tradeoffs:** If the change makes an operational judgment call, record why
   this path was chosen and why simpler or safer-looking alternatives were
   rejected.

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
- `./tool/delivery_checklist.sh` / `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs
