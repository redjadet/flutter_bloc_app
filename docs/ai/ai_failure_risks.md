# AI Failure Risks

Cursor and Codex agents use this register before broad feature, architecture,
testing, validation, or host-harness work. Goal: prevent mistakes through owner
docs and scripts, then recover with minimal rollback when a mistake lands.

## Pre-Flight (non-trivial work)

Run before first edit when the task touches app code, harness docs, host
templates, validation scripts, or architecture policy:

1. Read this register; map the task to [Minimum proof by task](#minimum-proof-by-task).
2. `./bin/agent-maintain preflight` (bootstrap, drift, trackers).
3. Invoke `agents-common-pitfalls` — pitfall → risk ID map in that skill.
4. Route skills via [`skill_routing.md`](skill_routing.md); load owner docs only
   ([`context_loading.md`](context_loading.md)), not whole feature trees.
5. Before claiming done: match detection scripts for every risk row that applies;
   run [`harness_scorecard.md`](harness_scorecard.md) gates when claiming harness
   completeness; follow [`harness_auto_maintenance.md`](harness_auto_maintenance.md)
   when harness paths are in scope.

Detection paths below use `bash ../../tool/...` (relative to `docs/ai/`). From repo
root, run `bash tool/...` instead.

## Priority

| Tier | When | Risk IDs |
| --- | --- | --- |
| P0 — stop before edit | Secrets, destructive ops, SDK/framework mutation, new feature without brief, wrong layer on new code | `RISK-SECRET-LEAK`, `RISK-DESTRUCTIVE-SIDE-EFFECT`, `RISK-FLUTTER-SDK-MUTATION`, `RISK-FEATURE-BRIEF-SKIP`, `RISK-ARCH-LAYER` |
| P1 — during implementation | Async, offline, seams, BLoC, tests, platform scope, false “done” | `RISK-ASYNC-LIFECYCLE`, `RISK-OFFLINE-OVERWRITE`, `RISK-INTEGRATION-SEAM`, `RISK-BLOC-DIVERGENCE`, `RISK-TEST-GAP`, `RISK-PLATFORM-SCOPE`, `RISK-VALIDATION-SHORTCUT`, `RISK-SECURITY-GAP` |
| P2 — session hygiene | Host/docs/context/API/UI/harness drift | `RISK-HOST-DRIFT`, `RISK-DOC-DRIFT`, `RISK-HARNESS-SCORE-DROP`, `RISK-CONTEXT-OVERLOAD`, `RISK-STALE-API`, `RISK-UI-REGRESSION` |

## Risk Register

| ID | Failure risk | Prevention | Detection | Recovery |
| --- | --- | --- | --- | --- |
| RISK-ARCH-LAYER | Agent puts code in wrong Clean Architecture layer or bypasses domain contracts | Read [`../clean_architecture.md`](../clean_architecture.md) § Architecture skeleton, [`../architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md), [`../architecture/reference_features.md`](../architecture/reference_features.md), and [`../architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md); use `agents-feature-delivery` | `bash ../../tool/check_clean_architecture_imports.sh`; `bash ../../tool/check_feature_folder_contract.sh`; `bash ../../tool/check_feature_modularity_leaks.sh`; review [`../review/architecture_checklist.md`](../review/architecture_checklist.md) | Move type to owner layer; add mapper/port; rerun checklist |
| RISK-PRES-LOGIC-IN-UI | Agent embeds business logic in widgets/pages (filtering, counting, lookup-by-id, repo calls in UI) | Read [`../clean_architecture.md`](../clean_architecture.md) (“keep `build()` pure”) + [`../architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) (“leaf widgets take data+callbacks”) + [`../review/architecture_checklist.md`](../review/architecture_checklist.md) forbidden patterns | `bash ../../tool/check_solid_presentation_data_imports.sh`; `bash ../../tool/check_direct_getit.sh`; focused widget/cubit tests on derived getters | Move derived logic to `presentation/cubit` state getters; move async/repo work to cubit; extract pure domain helper when rules needed |
| RISK-ASYNC-LIFECYCLE | Cubit emits after `close()`, leaked subscriptions/timers, or UI uses `context` after `await` without `mounted` | `agents-canonical-rules-async`; [`../bloc_standards.md`](../bloc_standards.md); `agents-bloc-standards` | Focused cubit/widget tests; `./tool/analyze.sh`; [`../review/bloc_checklist.md`](../review/bloc_checklist.md) async rows | `close()` cancels subs; `isClosed` before emit; `mounted` guards; rerun focused tests |
| RISK-OFFLINE-OVERWRITE | Remote refresh overwrites newer local/offline-pending state | [`../offline_first/adoption_guide.md`](../offline_first/adoption_guide.md); `agents-shared-patterns` | Offline/sync unit tests; review merge and request-id policy | Preserve pending local; coalesce in-flight; rerun sync tests |
| RISK-INTEGRATION-SEAM | Feature lands without DI, routes, l10n, or codegen registration | `agents-feature-delivery` wire-DI rule; [`../feature_implementation_guide.md`](../feature_implementation_guide.md) | `./tool/analyze.sh`; grep DI/router/l10n registration; widget smoke | Register deps/routes/l10n; run codegen; hot restart when DI/native touched |
| RISK-BLOC-DIVERGENCE | Two agents create incompatible Cubit/BLoC state patterns | Read [`../bloc_standards.md`](../bloc_standards.md); use `agents-bloc-standards` | Focused cubit/widget tests; `./tool/analyze.sh`; review [`../review/bloc_checklist.md`](../review/bloc_checklist.md) | Refactor state to standard shape; add missing loading/error/stale async tests |
| RISK-FEATURE-BRIEF-SKIP | Agent starts non-trivial feature work without tests and scope contract | Run `bash ../../tool/scaffold_feature_contract.sh --name <feature>`; fill feature brief first | `bash ../../tool/check_feature_brief_linked.sh`; `./bin/checklist` | Add linked brief/change note with tests; split broad work if scope is unclear |
| RISK-TEST-GAP | Agent claims done with no executable proof for behavior change | Use [`../testing/matrix_required_by_change.md`](../testing/matrix_required_by_change.md) | Focused `flutter test <paths>`; `./bin/checklist`; CI coverage gate | Add missing unit/cubit/widget/integration test or explicit `Tests: N/A - <reason>` |
| RISK-HOST-DRIFT | Cursor/Codex host assets diverge from repo source | Edit only `tool/agent_host_templates/**` or root [`AGENTS.md`](../../AGENTS.md) source; run after-host edit | `bash ../../tool/check_agent_asset_drift.sh`; `./bin/agent-maintain closeout` | `./bin/agent-maintain after-host-edit`; reload Cursor |
| RISK-DOC-DRIFT | New durable rule lands only in chat, not owner docs | Land rule in owner doc plus `docs/changes/` or [`decision_log.md`](decision_log.md) | `bash ../../tool/check_agent_knowledge_base.sh`; `bash ../../tool/check_docs_gardening.sh --paths <docs>` | Add owner doc entry; link from index/map; rerun closeout |
| RISK-HARNESS-SCORE-DROP | Harness wiring breaks; agents claim max score without gates | [`harness_auto_maintenance.md`](harness_auto_maintenance.md); `./bin/agent-maintain harness-maintain`; `./bin/agent-maintain closeout` when harness scope | `bash ../../tool/check_harness_scorecard_gate.sh`; `bash ../../tool/check_ai_failure_risk_register.sh`; `scope_has_harness_edits` in closeout | Fix owner docs/skills/scripts; `after-host-edit` when templates touched; change note |
| RISK-CONTEXT-OVERLOAD | Agent loads stale or excessive context and misses current owner files | Start with [`AGENTS.md`](../../AGENTS.md), [`context_loading.md`](context_loading.md), and [`skill_routing.md`](skill_routing.md) only | `./bin/agent-maintain preflight`; task tracker context section | Reset context ladder; reopen owner docs; summarize before editing |
| RISK-FLUTTER-SDK-MUTATION | Agent patches core Flutter/Dart SDK, framework, or toolchain cache files instead of repo-owned app code | Treat `/Users/ilkersevim/Flutter_SDK/flutter/**`, Flutter framework sources, Dart SDK sources, and toolchain caches as read-only; fix app code, add repo adapter/workaround, or use documented dependency/toolchain upgrade flow | Review changed paths before edits/commit; `git status --short`; if needed `git -C /Users/ilkersevim/Flutter_SDK/flutter status --short` | Stop; do not build on SDK edits; restore SDK/toolchain from clean source with user approval, then patch repo-owned code |
| RISK-SECRET-LEAK | Agent commits key, token, private endpoint, or printed secret | Use [`../security_and_secrets.md`](../security_and_secrets.md); never print secret values | `./tool/check_tracked_secret_literals.sh`; `./tool/check_ai_generated_code_smells.sh` | Remove secret; rotate externally; add placeholder/env doc; rerun security checks |
| RISK-SECURITY-GAP | Auth, payments, PII, or data mutation without security review | [`../review/security_checklist.md`](../review/security_checklist.md); [`../security_and_secrets.md`](../security_and_secrets.md) | Secret/smell scripts; security checklist pass; focused denial-path tests | Fix authz boundary; redact logs; add permission tests |
| RISK-DESTRUCTIVE-SIDE-EFFECT | Agent runs destructive command, external mutation, or deploy without confirmation | Current-turn confirmation with affected items first | Review shell history/diff; no silent deploys | Stop; report affected state; restore from git or documented backup path |
| RISK-STALE-API | Agent uses stale package/platform/API assumptions | MCP package docs + pinned lockfile before editing — [`../agent_kb/package_docs_mcp.md`](../agent_kb/package_docs_mcp.md) | Analyzer/tests; dependency compatibility guard | Patch to pinned API; update docs when version rule changes |
| RISK-PLATFORM-SCOPE | Agent ships shared UI/platform change for one target only (e.g. iOS-only layout, web-unsafe import, tablet/desktop untested) | [`../tech_stack.md`](../tech_stack.md) § Supported platforms; [`design_system.md`](../design_system.md) § Cross-platform form factors; `flutter-cross-platform-modern`; isolate IO in data/shared adapters | `check_sync_io_in_presentation.sh`; web/integration preflight when routing/bootstrap touched; widget tests at mobile + wide widths | Add `kIsWeb`/adapter gate; fix imports; prove mobile/tablet/web/desktop form factors |
| RISK-UI-REGRESSION | Agent changes UI without design or responsive proof | Read [`DESIGN.md`](../../DESIGN.md) and [`../design_system.md`](../design_system.md) § Reusable widgets + § Responsive layout; `LayoutBuilder`/`MediaQuery` when suitable; extract previewable/testable leaf widgets | Widget tests at compact width + text scale when layout branches; `@Preview` or layout checks | Fix layout/theme/l10n; hot reload active session when available |
| RISK-VALIDATION-SHORTCUT | Agent reports success from reused or partial checks when fresh proof is needed | Use scorecard gate in [`harness_scorecard.md`](harness_scorecard.md) | `bash ../../tool/check_harness_scorecard_gate.sh`; `./bin/checklist-fast --no-reuse` or `./bin/checklist`; `git diff --check` | Rerun correct lane; report skipped checks honestly |

## Minimum proof by task

| Task type | Required proof |
| --- | --- |
| Harness/docs/rules | [`harness_auto_maintenance.md`](harness_auto_maintenance.md); `bash ../../tool/check_ai_failure_risk_register.sh`; `bash ../../tool/check_harness_scorecard_gate.sh`; `./bin/agent-maintain harness-maintain`; `./bin/checklist-fast --no-reuse`; `./bin/agent-maintain closeout` |
| Feature architecture | `bash ../../tool/check_clean_architecture_imports.sh`; `bash ../../tool/check_feature_folder_contract.sh`; `bash ../../tool/check_feature_modularity_leaks.sh`; `bash ../../tool/check_feature_brief_linked.sh`; focused tests |
| BLoC/Cubit | Focused cubit/widget tests; `./tool/analyze.sh`; [`review/bloc_checklist.md`](../review/bloc_checklist.md); `agents-bloc-standards` |
| Offline/sync | [`offline_first/adoption_guide.md`](../offline_first/adoption_guide.md); sync unit tests; `agents-shared-patterns` |
| Auth/security/PII | [`review/security_checklist.md`](../review/security_checklist.md); `./tool/check_tracked_secret_literals.sh`; denial-path tests |
| Host template | `./bin/agent-maintain after-host-edit`; `bash ../../tool/check_agent_asset_drift.sh`; reload Cursor |
| App UI | All supported platforms (mobile, tablet, web, desktop) when change is shared ([`tech_stack.md`](../tech_stack.md), [`design_system.md`](../design_system.md) § Cross-platform form factors); focused widget tests; responsive/no-overlap proof; hot reload when active session exists |

## Update Rule

When the same AI failure repeats, add or strengthen a repo capability:

- script gate when deterministic
- fixture when script behavior matters
- owner doc when policy matters
- host skill/routing entry when agents must recall it
- change note when future agents need rationale
