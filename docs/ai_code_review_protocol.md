# AI Code Review Risks and Special Cases

AI code = draft until review gate passes. Use the
[`review/code_review_playbook.md`](review/code_review_playbook.md) for roles,
review sequence, findings, validation, and decision records. This document owns
AI-specific risks and Flutter review special cases.

Before report: apply the playbook's **Scope discipline** and
**Self-verification** requirements; AI must **Self-verify** conclusions against
the request, diff, proof, blockers, and residual risks.

Toolchain: [`tech_stack.md`](tech_stack.md) (pins: [`toolchain_versions.env`](toolchain_versions.env)). Adapted from [Vinod Pal (Mar 2026)](https://medium.com/%40vndpal/my-practical-approach-for-reviewing-ai-generated-code-268db27f3af8).

Pointers: [`agent_knowledge_base.md`](agent_knowledge_base.md) (traps, finish gate) · [`agents_quick_reference.md`](agents_quick_reference.md) · [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) · [`agent_kb/legibility_and_finish_gate.md`](agent_kb/legibility_and_finish_gate.md) (report shape, legibility, response tiers) · [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md) (`./bin/agent-maintain closeout`). Deterministic checklists: [`review/architecture_checklist.md`](review/architecture_checklist.md), [`review/bloc_checklist.md`](review/bloc_checklist.md), [`review/security_checklist.md`](review/security_checklist.md), [`review/performance_checklist.md`](review/performance_checklist.md). Cross-host review only when explicitly requested: `./tool/request_codex_feedback.sh`, `./tool/run_codex_plan_review.sh`.

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

## Special Cases

**Dependencies:** justify add/upgrade; check existing deps; `flutter pub get` ≠ validation.

**Generic abstractions:** type params only for repeated error/parsing/lifecycle/widget contracts; first abstraction feature-local unless cross-feature reuse exists; keep endpoint-specific names, failures, tests, mappers at call site.

**Widget identity:** stable `Key` from durable id (not index) when list reorders/filters; `AnimatedSwitcher` needs explicit child identity (`KeyedSubtree`, `ValueKey`, …). Guardrail: `./tool/check_widget_identity.sh`; suppress: `// widget_identity:ignore <reason>`.

**Bug fix path:** reproduce → focused guard → fix → narrowed validation (see also validation doc § bug-fix).

**Widget-test viewport:** `tester.view.physicalSize` / `devicePixelRatio`; reset with `resetPhysicalSize()` / `resetDevicePixelRatio()` — not deprecated `tester.binding.window` / `TestWidgetsFlutterBinding.window` test-value APIs.

**UI/design:** read [`../DESIGN.md`](../DESIGN.md) + [`design_system.md`](design_system.md) before theme/typography/spacing/Mix/`AppStyles`/shared visuals; runtime source wins (`AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`). Workflow/demo first; complete controls/states; dynamic labels must not break layout. [`DESIGN.md`](../DESIGN.md) edits → `./tool/check_design_md.sh`; Mix → `./tool/run_mix_lint.sh` + widget proof when practical.

**Async list builders:** snapshot list at build start; `itemCount` from snapshot; guard stale indexes; header rows (`length + 1`, `index - 1`) highest risk — never index live Cubit/BLoC lists mid-refresh.

**Hive schema migrations:** shape changes → [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md) + manifest, fingerprints, migrator/tests. Review idempotency, failed fingerprint behavior, watch/meta noise, temp-key cleanup, salvage. Generator is manifest-driven.
