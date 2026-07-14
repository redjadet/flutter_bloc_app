# AI-Native Repository Hardening Plan

> **Build status (2026-07-14):** **Complete** — Waves 1–3 (T1–T8) implemented.

**Goal:** Restore trustworthy AI discovery paths after the Melos monorepo
migration, add freshness gates so drift cannot recur, and tighten compact agent
entrypoints—without new runtime dependencies, host installs, or architecture
rewrites.

**Merge order:** T1 → T2 → T3 → T4. T5 and T6 parallel after T3. T7 after T3
catalog sync. T8 after T2 + T5.

---

## Executive summary

Architecture remains intact. No rewrite.

Current strengths:

- 35 feature modules, package DAG guard, feature-contract gate, task and
  validation routing, root [`AGENTS.md`](../../AGENTS.md), Dart MCP, and optional code graph.
- `bash tool/check_feature_folder_contract.sh` passes.
- `apps/mobile/lib` has 1,255 Dart files and `apps/mobile/test` has 503 tests.

Primary risk: AI discovery snapshots retain pre-Melos paths such as `lib/core`,
`lib/shared`, and old test roots. Repair stale evidence first. Do not add Task
Master, Mason, Very Good CLI, Flutter Lints, filesystem MCP, SQLite MCP, or
memory MCP by default; existing repo tools cover their useful roles with less
host complexity.

## Top 10 improvements

| Priority | Improvement | Why and AI benefit | Effort | Reference |
| --- | --- | --- | --- | --- |
| P0 | Refresh [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) and `ai/reports/*` paths | Stops agents opening deleted locations; restores trustworthy minimal-context packets. | M | Existing repo migration contract |
| P0 | Add AI-snapshot freshness gate | Prevents recurrence: reject obsolete app roots and require generation date, HEAD, and canonical-path links. | S | Repomix-style context hygiene |
| P0 | Tighten `llms.txt` | Add workspace root, app root, package ownership, canonical maps, validation router, and report/canon distinction. | S | Repomix |
| P1 | Make feature map derived and complete | One compact entry per feature: purpose, route, barrel, tests, owner docs, complexity flag. No 35 new READMEs. | M | Flutter Architecture Samples |
| P1 | Add curated Repomix profiles | Safe, token-bounded onboarding and feature-context bundles; exclude generated Dart, caches, secrets, binaries, and historical noise. | S | Repomix |
| P1 | Add dependency-aware work packet | Extend existing feature brief/task tracker with `depends_on`, blocking decision, and merge order. No Task Master runtime or API keys. | S | Task Master |
| P1 | Add GitHub MCP guidance | Read-only-first PR, CI, issue, and release-state inspection; explicit approval remains required for mutations. | S | MCP |
| P1 | Generalize code-graph guidance | Keep local SQLite code graph optional; document host-neutral CLI fallback and freshness behavior. | S | Existing `code-review-graph` |
| P2 | Add complex-feature README standard | Require co-located README only for platform, backend, or async-heavy features; use short template. | M | Flutter Architecture Samples |
| P2 | Add architecture-change evaluator | Diff-scoped check: changed feature retains barrel, route/doc link, tests, and clean layer boundaries. Reuse existing guards. | M | Existing gates |

Do not adopt `dart_code_metrics`: upstream repository archived and package
discontinued. Existing `very_good_analysis`, analyzer, custom lints,
file-size lint, and architecture guards provide concrete value.

## Quick wins

1. Rebase stale AI snapshots to `apps/mobile/lib`, `apps/mobile/test`,
   `packages/*`, `app/composition`, `app/router`, and package-owned
   sync/networking.
2. Update `llms.txt`, [`CODEMAP.md`](../../CODEMAP.md), and [`ai/repo_map.md`](../ai/repo_map.md) into one compact
   retrieval path.
3. Add report metadata: `generated_at`, `git_head`, `app_root`, and
   `canon_links`.
4. Add stale-path checks to docs gardening.
5. Document GitHub MCP read-only workflow and non-recommendations for
   filesystem, SQLite, and memory MCP.

