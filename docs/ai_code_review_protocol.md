# AI Code Review Protocol

AI code = draft until review gate passes. Before report: self-verify vs request, diff, proof, blockers, residual risks.

Pinned repo toolchain: Flutter 3.41.9 / Dart 3.11.5.

Adapted from Vinod Pal’s March 8, 2026 checklist:
<https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8>

Use with [`agent_knowledge_base.md`](agent_knowledge_base.md), [`agents_quick_reference.md`](agents_quick_reference.md), and [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md). Cross-host review (`./tool/request_codex_feedback.sh`, `./tool/run_codex_plan_review.sh`) is optional, explicit-request-only, environment-dependent.

## Builder and Validator roles

- **Builder:** smallest reversible diff toward request. Output stays **draft**.
- **Validator:** applies checks below, runs scope-matched validation, self-verifies final report.
- Same host often does both roles; no second agent required.

## Checks

Enforce TDD where practical, linting, build verification, minimal edits, and architecture preservation. Avoid giant prompts, giant rewrites, context flooding, single-agent overload, and unverified outputs.

| Check | What to ask |
| --- | --- |
| Draft first | Am I treating first output as draft, not truth? |
| Reprompt loop | Did I stop after 1-2 critique cycles and switch to evidence + minimal patch instead of regenerating? |
| Assumptions | What assumptions did the AI make about this codebase that might be false? Did I surface ambiguous scope/data/format/privacy/volume/UX? |
| System shape | Are boundaries, data flow, ownership, failure handling, logs, test seams, and rollback clear enough before generation/refactor? |
| Prompt shape | Did guidance separate intent, eval/spec, and implementation; use Goal / Context / Boundaries / Verification; omit nonessential rules; and avoid micromanaging implementation order? |
| Problem fit | Does change fit user outcome + production path? |
| Deploy/config fit | Platform targets, flavor/env config, Firebase/Supabase wiring, secrets, CI/CD, store/background limits, and rollback path checked? |
| Visual fit | Did I read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md), use runtime source (`AppTheme` / `buildAppMixScope` / `AppStyles` / `UI`), and fit audience/workflow? |
| UI states/layout | Are expected states present, and did mobile/tablet/desktop checks cover clipped text, overlap, unstable controls, hidden primary content? |
| Simplify | Smallest change without speculative abstraction? |
| Security | Auth, replay, retries, logging, secrets, file access, sync, `--dart-define` reviewed? |
| Observability | Stable logs/telemetry/error metadata added only where useful, using repo utilities and no sensitive data? |
| Performance | Rebuild scope, repeated I/O, UI-isolate parsing, polling/listeners, allocations, scale checked? |
| Edge cases | Empty, malformed, repeated, concurrent, offline, resumed, interrupted paths handled? |
| Failure modes | What inputs/conditions fail? Weaknesses? |
| Error handling | Existing pattern + stable error contracts preserved? |
| Dependencies | Existing utilities/packages checked before adding deps? |
| Naming | Names match codebase? |
| Readability | Can next agent/developer understand seams, names, comments, tests, and docs? |
| Operational clarity | Can someone run, verify, debug, and recover from repo artifacts? |
| Execution state | Is plan/checklist/retry/blocker state inspectable instead of hidden in chat? |
| Breakage impact | What breaks first, how is it detected, and what is the recovery path? |
| Tool output | Were empty/truncated/malformed tool results treated as failures to re-check, not proof? |
| Tool choice | Did I use repo tools/MCP/browser/connector evidence when it owns the state, instead of guessing from prompt memory? |
| Tool contract | Are tool inputs, side effects, retry safety, and failure modes explicit enough for future agents? |
| Legibility | Future Codex/Cursor can inspect docs/tests/fixtures/logs/UI proof without chat, with a runnable trigger and stable signal for runtime claims? |
| Confidence | Confidence from proof; uncertainty stated? |
| Focused tests | Scope-matched tests, known client/domain edge cases before integration when practical, async reasoning, no deprecated Flutter test APIs? |
| Judgment | Tradeoff documented; changed surface owned? |
| Scope discipline | Every changed line traces to request or required validation/doc update? |
| Self-verification | Final answer checked against request, files, validation, blockers, risk? |

## AI-Generated-Code Risk Matrix

