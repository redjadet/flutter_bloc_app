# AI Code Review Protocol

Treat AI-generated code as draft output that must pass review gate before it
is trusted. Before reporting back, every agent must self-verify its own final
output against user request, diff, validation evidence, and known residual
risks.

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

## The Ten Checks

| Check | What to ask |
| --- | --- |
| Draft first | Am I still treating the first output as draft, not truth? |
| Problem fit | Does the change fit the user outcome and production path, not just the local function body? |
| Simplify | Is this the smallest change that solves the task without speculative abstractions? |
| Security | Did I review auth, replay, retries, logging, secrets, file access, sync, and `--dart-define` handling? |
| Performance | Did I check rebuild scope, repeated I/O, parsing on the UI isolate, polling/listeners, allocations, and scale bottlenecks? |
| Edge cases | Did I reason about empty, malformed, repeated, concurrent, offline, resumed, and interrupted paths? |
| Dependencies | Does the repo already have a suitable utility, and is the new dependency worth its cost? |
| Focused tests | Is there scope-matched proof, regression coverage where practical, async-state reasoning or coverage, and no deprecated Flutter test APIs? |
| Judgment and ownership | Did I document the tradeoff and keep ownership of failures in the changed surface? |
| Self-verification | Before reporting back, did I check my final answer against the request, changed files, validation results, blockers, and residual risk? |

## Before Accepting AI-Written Code

Work through following; order matters where noted.

1. **Checks:** Apply **Ten Checks** above.
2. **Diff:** Review diff or generated artifacts.
3. **Verify:** Run smallest honest validation command (route via
   [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)).
4. **Self-verify:** Final response vs request + diff + proof + blockers + residual risk.
5. **Extra review (risk-based):** For medium/high-risk work, prefer one extra review pass.
   Cross-host diff review (explicit request): `./tool/request_codex_feedback.sh`.
   Cross-host plan review: `./tool/run_codex_plan_review.sh PATH/TO/plan.md`.

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

Widget-test viewport setup:

- Use `tester.view.physicalSize` and `tester.view.devicePixelRatio`.
- Reset with `tester.view.resetPhysicalSize()` and
  `tester.view.resetDevicePixelRatio()`.
- Do not use deprecated `tester.binding.window` or
  `TestWidgetsFlutterBinding.window` test-value APIs.

Async list builders:

- In `ListView.builder`, `ListView.separated`, and sliver builders, do not index
  live Cubit/BLoC state lists directly when async refresh can shrink the list.
- Snapshot the list at build start, derive `itemCount` from that snapshot, and
  guard stale builder indexes before indexing. This matters most for header-row
  patterns such as `items.length + 1` with `items[index - 1]`.
- Add widget regression coverage when fixing a runtime `RangeError` from a list
  builder.

## Relationship To Validation

This protocol complements, but doesn't replace:

- `./bin/router_feature_validate`
- `./tool/delivery_checklist.sh` / `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs
