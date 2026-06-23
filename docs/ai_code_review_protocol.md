# AI Code Review Protocol

AI code = draft until review gate passes. **Before report:** self-verify vs request, diff, proof, blockers, residual risks.

Toolchain: Flutter 3.44.3 / Dart 3.12.2. Adapted from [Vinod Pal (Mar 2026)](https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8).

Pointers: [`agent_knowledge_base.md`](agent_knowledge_base.md) (traps, finish gate) · [`agents_quick_reference.md`](agents_quick_reference.md) · [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) · [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md) (report shape, legibility) · [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) (`./bin/agent-maintain closeout`). Deterministic checklists: [`review/architecture_checklist.md`](review/architecture_checklist.md), [`review/bloc_checklist.md`](review/bloc_checklist.md), [`review/security_checklist.md`](review/security_checklist.md), [`review/performance_checklist.md`](review/performance_checklist.md). Cross-host review only when explicitly requested: `./tool/request_codex_feedback.sh`, `./tool/run_codex_plan_review.sh`.

## Builder and Validator

**Builder:** smallest reversible diff (draft). **Validator:** checks below + scope-matched validation + self-verify report ([`AGENTS.md`](../AGENTS.md) § Loop).

## Checks

TDD where practical, lint/build proof, minimal edits, architecture preserved. Avoid giant prompts/rewrites, context flooding, single-agent overload, unverified outputs.

| Check | What to ask |
| --- | --- |
| Draft loop | Draft-first output? Stopped after 1–2 critique cycles → evidence + minimal patch, not regen? |
| Assumptions | False codebase assumptions? Ambiguous scope/data/format/privacy/volume/UX surfaced? |
| System shape | Boundaries, data flow, ownership, failure handling, logs, test seams, rollback clear pre-gen? |
| Prompt shape | Intent / eval / implementation separated; Goal·Context·Boundaries·Verification; no micromanaged steps? |
| Problem fit | Fits user outcome + production path? |
| Modularity | Feature boundary modeled; `Presentation -> Domain <- Data`; no feature leakage? |
| Capabilities | Widgets/services get narrow contracts, not concrete cubits/repos/VMs? |
| Deploy/config | Targets, flavor/env, Firebase/Supabase, secrets, CI/CD, store/background limits, rollback? |
| Visual fit | Read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md); runtime `AppTheme` / `buildAppMixScope` / `AppStyles` / `UI`? |
| UI states | Expected states + mobile/tablet/desktop: clip, overlap, unstable controls, hidden primary? |
| Simplify | Smallest change; no speculative abstraction? |
| Security | Auth, replay, retries, logging, secrets, file access, sync, `--dart-define`? |
| Observability | Stable logs/telemetry/errors only where useful; repo utilities; no sensitive data? |
| Performance | Rebuild scope, repeated I/O, UI-isolate parsing, polling/listeners, allocations, scale? |
| Edge cases | Empty, malformed, repeated, concurrent, offline, resumed, interrupted? |
| Failure modes | What fails; weaknesses documented? |
| Error handling | Existing pattern + stable error contracts preserved? |
| Dependencies | Existing utilities/packages before new deps? |
| Naming | Matches codebase? |
| Shared behavior | Extract duplication only when lifecycle/error/test contracts match; feature-local until proven cross-feature? |
| Readability | Next agent/dev sees seams, names, comments, tests, docs? |
| Operations | Runnable verify/debug/recovery from repo artifacts; inspectable plan/checklist/blockers (not chat-only)? |
| Tool discipline | Empty/truncated tool output = re-check; repo tools/MCP/browser when they own state; explicit tool contracts? |
| Confidence | Proof-backed confidence; uncertainty stated? |
| Focused tests | Scope-matched tests; domain edge cases before integration when practical; no deprecated Flutter test APIs? |
| Judgment | Tradeoff documented; changed surface owned? |
| Scope discipline | Every changed line traces to request or required validation/doc update? |
| Self-verification | Final answer vs request, files, validation, blockers, risk? |

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

1. Apply checks + risk matrix.
2. If vague: assumptions, boundaries, data flow, failure handling, success criteria, smallest verifiable slice.
3. Non-trivial: acceptance contract before broad execution; executable specs/tests/fixtures over prose. Map Feature Brief **Tests** rows (or spec bullets) → `test/` paths in review output.
4. Re-read related features for landmines.
5. Edge-case proof first when domain boundaries matter (time, fiscal, offline/sync, permissions, retries, locale, scale).
6. Review diff/artifacts; run smallest honest validation per [`validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).
7. Verifier fails → retry on concrete evidence; after two loops, replan or report blocker.
8. **Self-verify** final response (request, diff, proof, blockers, risk). Medium/high risk → extra review pass.

Repeated critique without progress → durable repo capability (doc, validation check, test helper, fixture, route proof, task template).

## Special Cases

**Dependencies:** justify add/upgrade; check existing deps; `flutter pub get` ≠ validation.

**Generic abstractions:** type params only for repeated error/parsing/lifecycle/widget contracts; first abstraction feature-local unless cross-feature reuse exists; keep endpoint-specific names, failures, tests, mappers at call site.

**Widget identity:** stable `Key` from durable id (not index) when list reorders/filters; `AnimatedSwitcher` needs explicit child identity (`KeyedSubtree`, `ValueKey`, …). Guardrail: `./tool/check_widget_identity.sh`; suppress: `// widget_identity:ignore <reason>`.

**Bug fix path:** reproduce → focused guard → fix → narrowed validation (see also validation doc § bug-fix).

**Widget-test viewport:** `tester.view.physicalSize` / `devicePixelRatio`; reset with `resetPhysicalSize()` / `resetDevicePixelRatio()` — not deprecated `tester.binding.window` / `TestWidgetsFlutterBinding.window` test-value APIs.

**UI/design:** read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md) before theme/typography/spacing/Mix/`AppStyles`/shared visuals; runtime source wins (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`). Workflow/demo first; complete controls/states; dynamic labels must not break layout. [`DESIGN.md`](../DESIGN.md) edits → `./tool/check_design_md.sh`; Mix → `./tool/run_mix_lint.sh` + widget proof when practical.

**Async list builders:** snapshot list at build start; `itemCount` from snapshot; guard stale indexes; header rows (`length + 1`, `index - 1`) highest risk — never index live Cubit/BLoC lists mid-refresh.

**Hive schema migrations:** shape changes → [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md) + manifest, fingerprints, migrator/tests. Review idempotency, failed fingerprint behavior, watch/meta noise, temp-key cleanup, salvage. Generator is manifest-driven.

## Relationship To Validation

Complements (never replaces): `./bin/router_feature_validate`, `./tool/delivery_checklist.sh` / `./bin/checklist`, `./bin/integration_tests`, targeted format/analyze/test.
