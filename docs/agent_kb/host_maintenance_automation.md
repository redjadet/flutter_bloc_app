# Agent maintenance automation (agents)

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

Canon entrypoint: `./bin/agent-maintain` (`tool/agent_maintain.sh`). Cursor: `/agent-maintain`.

Agents **run these steps themselves** (shell), not only document them for the user.
Use `--apply` only when the table allows mutation; host sync/setup/install always
needs a reload hint after `--apply`.

## When to run (mandatory for agents)

| Situation | Command | `--apply` |
| --- | --- | --- |
| **Non-trivial task start** (feature, fix, refactor, multi-file) | `./bin/agent-maintain preflight` | No |
| **Cold session / unclear repo state** | `./bin/agent-maintain preflight` | No |
| **After editing `tool/agent_host_templates/**`** | `./bin/agent-maintain after-host-edit` **in the same turn** (do not defer; `closeout` runs it when templates are in git scope) | **Yes** (agents run; never only tell the user) |
| **After editing [`AGENTS.md`](../../AGENTS.md), [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md), `docs/agent_kb/**`, host scripts, or `bin/agent-maintain`** | `./bin/agent-maintain kb` (also via `closeout` when agent-map is in scope and templates are not) | No |
| **Before claiming any non-trivial task done** | `./bin/agent-maintain closeout` (alias: `auto`) | Host + doc sync from git scope; agents run, never delegate |
| **Before claiming host/docs/tooling work done** (narrow lane) | `./bin/agent-maintain closeout` | Same as above |
| **End of host-only session** (templates + agent docs, no app code) | `./bin/agent-maintain routine` | Optional (`routine --apply`: sync `--apply` + **strict** drift) |
| **User asks: setup Cursor/Codex, install globals, new machine** | `./bin/agent-maintain host-full` | **Yes** (network) |
| **User asks: refresh globals / trim duplicates** | `./bin/agent-maintain update` / `trim` | `trim` needs `--apply` |

Do **not** run `host-full --apply` or `install` unless the user requested host setup or
you are finishing an explicit host-environment task. Prefer `preflight` + scoped `sync --apply`.

## `closeout` / `auto` (scope-based, run before finish)

```bash
./bin/agent-maintain closeout    # preferred name before claiming task done
./bin/agent-maintain auto        # same workflow
```

`closeout` / `auto` runs:

1. `preflight` (bootstrap + drift warn + trackers)
2. **`docs-sync`** when validation tooling or markdown docs are in scope (see below)
3. **`after-host-edit`** only when `tool/agent_host_templates/**` is in git scope (sync `--apply` + strict drift + `kb`) — **not** on every task
4. **`kb`** only when agent-map paths changed **and** templates were not in scope

`closeout` prints `auto_action|...` only for steps it will run, then executes them. Agents must run **`./bin/agent-maintain closeout`** before claiming done; do not run `after-host-edit` when scope is empty.

### Why `closeout` always runs `preflight`

`preflight` is cheap (read-only bootstrap, drift **warn**, task trackers) and re-establishes session context before doc/host steps. Skipping it would let agents claim done without fresh tracker/drift signals. Host/doc mutations still follow scope (`after-host-edit`, `kb`, `docs-sync` only when paths match).

## Doc closeout (`docs-sync`)

Mechanical doc updates agents run **before finish** (included in `closeout`; also `./bin/agent-maintain docs-sync` alone).

| Path pattern | Automated steps |
| --- | --- |
| `tool/delivery_checklist.sh`, `tool/agent_maintain.sh`, `bin/agent-maintain`, `tool/check_*.sh`, `tool/validate_validation_docs.sh`, `tool/fix_validation_docs.sh`, `bin/checklist`, `bin/checklist-fast` | `bash tool/fix_validation_docs.sh` (checklist index block + catalog/overview counts) then `bash tool/validate_validation_docs.sh` |
| `docs/**`, [`AGENTS.md`](../../AGENTS.md), [`README.md`](../../README.md), [`SECURITY.md`](../../SECURITY.md), [`DESIGN.md`](../../DESIGN.md), `llms.txt` | `bash tool/agent_memory_auto_maintain.sh --fix-links` then `bash tool/check_docs_gardening.sh` on changed doc paths |
| [`DESIGN.md`](../../DESIGN.md) | `bash tool/check_design_md.sh` (warn-only on failure if `npx` unavailable) |

Agents still **author** narrative doc content in the same turn; `docs-sync` only applies deterministic sync (indexes, counts, links, validation-doc inventory). If `validate_validation_docs.sh` fails after `fix_validation_docs.sh`, add missing catalog/router entries before claiming done.

### Scope detection (git)

`auto` inspects **staged, unstaged, untracked, and deleted** paths under the repo root.
Template deletes under `tool/agent_host_templates/**` still trigger sync/kb workflows.

| Path pattern | Triggers |
| --- | --- |
| `tool/agent_host_templates/**` | `after-host-edit` via `closeout` or run directly after edits |
| [`AGENTS.md`](../../AGENTS.md), [`agent_knowledge_base.md`](../agent_knowledge_base.md), `docs/agent_kb/**`, listed host docs/scripts, `bin/agent-maintain` | `kb` via `closeout` when templates not in scope |
| `tool/delivery_checklist.sh`, `tool/agent_maintain.sh`, `bin/agent-maintain`, `tool/check_*.sh`, `docs/**` (see doc-closeout table) | `docs-sync` via `closeout` |

### Drift checks

| Command context | Drift behavior |
| --- | --- |
| `preflight`, `auto` (no apply), `sync` dry-run, `routine` (no `--apply`) | Warn + hint (`sync --apply`); exit 0 |
| `sync --apply`, `routine --apply`, `after-host-edit`, `closeout` / `auto` (when templates in scope) | Strict; exit non-zero if still out of sync |

## Composed presets (prefer over hand-built chains)

| Preset | Use |
| --- | --- |
| `preflight` | Session start, task start |
| `routine` / `routine --apply` | Light periodic upkeep |
| `host-full --apply` | Full install + trim (user-owned) |

## Proof and checklist alignment

- Narrow docs/tooling lane: `./bin/checklist-fast` already runs drift when policy docs change.
- After `sync --apply`: tell user to reload Cursor if they use synced commands/rules.
- Validation catalog: [`validation_scripts/operations_host_skills.md`](../validation_scripts/operations_host_skills.md)
- Contract smoke: `tool/check_checklist_cli_contract.sh` (help/list, scope `closeout`, PLAN_ONLY `after-host-edit` + `agent_maintain.sh` docs-sync scope; `AGENT_MAINTAIN_CHANGED_PATHS_FILE` + `AGENT_MAINTAIN_PLAN_ONLY=1` — **tests only**, not for agents)

## Not changed (by design)

Intentional limits — do not “fix” these without an explicit policy change.

| Area | Behavior | Why |
| --- | --- | --- |
| **Contract tests** | `tool/check_checklist_cli_contract.sh` sets `AGENT_MAINTAIN_PLAN_ONLY=1` and optional `AGENT_MAINTAIN_CHANGED_PATHS_FILE`; asserts **plans** (`plan\|after-host-edit\|…`, `plan\|docs-sync\|…`), not live `sync --apply` / `kb` | Real apply mutates `~/.cursor` / global host paths; unsafe in CI and agent sandboxes |
| **`closeout` scope** | Runs `after-host-edit`, `kb`, and `docs-sync` only when matching paths are in git scope; empty tree → `preflight` only (no `after-host-edit`) | App-only tasks must not sync host templates or rewrite unrelated docs |
| **`docs-sync` depth** | Mechanical sync only (`fix_validation_docs`, link gardening, catalog validate); agents still **author** narrative prose | Automation must not invent requirements or architecture text |
| **`check_design_md.sh`** | Warn-only inside `docs-sync` when `npx`/network unavailable | DESIGN brief check is optional lane; must not block link gardening |
| **Drift on read paths** | `preflight`, `closeout` without template apply, `sync` dry-run, `routine` (no `--apply`) → warn + exit 0 | Read-only session start should not fail on stale `~/.cursor` |
| **`routine` inventory** | Budget report only when `skill_inventory_latest.json` exists; never `inventory --enforce` in the preset | Enforcement is opt-in; routine stays low-noise |
| **Cross-host review** | `review` / `request_codex_feedback.sh` not in `closeout` | User-owned, network/cost; explicit ask only |
| **Global install** | `install` / `host-full --apply` not implied by `preflight` or `closeout` | Network + large host mutation; user intent required |
| **Checklist index** | `check_skill_budgets.sh` stays **manual** (not in `./bin/checklist` `CHECK_SCRIPTS`) | Report-only unless operator runs enforce mode |

Full host sync proof after template edits remains **manual** or operator-driven: `./bin/agent-maintain after-host-edit`, reload Cursor, then `sync --dry-run` clean.

## Do not automate

- Cross-host `review` / `codex-feedback` unless user asks.
- `inventory --enforce` in routine loops (report-only unless enforcing budgets).
- Network `install` / `host-full` without explicit user intent.
