# Validation Routing: Fast vs Full

Entrypoint list: [`docs/agents_quick_reference.md`](../agents_quick_reference.md) (**Commands**).

Defines fast/scoped vs full validation. Supports **Plan, Execute, Verify, Report**.
Pick lane in **Verify**. Report after proof ran or blocker confirmed.

## Fast Path

Use for narrow low-risk edits where routing/auth/gates unchanged.

- Local formatting with `./bin/format --changed`, lints, and tests for touched files
- Optional targeted regression tests
- **Python only** (`demos/render_chat_api/**`, repo `tool/*.py`): `./tool/check_pyright_python.sh` (Pyright + config guard; bootstraps `demos/render_chat_api/.venv` when missing). For behavior proof, `cd demos/render_chat_api && python -m pytest`. Full gate still includes this script via `./tool/delivery_checklist.sh` / `./bin/checklist`.
- **Checklist local sanity shortcut**: `./bin/checklist-fast` for clean-tree local sanity or narrow docs/tooling change sets only. It skips app-wide Flutter validation and refuses CI or app/runtime diffs.

## Scoped Router/Auth Path

Use `./bin/router_feature_validate` when changes touch:

- `lib/app/router/**`
- `lib/core/router/**`
- feature presentation gate/auth/sign-in/login/register pages or widgets

Command:

```bash
./bin/router_feature_validate
```

## Full Path

Use for broad, medium/high-risk, or pre-ship changes.

Typical triggers:

- shared architecture or dependency-injection changes
- offline-first sync, retry, lifecycle, or reliability work
- changes that span multiple features or shared infrastructure
- changes where smallest honest proof is broader than single focused test

Command (wrapper and canonical script are equivalent):

```bash
./bin/checklist
# or
./tool/delivery_checklist.sh
```

Local fast sanity shortcut:

```bash
./bin/checklist-fast
```

## Melos workspace (migration)

