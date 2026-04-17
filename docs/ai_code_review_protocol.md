# AI Code Review Protocol

Treat AI-generated code as draft output that must pass review gate before it
is trusted.

Pinned repo toolchain: Flutter 3.41.7 / Dart 3.11.5.

Adapted from Vinod Pal’s March 8, 2026 checklist:
<https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8>

This review gate comes before normal repo validation. It complements automated
checks; it doesn't replace them.

If [`AGENTS.md`](../AGENTS.md) is unavailable in current host context,
combine this document with
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
to pick validation commands. When present,
[`agents_quick_reference.md`](agents_quick_reference.md) is compact command
lookup only; it doesn't replace [`AGENTS.md`](../AGENTS.md) once that file is available.

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

Work through following; order matters where noted.

1. **Checks:** Apply **Nine Checks** above.
2. **Tracker:** For non-trivial tasks, confirm active plan and verification
   are recorded in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) or
   [`tasks/codex/todo.md`](../tasks/codex/todo.md) per
   [`AGENTS.md`](../AGENTS.md).
3. **Presentation:** For presentation-layer changes, confirm styling uses
   shared theme/design tokens unless file is intentionally defining them.
4. **Delegates:** If subagents or sidecars were used, treat their output as
   draft input and validate integrated result yourself.
5. **Diff:** Review diff manually.
6. **Validate:** Run smallest matching repo validation command. Use
   [`AGENTS.md`](../AGENTS.md) plus
   [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)
   for routing.
7. **Extra review:** For medium/high-risk work, prefer one extra review pass
   before finalizing.
   From non-Codex hosts, that can include
   `./tool/request_codex_feedback.sh` (git diff) or
   `./tool/run_codex_plan_review.sh PATH/TO/plan.md` (tracked template + Codex
   delegate). From Codex itself, use that helper only when user explicitly
   asks for second opinion or cross-host review. Keep
   `./tool/delivery_checklist.sh` / `./bin/checklist` for broad or pre-ship
   sweeps, or when user explicitly asks for full validation pass.
8. **Goal fit:** Confirm solution still aligns with business goal and
   doesn't defer obvious production-risk ownership to unspecified later
   cleanup.
9. **Tradeoffs:** If change makes operational judgment call, record why
   this path was chosen and why simpler or safer-looking alternatives were
   rejected.

## Before Marking The Task Done

- **Evidence:** Prove behavior with scope-matched evidence like tests, logs, screenshots,
  or behavior diffs.
- **Tracker wrap-up:** When plan-first workflow was used, record verification outcome and short
  review notes in host-specific task tracker.
- **Docs and drift:** For docs-only or agent-guidance changes, still validate touched docs,
  links, and any affected host-template drift path instead of treating
  change as proof-free.
- **Lessons:** If user corrected mistake during task, add prevention note to
  [`tasks/lessons.md`](../tasks/lessons.md).
- **Incidents:** If task involved production failure or reliability defect, document
  root cause, guard, or residual risk in verification notes.
- **Decisions:** If task involved material tradeoff, document chosen path briefly
  enough that next engineer can understand decision without redoing
  entire analysis.
- **Communication:** Use caveman-lite brevity for routine review notes and
  status summaries when it reduces tokens without reducing meaning. Switch to
  normal concise prose for security/privacy warnings, destructive actions,
  ambiguous multi-step guidance, or anything that benefits from fuller
  precision.

## Special Cases

Dependency changes:

- Justify new package or upgrade.
- Check whether existing repo dependency already covers need.
- don't rely on `flutter pub get` as validation.

Bug-fix path:

1. reproduce or reason clearly about failure
2. add focused guard
3. implement fix
4. validate narrowed scope

## Relationship To Validation

This protocol complements, but doesn't replace:

- `./bin/router_feature_validate`
- `./tool/delivery_checklist.sh` / `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs
