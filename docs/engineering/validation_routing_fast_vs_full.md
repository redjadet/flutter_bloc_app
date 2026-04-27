# Validation Routing: Fast vs Full

Entrypoint list: [`docs/agents_quick_reference.md`](../agents_quick_reference.md) (**Commands**).

Defines fast/scoped vs full validation. Supports **Plan, Execute, Verify, Report**.
Pick lane in **Verify**. Report after proof ran or blocker confirmed.

## Fast Path

Use for narrow low-risk edits where routing/auth/gates unchanged.

- Local formatting/lints/tests for touched files
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

## Docs And Agent Guidance Path

Use targeted validation for docs-only repo guidance, workflow docs, and agent-facing files.

Typical path:

- Self-verify final wording against [`AGENTS.md`](../../AGENTS.md), user request, changed docs, blockers, and residual risk before reporting
- Markdown lint or link/doc checks on touched paths
- `bash tool/check_docs_gardening.sh` for cheap deterministic doc-rot detection
- `bash tool/validate_task_trackers.sh` to ensure `tasks/*/todo.md` follows canonical tracker contract
- `./tool/check_agent_asset_drift.sh` when `tool/agent_host_templates/` changed
- `./tool/sync_agent_assets.sh --dry-run` when repo-managed host assets changed

Escalate to `./tool/delivery_checklist.sh` / `./bin/checklist` when docs materially change validation guidance, delivery policy, or repo-wide operating rules (incl [`AGENTS.md`](../../AGENTS.md)).

## Routing Matrix (path triggers)

Routing source of truth. If host prompt/helper script disagrees, this doc wins.

| Trigger (changed files) | Required lane(s) (minimum) |
| --- | --- |
| Docs/tooling only (e.g. `docs/**`, `tool/*.sh`, `bin/*`, `.cursor/**`) | `./bin/checklist-fast` + `bash tool/check_agent_knowledge_base.sh` |
| Routing/auth gates (e.g. `lib/**/router/**`, `AppRoutes`, route guard code, auth UI) | `./bin/router_feature_validate` (+ `./bin/checklist` if wide diff) |
| Offline-first/sync/lifecycle (e.g. `lib/shared/sync/**`, debounce/flush, pending-sync queues, retry/replay behavior) | `./bin/checklist` |
| DI / transport config (e.g. `get_it` wiring, Dio/interceptors, auth headers, retry policies, base URL parsing) | `./bin/checklist` |
| l10n / codegen surfaces (ARB files, generated localization, build_runner outputs) | `./bin/checklist` + run the repo’s documented generation/update step (see [`localization.md`](../localization.md)) |
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

Command:

```bash
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