## Medium improvements

### Repomix profiles

Create tracked `tool/repomix/` config files plus `.repomixignore`; store outputs
under ignored `.repomix/`.

- `onboarding` profile: root maps, pubspecs, app shell, package barrels, and
  feature catalog.
- `feature` profile: selected feature, tests, owning docs, DI, and router only.
- Preserve Repomix security checking; exclude `.env*`, generated l10n/Freezed
  files, build caches, vendored code, coverage, and binaries.

### AI report refresh

Replace hand-maintenance with a narrow refresh command using existing
metrics/scans. Validate report metadata and forbidden legacy roots; do not
create a second architecture source of truth.

### Dependency-aware work packet

Extend [`engineering/task_tracker_template.md`](../engineering/task_tracker_template.md) and feature briefs:

- `depends_on`
- `blocks`
- `merge_order`
- `rollback`
- exact proof commands

Task Master's transferable value: next work must have satisfied dependencies
and an explicit test strategy.

### Complex feature docs

Add a concise feature README template. Apply only where integration knowledge
cannot fit in [`feature_overview.md`](../feature_overview.md).

## Long-term improvements

1. Add `check_ai_change_contract` shell script under `tool/` (planned); run for feature, app, package, and
   architectural diffs.
2. Generate the feature catalog from source ownership; avoid manually
   duplicated report data.
3. Add quarterly AI retrieval drill: cold agent completes representative tasks
   using only [`AGENTS.md`](../../AGENTS.md), `llms.txt`, maps, and source links; record unresolved
   paths as defects.
4. Consider a Mason brick only after two additional stable repeated scaffolds
   beyond current `scaffold_feature_contract.sh`.

## AI-native repository recommendations

- Keep root [`AGENTS.md`](../../AGENTS.md) sole cross-host authority.
- Keep hot-path docs pointer-heavy; deep rules remain in owning docs.
- Treat code, tests, docs, ADRs, feature briefs, and validation scripts as
  retrieval memory.
- Preserve `Presentation -> Domain <- Data`, current Melos boundaries, feature
  barrels, route ownership, and existing package DAG.
- Keep current Dart MCP and runtime-error/hot-reload integration.
- Do not create universal agent memory store; repo-owned decisions already have
  durable locations and external memory risks divergence.
- Do not install filesystem MCP: agents already receive workspace-scoped file
  access; extra server adds configuration and authorization surface without
  discovery gain.
- Do not add generic SQLite MCP: code-review graph already uses local SQLite
  behind focused interface.

## Repomix optimisation

- Pack paths, not whole repository, by default.
- Include app shell, selected feature, exact tests, package barrels, owner docs,
  and relevant route/DI files.
- Exclude generated source, `.dart_tool`, platform builds, artifacts, vendored
  packages, secrets, and stale AI reports unless explicitly auditing them.
- Emit XML or Markdown with token counts and file tree; retain outputs locally
  and ignored.
- Add `instructionFilePath` pointing at compact `llms.txt`; use compression
  only for whole-repo structural scans, not normal feature work.

## Task Master-style roadmap