During the Melos monorepo migration ([#437](https://github.com/redjadet/flutter_bloc_app/pull/437)):

- **Authoritative full gate** remains `./bin/checklist` / `./tool/delivery_checklist.sh` from **repo root**. Scripts resolve `apps/mobile` via `tool/workspace_paths.sh`.
- **Scoped app work** — `./tool/analyze.sh` or `cd apps/mobile && flutter test <paths>` for narrow UI/package-consumer proof; escalate to `./bin/checklist` when shared packages, DI, routing, or workspace scripts change.
- **Package-only edits** under `packages/*` — app-hosted widget tests in `apps/mobile/test/` remain the honest proof lane until isolated `dart test` in packages is stable (see migration plan PR-C learnings).
- **Melos** — `dart run melos bootstrap` from repo root after `pubspec.yaml` / workspace member changes.

Routing matrix paths below still use `lib/**` shorthand; during migration the app tree is `apps/mobile/lib/**`.

## Docs And Agent Guidance Path

Use targeted validation for docs-only repo guidance, workflow docs, and agent-facing files.

Typical path:

- Self-verify final wording against [`AGENTS.md`](../../AGENTS.md), user request, changed docs, blockers, and residual risk before reporting
- Markdown lint or link/doc checks on touched paths
- `bash tool/check_docs_gardening.sh` for cheap deterministic doc-rot detection
- `bash tool/validate_task_trackers.sh` to ensure `tasks/*/todo.md` follows canonical tracker contract
- `./tool/check_design_md.sh` when root [`DESIGN.md`](../../DESIGN.md) changed
- Agents before finish: `./bin/agent-maintain closeout` (scope-based; `after-host-edit` only when `tool/agent_host_templates/**` in git scope)
- Intentional limits (PLAN_ONLY contract tests, no live host apply in CI, scope-gated `docs-sync`): [`host_maintenance_automation.md`](../agent_kb/host_maintenance_automation.md#not-changed-by-design)
- `./bin/agent-maintain after-host-edit` when `tool/agent_host_templates/**` changed (or `./tool/sync_agent_assets.sh --apply` + strict drift)
- `./bin/agent-maintain kb` or `./tool/check_agent_knowledge_base.sh` when [`AGENTS.md`](../../AGENTS.md), `docs/agent_kb/**`, or [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md) changed
- `./tool/sync_agent_assets.sh --dry-run` when previewing host asset copies without `agent-maintain`

Escalate to `./tool/delivery_checklist.sh` / `./bin/checklist` when docs materially change validation guidance, delivery policy, or repo-wide operating rules (incl [`AGENTS.md`](../../AGENTS.md)).

## Routing Matrix (path triggers)

Routing source of truth. If host prompt/helper script disagrees, this doc wins.

| Trigger (changed files) | Required lane(s) (minimum) |
| --- | --- |
| Docs/tooling only (e.g. `docs/**`, `llms.txt`, `tool/*.sh`, `bin/*`, `.cursor/**`) | `./bin/checklist-fast` + `bash tool/check_agent_knowledge_base.sh`; agents: `./bin/agent-maintain closeout` before claiming done |
| Feature code under `lib/features/**` (non-trivial / cross-layer) | `bash tool/check_feature_brief_linked.sh` (fails by default; `FEATURE_BRIEF_CHECK_STRICT=0` to warn) + `bash tool/check_feature_folder_contract.sh` (use `--strict` for new features) + focused `flutter test`; `./tool/run_file_length_lint.sh` when touching large `lib/` files; `./bin/checklist` if wide |
| UI/design brief or design-system code ([`DESIGN.md`](../../DESIGN.md), [`design_system.md`](../design_system.md), `lib/core/theme/**`, `lib/shared/design_system/**`) | `./tool/check_design_md.sh` when [`DESIGN.md`](../../DESIGN.md) changed; `./tool/run_mix_lint.sh` when Mix tokens/styles changed; focused widget/app-visible proof when runtime UI changed |
| Routing/auth gates (e.g. `lib/**/router/**`, `AppRoutes`, route guard code, auth UI) | `./bin/router_feature_validate` (+ `./bin/checklist` if wide diff). Full checklist also runs `./bin/router_feature_validate` when changed files match `.cursor/rules/router-feature-validation.mdc` globs (`CHECKLIST_SKIP_ROUTER_VALIDATE=1` to skip). |
| Presentation navigation in domain/data, presentation `dart:io` *Sync, image cache hints, cubit subscription hygiene | `./bin/checklist` (fail: `check_navigation_outside_presentation.sh`, `check_sync_io_in_presentation.sh`, `check_remote_image_cache_hints.sh`, `check_cubit_subscription_cancel.sh`). Theme map: `CHECKLIST_EXPLAIN_THEMES=1`. Deferred gates: [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md). |
| Offline-first/sync/lifecycle (e.g. `lib/shared/sync/**`, debounce/flush, pending-sync queues, retry/replay behavior) | `./bin/checklist` |
| DI / transport config (e.g. `get_it` wiring, Dio/interceptors, auth headers, retry policies, base URL parsing) | `./bin/checklist` |
| l10n / codegen surfaces (ARB files, generated localization, build_runner outputs) | `./bin/checklist` + run the repo’s documented generation/update step (see [`localization.md`](../localization.md)) |
| iOS native / CocoaPods embed / simulator build (`ios/**`, `Podfile`, pod frameworks, launch-time dyld errors) | `flutter build ios --simulator --debug` + `tool/check_ios_pod_framework_embed.sh --require-built-app`; `./bin/checklist` also runs the guard opportunistically when a simulator app is already built |
| Apple debug Hive / secure storage (`lib/shared/platform/secure_secret_storage.dart`, `lib/shared/storage/hive_*.dart`, simulator Keychain -34018, `Recovering corrupted box.`) | `bash tool/check_apple_debug_hive_storage.sh` + `flutter test test/secure_secret_storage_test.dart test/shared/storage/hive_key_manager_test.dart`; triage: [`apple_debug_hive_storage.md`](apple_debug_hive_storage.md); `./bin/checklist` includes the guard |
| Integration journeys / end-to-end flows | `./bin/integration_tests` (plus the narrowest supporting lane) |
| Backend-adjacent demos/scripts (e.g. `demos/**`, `demos/render_chat_api/**`, Python lanes, `supabase/**`) | `./bin/checklist` |

## Local Tooling Path

Use checklist's built-in tooling fast path for local shell/checklist/validation-doc work when every changed file stays inside `tool/*.sh`, `bin/*`, repo-managed host templates, or validation-guidance docs.

Behavior:

- `./bin/checklist` / `./tool/delivery_checklist.sh` still runs shell syntax checks, doc-link normalization, validation-doc sync, and agent-asset drift checks when relevant
- it skips app-wide Flutter dependency, analyze, validator-suite, and coverage work for that narrow local-only change set
- CI doesn't use this fast path
- `./bin/checklist-fast` exposes same narrow local path explicitly and also supports clean-tree local sanity runs; it refuses CI and broader app/runtime diffs

## Integration Path

Use for integration-covered workflows, release-candidate lanes, and upgrade lanes.

Use `./bin/integration_preflight` first when you want the cheapest honest proof
for browser/bootstrap seams (web-safe imports, fake Firebase bootstrap, log
filter scoping, or generated SwiftPM patch drift) before the full device suite.

Command:

```bash
./bin/integration_preflight
./bin/integration_tests
```

Optional full upgrade lane:

```bash
./bin/upgrade_validate_all
```

## Production-Failure Path

For hotfixes and reliability defects, validate narrowed failure first, then
add smallest broader gate that honestly covers blast radius. Aligns with
**Bug-fix path** in [`ai_code_review_protocol.md`](../ai_code_review_protocol.md#special-cases)
(reproduce → guard → fix → validate), extended here with when to escalate to
`./tool/delivery_checklist.sh` / `./bin/checklist`.

Default order:

1. Reproduce or reason clearly about failure.
2. Add focused guard or regression proof.
3. Run targeted validation for changed surface.
4. Add `./tool/delivery_checklist.sh` / `./bin/checklist` when failure touches shared infrastructure,
   lifecycle, routing, sync, retries, or other broad surfaces.
