# Code-review-graph pilot evidence (2026-07-29)

Status: **FAIL winner gate**. Keep maps + targeted `rg` as default. Do not harden
agent defaults to graph-first. No Codegraph/Graphify/RAG/remote storage added.

Worktree: `../flutter_bloc_app-graph-pilot` branch `codex/graph-pilot`.
Main checkout left untouched.

## Baseline metadata

| Field | Value |
| --- | --- |
| Source revision | `7a1b4017a5e3b10395ed8710a9a9eedb78c56574` |
| Tool | `code-review-graph 2.3.2` (`~/.codex/venvs/code-review-graph`) |
| Graph cache before build | absent |
| Build duration | ~11s (`real 10.82`) |
| DB size after build | ~183M (`.code-review-graph/graph.db`) |
| Indexed files (all langs) | 2556 |
| Nodes / edges | 15645 / 95327 |
| Dart nodes / distinct Dart files | 13935 / 2226 |
| Repo `apps`+`packages` `*.dart` count | 2088 |
| Docs historical counts | 1618 / 10535 / 64888 — **not live**; superseded by this build |

Graph indexes meaningful Dart structure (classes, calls, imports, inherits).
Pilot continued past Phase 0 stop condition.

## Frozen fixtures (CODEMAP + `rg` baseline)

| ID | Area | Seed / question | Baseline files | Baseline bytes |
| --- | --- | --- | --- | --- |
| F1 | Bootstrap/DI | callers of `configureDependencies` | 8 | 50280 |
| F2 | Bootstrap/DI | `registerAuthServices` impact | 5 | 24929 |
| F3 | Router/auth | `auth_redirect` / auth redirect helpers | 3 | 11859 |
| F4 | Router/auth | `AppRouteAuthGate` callers | 8 | 54520 |
| F5 | Sync | `BackgroundSyncCoordinator` (lib) | 11 | 54804 |
| F6 | Sync/retry | `nextRetryAt` / retry scheduling | 13 | 124571 |
| F7 | Shared storage | `HiveRepositoryBase` consumers | 17 | 69441 |
| F8 | Design system | `EpochThemeExtension` consumers | 11 | 46386 |
| F9 | todo_list | `TodoMergePolicy` callers | 4 | 17429 |
| F10 | todo_list | `TodoItemDto` importers | 8 | 81511 |
| F11 | todo_list | `TodoListCubit` impact | 20 | 125408 |
| F12 | todo_list | merge-policy test coverage edge | 2 | 3349 |

Manually verified critical edges (source authority):

- F1: `bootstrap_coordinator.dart` tear-off/assigns `configureDependencies`.
- F2: `register_feature_services.dart` + auth/http registration tests.
- F4: route builders under `routes_*.dart` + `app_route_auth_gate_test.dart`.
- F5: DI `register_sync_services.dart` plus session/app_scope/sync_status consumers.
- F7: feature Hive repos extend `HiveRepositoryBase`.
- F9: `offline_first_todo_repository_impl.part.dart` constructs/holds `TodoMergePolicy`.
- F12: `todo_merge_policy_test.dart` covers `TodoMergePolicy`.

## Graph-first results (MCP `query_graph` / `get_impact_radius`)

Qualified-name queries used after ambiguous short names.

| ID | Best query | Graph files | Critical correctness |
| --- | --- | --- | --- |
| F1 | `callers_of` configureDependencies | 1 (self file only) | **MISS** bootstrap_coordinator |
| F2 | `callers_of` registerAuthServices | 3 | OK vs critical set |
| F3 | `importers_of` auth_redirect.dart | 2 | OK |
| F4 | `callers_of` AppRouteAuthGate | 6 | OK core route sites; missed 1 coverage test vs rg |
| F5 | `callers_of` BackgroundSyncCoordinator | 3 | **MISS** app_scope / session / sync_status consumers |
| F6 | `callers_of` _nextRetryAt | 1 (self) | Weak; private helper not useful |
| F7 | `inheritors_of` HiveRepositoryBase | 16 | OK |
| F8 | `importers_of` epoch_theme_extension.dart | 0 | **MISS** all consumers |
| F9 | `callers_of` TodoMergePolicy | 1 (test only) | **MISS** production part-file usage |
| F9b | `importers_of` todo_merge_policy.dart | 2 | Partial (barrel + test) |
| F10 | `importers_of` todo_item_dto.dart | 6 | OK |
| F11 | `importers_of` todo_list_cubit.dart | 10 | Mostly OK; fewer than rg |
| F12 | `tests_for` TodoMergePolicy | 0 | **MISS** existing unit test |

False positives / noise:

- `callers_of` often returns `File:` nodes and duplicate test hits.
- `get_impact_radius` depth-2 for merge policy returned 44 files including weak/unrelated
  coupling (e.g. counter cubit, realtime market) — high fan-out, low precision.
- Injector impact skewed toward integration_test helpers, not bootstrap coordinator.

Raw-file reduction (files opened if agent trusted graph list only):

- Per-fixture reductions often ≥30% (median ~73% on naive file counts).
- **Invalid for winner gate**: reductions coincide with missed critical edges
  (`without worse correctness` fails).

## Freshness probes (wrapper)

Confirmed in this pilot:

1. `--if-needed` with matching `last_head` **skipped refresh** after dirty edit to
   `injector.dart` (HEAD unchanged). Stale trusted graph possible.
2. Vendor `status --repo` initializes/migrates empty `graph.db` when absent
   (wrapper `--status-only` currently delegates and can create cache).

Rename/delete full-rebuild need remains a design risk; not required to fail the
gate after (1)+(2) plus correctness misses.

## Winner gate

| Criterion | Result |
| --- | --- |
| No missed manually verified critical caller/impact edge | **FAIL** (F1, F5, F8, F9, F12) |
| Dirty/rename/delete/new-file cannot silently retain trusted stale graph | **FAIL** (dirty + `--if-needed`) |
| Median raw source opened −30% without worse correctness | **FAIL** (correctness worse) |

**Decision:** graph remains optional local tooling. Default discovery stays
`CODEMAP` / maps + targeted `rg` + raw reads. Do **not** change harness freshness
semantics or agent defaults in this pass (Phase 2–4 gated off).

## Validation (fail path + freshness follow-up)

- `bash tool/check_docs_gardening.sh`
- `bash tool/check_agent_memory_compounding.sh`
- `bash tool/check_code_review_graph_contract.sh`
- `./bin/checklist-fast --no-reuse` (docs/tool lane when allowlisted)
- `./bin/agent-maintain closeout`
- App analyze/tests — not run (no app code changes)

## Follow-up status

Freshness wrapper harden (same session, still optional graph default):

- [`tool/refresh_code_review_graph.sh`](../../tool/refresh_code_review_graph.sh) —
  dirty worktree never skips on HEAD alone; `--status-only` reports `not built`
  without creating cache; rename/delete forces full rebuild; `refresh_meta`
- [`tool/check_code_review_graph_contract.sh`](../../tool/check_code_review_graph_contract.sh)
- Docs: [`docs/ai/code_review_graph.md`](../../docs/ai/code_review_graph.md),
  ladder + specialist routes + validation catalog

Remaining (optional later): re-pilot fixtures that failed on Dart tear-offs,
part files, package import paths, and `tests_for` before any default-promotion.