Detailed steps: [Implementation waves](#implementation-waves). PR slicing:
[Suggested PR slicing](#suggested-pr-slicing).

| ID | Task | Why and dependencies | Effort / impact | Acceptance criteria |
| --- | --- | --- | --- | --- |
| T1 | Repair AI discovery artifacts | Depends on current workspace audit. | M / Critical | Zero obsolete app-root references in active maps; all links resolve. |
| T2 | Add snapshot freshness contract | Depends on T1. | S / High | Gate detects old roots, missing metadata, and broken canon links. |
| T3 | Harden compact entrypoints | Depends on T1. | S / High | `llms.txt`, [`CODEMAP.md`](../../CODEMAP.md), [`ai/repo_map.md`](../ai/repo_map.md) agree; no duplicate doctrine. |
| T4 | Add Repomix profiles | Depends on T3. | S / High | Onboarding and scoped-feature packs exclude sensitive/generated noise and stay within documented token budgets. |
| T5 | Add dependency-aware work packet | Independent; reuse current templates. | S / High | Every non-trivial brief states dependencies, blockers, merge order, rollback, and proof. |
| T6 | GitHub MCP operating guide | Independent. | S / Medium | Read-only-first commands, CI/PR evidence path, mutation approval rule documented. |
| T7 | Normalize complex feature docs | Depends on feature catalog. | M / Medium | Only complexity-qualified features gain concise co-located docs; catalog links them. |
| T8 | Add AI-change evaluator | Depends on T2 and T5. | M / High | Diff-scoped guard catches missing barrel/doc/test/boundary evidence without false-failing docs-only changes. |

Merge order: T1 -> T2 -> T3 -> T4. T5 and T6 parallel. T7 -> T8.

## MCP recommendations

| Integration | Decision | Value |
| --- | --- | --- |
| Dart MCP | Keep | Pinned package source, analyzer, DTD runtime errors, hot reload. |
| GitHub MCP | Add guidance; optional install | Faster PR/CI/issue inspection; direct repository-state evidence. |
| Filesystem MCP | Do not add | Native workspace filesystem already scoped; no incremental benefit. |
| SQLite MCP | Do not add | Existing code-review graph gives narrow local graph use case. |
| Documentation MCP / Context7 | Keep optional | Useful only for version-sensitive external APIs after pinned-source inspection. |
| Memory MCP | Do not add | Repo docs/ADRs/tests are source-controlled, reviewable memory; external state duplicates canon. |
| Very Good CLI MCP | Do not add | Experimental; overlaps repo wrappers and current toolchain. |

## Documentation and developer experience changes

- [`README.md`](README.md): retain public/product orientation; link one contributor and agent
  start path rather than adding more detail.
- [`new_developer_guide.md`](../new_developer_guide.md): one first-hour path; point to [`CODEMAP.md`](../../CODEMAP.md) for
  task routing.
- [`feature_overview.md`](../feature_overview.md): canonical feature catalog; generated map
  supplements, never replaces.
- `docs/ai/*`: compact agent navigation only; evidence reports marked
  date/HEAD-scoped.
- Melos: preserve current workspace scripts. Document `dart run melos` commands
  with descriptions and package selectors.
- BLoC: preserve Cubit/BLoC as presentation state management. Existing feature
  contracts and reference features remain primary examples; no migration.

## Validation

- `bash tool/check_feature_folder_contract.sh`
- `bash tool/check_docs_gardening.sh`
- `bash tool/check_agent_knowledge_base.sh`
- New snapshot and Repomix contract checks.
- `./bin/checklist-fast` for docs/tooling slices.
- `./bin/checklist` when validation policy or repo-wide agent rules change.
- Repomix smoke: verify profile contents, token count, ignored secrets/generated
  files, and no tracked output.

## Assumptions

- No code architecture rewrite, dependency addition, host install, or external
  MCP mutation in this program.
- Existing root authority, Melos workspace, package DAG, Dart MCP,
  code-review graph, feature briefs, and validation scripts remain canonical.
- Feature READMEs remain exceptional; catalog/map coverage scales better than
  35 duplicated documents.

---

## Pre-flight audit (2026-07-14)

Evidence captured from the current workspace (`git HEAD 5ec8efd9`, branch
`main`). Re-run this table at PR-A start; generated snapshot metadata, not this
plan, records the implementation commit.

| Check | Result |
| --- | --- |
| `apps/mobile/lib/core/` | **Absent** (deleted in Melos PR-J) |
| `apps/mobile/lib/shared/` | **Absent** (runtime moved to `app/**` + `packages/*`) |
| [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) | **Fully stale** — uses `lib/features/`, `lib/core/`, `lib/shared/`, `test/features/` |
| [`ai/reports/architecture_overview.md`](../../ai/reports/architecture_overview.md) | **Partially stale** — still cites `apps/mobile/lib/core/`, `lib/shared/`, wrong router path |
| [`ai/reports/data_flow_map.md`](../../ai/reports/data_flow_map.md) | **Partially stale** — `shared/sync`, `shared/http`, `core/di` |
| [`ai/reports/dependency_map.md`](../../ai/reports/dependency_map.md) | **Partially stale** — guidance cites deleted roots |
| [`ai/reports/feature_map.md`](../../ai/reports/feature_map.md) | **Mixed** — feature paths mostly correct; test paths still `test/features/` |
| [`ai/reports/README.md`](../../ai/reports/README.md) | **Stale metadata** — generated 2026-05-21; no `git_head` / `app_root` block |
| [`CODEMAP.md`](../../CODEMAP.md), [`ai/repo_map.md`](../ai/repo_map.md) | **Current** — already Melos-aware |
| `llms.txt` | **Thin** — 5 pointers only; missing workspace/app roots and validation router |
| `repomix.config.json` | **Missing** |
| `check_ai_snapshot_freshness` shell script under `tool/` (planned) | **Missing** |
| `refresh_ai_reports` shell script under `tool/` (planned) | **Missing** (manual steps in [`ai/README.md`](../ai/README.md) only) |
| Feature module count | **35** dirs under `apps/mobile/lib/features/` |
| `bash tool/check_feature_folder_contract.sh` | Passes (per plan claim) |

**Conclusion:** Primary gap is **stale AI discovery artifacts**, not missing
architecture. Wave 1 fixes evidence + gates; Wave 2 adds optional tooling
(Repomix, GitHub MCP guide); Wave 3 adds catalog/docs standards and diff guard.

---

## Canonical path contract (post-Melos)

Use this table when rewriting `ai/**` paths. All agent-facing paths should be
**repo-root absolute** (start with `apps/mobile/` or `packages/`).

| Obsolete pattern | Canonical replacement |
| --- | --- |
| `lib/features/<name>/` | `apps/mobile/lib/features/<name>/` |
| `test/features/<name>/` | `apps/mobile/test/features/<name>/` |
| `lib/core/router/` | `apps/mobile/lib/app/router/` |
| `lib/core/di/` | `apps/mobile/lib/app/composition/` |
| `lib/core/di/features/` | `apps/mobile/lib/app/composition/features/` |
| `lib/app/router/` (without `apps/mobile/`) | `apps/mobile/lib/app/router/` |
| `apps/mobile/lib/core/**` | **Deleted** — use `apps/mobile/lib/app/**` or `packages/*` |
| `apps/mobile/lib/shared/sync/` | `apps/mobile/lib/app/sync/` and/or `packages/storage/` |
| `apps/mobile/lib/shared/http/` | `apps/mobile/lib/app/http/` and/or `packages/networking/` |
| `apps/mobile/lib/shared/widgets/` | `packages/design_system/` or feature-local widgets |
| `apps/mobile/lib/core/auth/` | `packages/auth/` (e.g. `remote_backend_auth_port.dart`) |
| `apps/mobile/lib/shared/media/` | `packages/app_shared_flutter/` (media pick types) |

**Package ownership pointer:** [`docs/SHARED_UTILITIES.md`](../SHARED_UTILITIES.md).

---

## Implementation decisions (locked)

Defaults below are accepted for this plan. Revisit only through a plan update;
they do not block Wave 1.

| ID | Decision | Default | Blocks |
| --- | --- | --- | --- |
| D1 | T1 scope: path-fix only vs full metrics refresh | **Path-fix + regenerate metrics sections** via `refresh_ai_reports` under `tool/` | T1 |
| D2 | Repomix install model | **`npx --yes repomix@1.16.1` in script**; no root `package.json` dependency. Bump deliberately in its own PR. | T4 |
| D3 | Repomix token budget caps | **onboarding ≤120k tokens; feature ≤60k** (fail gate if exceeded) | T4 |
| D4 | Complex-feature README criteria | **Any feature with README today + platform/native/backend/async-heavy flag in catalog** | T7 |
| D5 | T8 gate trigger paths | **`apps/mobile/lib/features/**`, `apps/mobile/lib/app/**`, `packages/**`** | T8 |
| D6 | Wire T2 into `./bin/checklist-fast` | **Yes** — call from `run_harness_docs_checks` in `tool/delivery_checklist.sh` and list it in that function's `extra_scripts`. | T2 |

---

## Implementation waves

### Wave 1 — Repair + gate + entrypoints (T1 → T2 → T3)

#### T1 — Repair AI discovery artifacts

##### T1 — Why

Agents currently load deleted `lib/core` / `lib/shared` paths from
[`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) and mixed reports.

##### T1 — Create

- `refresh_ai_reports` shell script under `tool/` (new) — thin wrapper:
  1. Source `tool/workspace_paths.sh`
  2. Run `bash tool/modular_metrics.sh` and `--cross-feature-only` from the
     workspace root; capture stdout as refresh evidence.
  3. Rewrite dated sections in reports (do not duplicate canon prose)
  4. Emit metadata block (see T2 schema) into each updated report + [`ai/reports/README.md`](../../ai/reports/README.md)
  5. Bump `last_refreshed` in [`ai/README.md`](../ai/README.md)

##### T1 — Modify (path + metadata refresh)

- `tool/modular_metrics.sh` — replace its recursive
  `"$APP_ROOT/tool/modular_metrics.sh"` invocation with
  `"$WORKSPACE_ROOT/tool/modular_metrics.sh"`; the current command exits from
  the app root and cannot find `apps/mobile/tool/`.
- [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) — rewrite all pilot paths using [canonical contract](#canonical-path-contract-post-melos)
- [`ai/reports/architecture_overview.md`](../../ai/reports/architecture_overview.md)
- [`ai/reports/data_flow_map.md`](../../ai/reports/data_flow_map.md)
- [`ai/reports/dependency_map.md`](../../ai/reports/dependency_map.md)
- [`ai/reports/feature_map.md`](../../ai/reports/feature_map.md) — fix `Tests` column to `apps/mobile/test/features/...`
- [`ai/reports/context_hotspots.md`](../../ai/reports/context_hotspots.md) — refresh LOC if script output changed
- [`ai/reports/anti_patterns.md`](../../ai/reports/anti_patterns.md) and [`ai/reports/ai_recommendations.md`](../../ai/reports/ai_recommendations.md) — repair
  active path references and metadata when stale
- [`ai/reports/README.md`](../../ai/reports/README.md)
- [`ai/README.md`](../ai/README.md) — point refresh step to `refresh_ai_reports` under `tool/`

##### Do not modify in T1

- [`feature_overview.md`](../feature_overview.md) behavior rows (catalog is canon; only link fixes if broken)
- Long-form [`architecture_details.md`](../architecture_details.md)
- [`ai/reports/FINAL_OPTIMIZATION_REPORT.md`](../../ai/reports/FINAL_OPTIMIZATION_REPORT.md) historical result claims. Mark it
  historical in [`ai/reports/README.md`](../../ai/reports/README.md); do not treat it as current discovery
  guidance or subject it to freshness checks.

##### T1 — Proof

```bash
bash tool/refresh_ai_reports # shell extension added by PR-A
rg -n 'apps/mobile/lib/core/|apps/mobile/lib/shared/' \
  ai/CONTEXT_MAP.md \
  ai/reports/{architecture_overview,data_flow_map,dependency_map,feature_map,context_hotspots,anti_patterns,ai_recommendations}.md
# expect 0 matches
bash tool/check_docs_gardening.sh --paths ai/CONTEXT_MAP.md ai/reports/README.md
```

##### T1 — Acceptance

Zero forbidden legacy roots under `ai/`; all backticked paths
resolve; reports show fresh `generated_at` + `git_head`.

---

#### T2 — AI snapshot freshness contract

##### T2 — Create

- `check_ai_snapshot_freshness` shell script under `tool/` (new)
- `tool/fixtures/harness/ai_snapshot_forbidden_patterns.txt` (new) — one regex per line:

```text
\bapps/mobile/lib/core/
\bapps/mobile/lib/shared/
\b`lib/features/
\b`lib/core/
\b`lib/shared/
\b`test/features/
\b`lib/app/router/app_routes\.dart
```

- docs/validation_scripts/ai_snapshot_freshness.md (new shard — purpose + when to run)

##### T2 — Metadata schema

Required YAML frontmatter at top of [`ai/CONTEXT_MAP.md`](../../ai/CONTEXT_MAP.md) and active discovery
snapshots: [architecture overview](../../ai/reports/architecture_overview.md),
[data flow map](../../ai/reports/data_flow_map.md),
[dependency map](../../ai/reports/dependency_map.md),
[feature map](../../ai/reports/feature_map.md),
[context hotspots](../../ai/reports/context_hotspots.md),
[anti-patterns](../../ai/reports/anti_patterns.md), and
[AI recommendations](../../ai/reports/ai_recommendations.md).

```yaml
---
ai_snapshot:
  generated_at: "2026-07-14T12:00:00Z"
  git_head: "<full git rev-parse HEAD>"
  app_root: "apps/mobile"
  canon_links:
    - docs/architecture_details.md
    - CODEMAP.md
    - docs/feature_overview.md
---
```

##### T2 — Gate rules

1. Fail if any forbidden pattern matches the active snapshots; historical
   reports are excluded only when [`ai/reports/README.md`](../../ai/reports/README.md) labels them historical.
2. Fail if any active snapshot lacks required metadata keys.
3. Fail if `git_head` in metadata differs from current `git rev-parse HEAD`
   when `--strict-head` passed (CI optional; local default off).
4. Fail if any `canon_links` path missing on disk.

##### T2 — Wire

- `tool/check_docs_gardening.sh` — call snapshot check when `ai/**` in scope
- `tool/delivery_checklist.sh` — invoke the snapshot check from
  `run_harness_docs_checks` and add its path to `extra_scripts` (D6), so
  `./bin/checklist-fast` checks active snapshots even during docs-only work
- [`validation_scripts.md`](../validation_scripts.md) + catalog via `tool/fix_validation_docs.sh`
- `tool/run_harness_fixtures.sh` plus a focused invalid-snapshot fixture — prove
  a forbidden path and missing metadata fail the gate

##### T2 — Proof

```bash
bash tool/check_ai_snapshot_freshness # shell extension added by PR-A
./bin/checklist-fast   # when only ai/docs touched
```

##### T2 — Acceptance

Gate fails on injected stale path; passes after T1 refresh.

---

#### T3 — Harden compact entrypoints

##### T3 — Modify

- `llms.txt` — add sections (keep pointer-heavy; no doctrine duplication):

```text
# Workspace
- Root: .
- App package: apps/mobile
- Packages: packages/*

# Start
- AGENTS.md
- CODEMAP.md
- docs/ai/repo_map.md
- docs/agents_quick_reference.md

# Canon vs evidence
- Behavior canon: docs/
- Dated evidence: ai/reports/ (check generated_at + git_head)

# Validation router
- Fast: ./bin/checklist-fast
- Full: ./bin/checklist
- Feature: ./bin/router_feature_validate
```

- [`ai/repo_map.md`](../ai/repo_map.md) — add row for `llms.txt`; state “single compact retrieval path with CODEMAP”
- [`CODEMAP.md`](../../CODEMAP.md) — add row: Agent compact context → `llms.txt`
- [`AGENTS.md`](../../AGENTS.md) — one Map bullet: compact LLM context → `llms.txt` (no prose expansion)

**Consistency rule:** `llms.txt`, [`CODEMAP.md`](../../CODEMAP.md), [`ai/repo_map.md`](../ai/repo_map.md) must
agree on app root, test root, and validation commands. `bash
tool/check_agent_knowledge_base.sh` must pass.

##### T3 — Proof

```bash
bash tool/check_agent_knowledge_base.sh
bash tool/check_ai_snapshot_freshness # shell extension added by PR-A
```

##### T3 — Acceptance

Cold agent can reach app root, validation router, and canon vs
evidence distinction from `llms.txt` alone.

---

### Wave 2 — Context packs + work packets + MCP guides (T4, T5, T6)

#### T4 — Repomix profiles

##### T4 — Create

- `tool/repomix/onboarding.config.json` and `tool/repomix/feature.config.json`
  — tracked profiles; Repomix does not provide repository-local named-profile
  selection, so the wrapper selects one explicit config file
- `.repomixignore`
- `.gitignore` entries: `.repomix/`
- `repomix_pack` shell script under `tool/` (new) — validates the profile/feature name, invokes
  `npx --yes repomix@1.16.1` with the selected config, and writes to
  `.repomix/<profile>-<timestamp>.md`
- `check_repomix_contract` shell script under `tool/` (new) — smoke: run onboarding pack; assert no `.env`, `*.freezed.dart`, `*.g.dart`, `.dart_tool/` in output; token count ≤ budget (D3)
- docs/ai/repomix_profiles.md (new — usage for agents)

##### T4 — Onboarding profile includes

- [`AGENTS.md`](../../AGENTS.md), [`CODEMAP.md`](../../CODEMAP.md), `llms.txt`, [`ai/repo_map.md`](../ai/repo_map.md)
- `apps/mobile/pubspec.yaml`, root `pubspec.yaml` / `melos.yaml`
- `apps/mobile/lib/app/` (composition + router only, not all features)
- `packages/*/lib/*.dart` barrels (not full package trees)
- [`feature_overview.md`](../feature_overview.md)

##### T4 — Feature profile args

- `--feature <snake_case>` → include that feature tree, matching test tree,
  [`CODEMAP.md`](../../CODEMAP.md), feature catalog, `apps/mobile/lib/app/router/`, and
  `apps/mobile/lib/app/composition/`. Do not infer one registrar filename: many
  features share registration groups.

##### T4 — Proof

```bash
bash tool/repomix_pack onboarding # shell extension added by PR-C
bash tool/check_repomix_contract # shell extension added by PR-C
```

##### T4 — Acceptance

Outputs gitignored; secrets/generated excluded; budgets documented.

---

#### T5 — Dependency-aware work packet

##### T5 — Modify

- [`engineering/task_tracker_template.md`](../engineering/task_tracker_template.md) — add sections:

```markdown
## depends_on
- [ ] <task/issue/doc>

## blocks
- <what this work blocks>

## merge_order
- <e.g. T1 before T2>

## rollback
- <revert plan or feature flag>

## proof_commands
- `./bin/checklist-fast`
```

- [`plans/FEATURE_TEMPLATE.md`](FEATURE_TEMPLATE.md) — mirror fields in Feature Brief
- `tool/validate_task_trackers.sh` — preserve backward compatibility for
  existing local-only trackers; validate the new fields only when present.
  Template requirements apply to newly created non-trivial trackers.

##### T5 — Acceptance

Template linted by `bash tool/validate_task_trackers.sh`; the template contains
one filled example block for all fields. Do not modify gitignored host trackers.

---

#### T6 — GitHub MCP operating guide

##### T6 — Create

docs/ai/github_mcp_guide.md

##### T6 — Content (read-only first)

| Operation | Tool pattern | Approval |
| --- | --- | --- |
| PR status / checks | `gh pr view`, `gh pr checks`, GitHub MCP read | None |
| Issue triage | `gh issue view`, list | None |
| Diff / files | `gh pr diff`, MCP file list | None |
| Comment / review / merge | any write | **Explicit user approval same turn** |

- Link configured GitHub MCP capability when available; use `gh` CLI fallback
- Cross-link [`agent_kb/tool_orchestration.md`](../agent_kb/tool_orchestration.md)
- Document **non-recommendations**: filesystem MCP, SQLite MCP, memory MCP (1 paragraph each, pointer to this plan)

##### T6 — Modify

- [`agents_quick_reference.md`](../agents_quick_reference.md) — one row under MCP / external tools
- [`ai/context_loading.md`](../ai/context_loading.md) — Tier for PR/CI evidence

##### T6 — Acceptance

Guide is self-contained; no host config committed.

---

#### T6b — Code-graph guidance (P1, parallel with T6)

##### T6b — Modify (not duplicate)

- [`code_review_graph.md`](../code_review_graph.md) — add “Host-neutral agent path” section:
  - Cursor: optional; prefer `rg` + maps for hot path
  - Codex: `tool/refresh_code_review_graph.sh --if-needed`
  - Freshness: rebuild after large feature moves
- [`agents_quick_reference.md`](../agents_quick_reference.md) — align with existing row

##### T6b — Acceptance

Single doc owns code-graph policy; no second graph doc.

---

### Wave 3 — Catalog standards + diff guard (T7, T8)

#### T7 — Complex feature README standard

##### T7 — Create

docs/architecture/complex_feature_readme_template.md (~40 lines)

##### T7 — Modify

- [`ai/reports/feature_map.md`](../../ai/reports/feature_map.md) — add `complexity: high|standard` column; link README when present
- [`feature_overview.md`](../feature_overview.md) — footnote linking template; list features with co-located READMEs:
  - `native_platform_showcase`, `iot`, `library_demo` (existing)

**Criteria (D4 default):** flag `complexity: high` when any of: platform
channels, FFI, certificate pinning, multi-backend auth, offline-first queue, or
existing co-located README. Do not backfill all high-complexity READMEs; create
one when that feature next changes, unless a missing ownership detail blocks
current work.

##### T7 — Acceptance

Catalog lists complexity; no new README unless criteria met.

---

#### T8 — AI change evaluator

##### T8 — Create

- `check_ai_change_contract` shell script under `tool/` (new)
  - Inputs: `--base <ref>` (default `origin/main` or merge base)
  - If diff touches only `docs/**/*.md` without `apps/mobile` / `packages` → exit 0
  - For a changed feature, require the existing barrel to be present, then
    require a changed test path under `apps/mobile/test/` or explicit
    `Tests: N/A` in its linked change note.
  - Invoke `check_feature_brief_linked.sh`,
    `check_feature_folder_contract.sh`, and
    `check_clean_architecture_imports.sh`; do not parse commit bodies or
    duplicate their boundary rules.

**Deferred by design:** automatic route/DI inference. Existing feature briefs
and router validation own this semantic proof; add a new heuristic only after a
measured recurring miss.

**Wire:** optional CI on PR; local pre-push documented in [`agents_quick_reference.md`](../agents_quick_reference.md)

##### T8 — Acceptance

False-negative test on docs-only PR; catches missing test path on feature edit fixture.

---

## Suggested PR slicing

| PR | Tasks | Risk |
| --- | --- | --- |
| PR-A | T1 + T2 | Low — ai/ + tool scripts |
| PR-B | T3 | Low — entrypoint docs |
| PR-C | T4 | Low — new ignored outputs |
| PR-D | T5 + T6 + T6b | Docs only |
| PR-E | T7 + T8 | Medium — new diff guard |

Run `./bin/checklist-fast` per PR; `./bin/checklist` before merging PR-E if
validation policy files changed.

---

## Definition of done (program)

- [x] `check_ai_snapshot_freshness` shell script passes on clean tree
- [x] Active snapshot scan returns no stale agent paths; historical reports are
  explicitly marked and excluded from discovery routing
- [x] `llms.txt` + CODEMAP + repo_map agree
- [x] Repomix smoke passes budgets
- [x] Task tracker template includes dependency fields
- [x] GitHub MCP + code-graph guides linked from quick reference
- [x] T8 guard documented and tested with harness fixture

---

## Research references

- [Repomix](https://github.com/yamadashy/repomix)
- [Task Master](https://github.com/eyaltoledano/claude-task-master)
- [MCP servers](https://github.com/modelcontextprotocol/servers)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Melos workspace scripts](https://melos.invertase.dev/~218/configuration/scripts)
- [Mason](https://github.com/felangel/mason)
- [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli)
- [Flutter Lints](https://github.com/flutter/packages/tree/main/packages/flutter_lints)
- [Dart Code Metrics status](https://github.com/dart-code-checker/dart-code-metrics)
