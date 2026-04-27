# AI Code Review Protocol

AI code is draft until review gate passes. Before report: self-verify output vs request, diff, proof, blockers, residual risks.

Pinned repo toolchain: Flutter 3.41.7 / Dart 3.11.5.

Adapted from Vinod Pal’s March 8, 2026 checklist:
<https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8>

Review gate before normal validation. Complements automated checks; does not replace them.

Use [`agent_knowledge_base.md`](agent_knowledge_base.md) for source layout. If [`AGENTS.md`](../AGENTS.md) unavailable, combine this with [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md). [`agents_quick_reference.md`](agents_quick_reference.md) is command lookup.

## Checks

| Check | What to ask |
| --- | --- |
| Draft first | Am I still treating the first output as draft, not truth? |
| Assumptions | Did I surface ambiguous scope, data, format, privacy, volume, or UX assumptions before coding? |
| Problem fit | Does the change fit the user outcome and production path, not just the local function body? |
| Simplify | Is this the smallest change that solves the task without speculative abstractions? |
| Security | Did I review auth, replay, retries, logging, secrets, file access, sync, and `--dart-define` handling? |
| Performance | Did I check rebuild scope, repeated I/O, parsing on the UI isolate, polling/listeners, allocations, and scale bottlenecks? |
| Edge cases | Did I reason about empty, malformed, repeated, concurrent, offline, resumed, interrupted paths? |
| Dependencies | Does the repo already have a suitable utility, and is the new dependency worth its cost? |
| Legibility | Can a future Codex/Cursor run inspect the relevant docs, tests, fixtures, logs, or UI proof without chat context? |
| Confidence | Does my confidence come from proof, and did I state uncertainty when risk remains? |
| Focused tests | Is proof scope-matched, with regression coverage where practical, async-state reasoning/coverage, and no deprecated Flutter test APIs? |
| Judgment and ownership | Did I document the tradeoff and keep ownership of failures in the changed surface? |
| Scope discipline | Does every changed line trace to the request or to validation/doc updates required by that same change? |
| Self-verification | Before reporting back, did I check my final answer against the request, changed files, validation results, blockers, and residual risk? |

## AI-Generated-Code Risk Matrix (compact)

Use when reviewing AI-written diffs or adding helper scanners. Goal: high-impact failures, low noise.

| Risk | Common smell | What to do | Proof to prefer |
| --- | --- | --- | --- |
| Injection (SQL/GraphQL/command/HTML) | string concatenation into query/HTML/CLI args | parameterize, strict allowlists, encode/escape, validate inputs | focused unit tests + grepable guardrails |
| XSS-style UI injection | unsafe HTML rendering, missing escaping | avoid raw HTML; sanitize/escape; constrain allowed markup | widget tests / snapshot proof where applicable |
| Hardcoded secrets / tokens | API keys, JWTs, DSNs, “sk-”, “AKIA”, long hex/base64 | remove; use env/secret store; blocklist patterns; rotate if real | repo scan + CI guard; no secret in git diff |
| Swallowed errors | `catch (e) {}` / broad `except Exception: pass` | catch narrow; log/return typed error; keep stable error contract | tests asserting error codes/messages |
| Missing auth/ownership | public endpoints mutate data; no user scope | add auth gate or explicitly document “demo-open” | route docs + tests; explicit decision log |
| Race / concurrency bugs | async overlap, shared mutable state, non-idempotent retries | idempotency keys, locks/semaphores, debouncing, request coalescing | adversarial tests; deterministic reproduction harness |
| Excessive I/O / N+1 | loops doing network/disk/db work | batch, cache, index, move off UI isolate | perf note + small benchmark if needed |
| Deprecated/unstable APIs | uses removed Flutter test APIs / old SDK calls | update to supported APIs; align with repo conventions | `./bin/checklist-fast` or targeted checks |
| Hallucinated deps / wrong APIs | adds packages “because”; calls non-existent helpers | verify repo has it; prefer existing utilities | `pubspec`/lock unchanged unless required |
| Weak tests (mirror impl) | tests assert internal calls, not behavior | assert user-visible behavior/contracts, include edge inputs | red/green for bug repro; contract tests |

## Before Accepting AI-Written Code

Do in order:

1. **Checks:** Apply **Ten Checks** above.
2. **Goal:** If request is vague, define success criteria and smallest verifiable slice.
3. **Diff:** Review changed files/generated artifacts.
4. **Verify:** Run smallest honest validation command (route via [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md)).
5. **Self-verify:** Final response vs request, diff, proof, blockers, residual risk.
6. **Extra review (risk-based):** Medium/high risk -> prefer 1 extra review pass.
   Cross-host diff review (explicit request): `./tool/request_codex_feedback.sh`.
   Cross-host plan review: `./tool/run_codex_plan_review.sh PATH/TO/plan.md`.

Repeated critique => repo-visible capability: source-doc update, validation check, test helper, fixture, route proof, or task template.

## Special Cases

Dependency changes: justify package/upgrade, check existing deps first, and don’t treat `flutter pub get` as validation.

Widget identity (keys) invariants:

- In `ListView.builder`, `ListView.separated`, sliver builders, and similar, **rows must have a stable `Key` from durable id** (not index) when the list can reorder/filter/insert/delete.
- In `AnimatedSwitcher` and similar mode-switching widgets, **the child must have explicit identity** (for example, `KeyedSubtree(key: ValueKey('mode'), child: …)`) so Flutter doesn't reuse the wrong `Element`.
- Guardrail: `./tool/check_widget_identity.sh` (wired into `./bin/checklist`; `./bin/checklist-fast` runs it for local tooling/docs changes that include Dart tooling files).
- Suppress only with reason: `// widget_identity:ignore <reason>` on same line or line above flagged construct.

Bug-fix path:

1. reproduce or reason clearly about failure
2. add focused guard
3. implement fix
4. validate narrowed scope

Widget-test viewport setup:

- Use `tester.view.physicalSize` and `tester.view.devicePixelRatio`.
- Reset with `tester.view.resetPhysicalSize()` and `tester.view.resetDevicePixelRatio()`.
- Don’t use deprecated `tester.binding.window` or `TestWidgetsFlutterBinding.window` test-value APIs.

Async list builders:

- In `ListView.builder`, `ListView.separated`, and sliver builders, don’t index live Cubit/BLoC lists when async refresh can shrink list.
- Snapshot list at build start, derive `itemCount` from snapshot, guard stale indexes before indexing. Header-row patterns like `items.length + 1` with `items[index - 1]` are highest risk.
- Add widget regression coverage when fixing runtime list-builder `RangeError`.

## Relationship To Validation

This protocol complements, but doesn't replace:

- `./bin/router_feature_validate`
- `./tool/delivery_checklist.sh` / `./bin/checklist`
- `./bin/integration_tests`
- targeted format, analyze, and test runs