| Risk | Smell | Fix | Proof |
| --- | --- | --- | --- |
| Injection | string-built SQL/GraphQL/command/HTML | parameterize, allowlist, encode/escape | focused tests + guardrails |
| XSS-style UI injection | unsafe HTML/rendering | avoid raw HTML; sanitize/escape | widget/snapshot proof |
| Secrets | keys/JWTs/DSNs/`sk-`/`AKIA` | remove, secret store, rotate if real | repo scan + CI guard |
| Swallowed errors | broad empty catch | narrow catch, typed error/log, stable contract | tests assert error codes/messages |
| Missing auth/ownership | public mutation/no user scope | auth gate or explicit demo-open decision | route docs + tests |
| Race/concurrency | async overlap, mutable shared state, non-idempotent retry | locks, idempotency, debounce, coalescing | adversarial tests |
| Excess I/O/N+1 | looped network/disk/db | batch/cache/index/offload | perf note/benchmark if needed |
| Deprecated APIs | removed Flutter/SDK calls | update to repo convention | targeted checks |
| Hallucinated deps/APIs | package/helper not verified | prefer existing utility; verify API exists | `pubspec`/lock unchanged unless required |
| Weak tests | mirror implementation | assert behavior/contracts + edge inputs | red/green bug proof |

## Before Accepting AI-Written Code

1. Apply checks above.
2. If vague, define assumptions, system boundaries, data flow, failure handling, success criteria, and smallest verifiable slice.
3. For non-trivial work, define acceptance contract before broad execution; prefer executable specs/tests/fixtures over prose.
4. Re-read related existing features for landmines before trusting generated code.
5. Add or identify edge-case proof first when domain boundaries matter (time, fiscal periods, offline/sync, permissions, retries, locale, scale).
6. Review diff/generated artifacts.
7. Run smallest honest validation via [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).
8. If verifier/critique fails, retry only against concrete evidence; after two loops, replan or report blocker.
9. Self-verify final response vs request, diff, proof, blockers, residual risk.
10. Medium/high risk: prefer extra review pass. Cross-host review only when explicitly requested.

Repeated critique => repo-visible capability: source-doc update, validation check, test helper, fixture, route proof, or task template.

## Special Cases

Dependency changes: justify add/upgrade, check existing deps first, don’t treat `flutter pub get` as validation.

Widget identity:

- Builder rows need stable `Key` from durable id, not index, when list can reorder/filter/insert/delete.
- `AnimatedSwitcher`/mode switches need explicit child identity (`KeyedSubtree`, `ValueKey`, etc.).
- Guardrail: `./tool/check_widget_identity.sh`; suppress only with reason: `// widget_identity:ignore <reason>`.

Bug fix path:

1. reproduce or reason clearly
2. add focused guard
3. implement fix
4. validate narrowed scope

Widget-test viewport:

- Use `tester.view.physicalSize` / `tester.view.devicePixelRatio`.
- Reset with `tester.view.resetPhysicalSize()` / `tester.view.resetDevicePixelRatio()`.
- Don't use deprecated `tester.binding.window` or `TestWidgetsFlutterBinding.window` test-value APIs.

UI/design changes:

- Read root [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md) before theme, typography, spacing, Mix tokens, `AppStyles`, or shared component visuals.
- Runtime source wins: `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`.
- Build real workflow/demo first; avoid marketing/landing pages unless required.
- Prefer complete controls/states over explanatory in-app text.
- Dynamic labels/counters/badges/icons must not resize or overlap layout.
- If [`DESIGN.md`](../DESIGN.md) changes, run `./tool/check_design_md.sh`; if Mix styles/tokens change, run `./tool/run_mix_lint.sh` plus focused widget proof where practical.

Async list builders:

- Don’t index live Cubit/BLoC lists during async refresh.
- Snapshot list at build start, derive `itemCount` from snapshot, guard stale indexes.
- Header rows (`items.length + 1`, `items[index - 1]`) are highest risk.

Hive schema migrations:

- Stored Hive shape changes require [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md), manifest, fingerprints, migrator/tests.
- Review idempotency, failed fingerprint behavior, watch/meta-key noise, temp-key cleanup, per-item salvage.
- Generator is manifest-driven, not automatic schema inference.

## Relationship To Validation

Complements, never replaces: `./bin/router_feature_validate`, `./tool/delivery_checklist.sh` / `./bin/checklist`, `./bin/integration_tests`, targeted format/analyze/test.
