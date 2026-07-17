# Agent Knowledge Base (Details)

Rarely opened. Holds long tables and deeper mechanics referenced by the main [`agent_knowledge_base.md`](agent_knowledge_base.md).
Most day-to-day section bodies live under [`agent_kb/`](agent_kb/).

## System Of Record Layout

| Area | Source | Use when |
| --- | --- | --- |
| Docs index | [`README.md`](README.md) | Find source of truth. |
| Tech stack / entrypoints | [`toolchain_versions.env`](toolchain_versions.env) (machine pins), [`tech_stack.md`](tech_stack.md) (display), [`architecture_details.md`](architecture_details.md) | Flutter/Dart versions and app entrypoints under `apps/mobile/lib/`: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`. |
| Agent harness | [`agent_knowledge_base.md`](agent_knowledge_base.md) | Agent behavior, host templates, trackers, validation. |
| Project-specific AI context | [`agent_project_context.md`](agent_project_context.md) | Pinned versions, package caveats, migration contracts, performance seams, forbidden patterns. |
| Review gate | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) | Accepting AI-written code / final report. |
| Commands | [`agents_quick_reference.md`](agents_quick_reference.md) | Choosing repo entrypoints. |
| Design system | [`../DESIGN.md`](../DESIGN.md), [`design_system.md`](design_system.md) | UI/theme/typography/spacing/component/Mix/visual-state change. |
| Validation routing | [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) | Fast vs full validation. |
| Architecture | [`architecture_details.md`](architecture_details.md), [`clean_architecture.md`](clean_architecture.md), `adr/` | Structure, routing, DI, layers, feature seams. |
| Quality | [`CODE_QUALITY.md`](CODE_QUALITY.md), [`testing_overview.md`](testing_overview.md), [`validation_scripts.md`](validation_scripts.md) | Risk, tests, guardrails. |
| Runtime evidence | [`logging.md`](logging.md), [`observability.md`](observability.md), [`performance/startup_time_profiling.md`](performance/startup_time_profiling.md) | Logs, metrics, traces, startup/runtime measurements, and agent-queryable proof. |
| Lifecycle | [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md) | Async, subscriptions, timers, retry, sync, background work. |
| Code graph | [`code_review_graph.md`](code_review_graph.md) | Narrow non-trivial exploration. |
| Hive migrations | [`offline_first/hive_schema_migrations.md`](offline_first/hive_schema_migrations.md) | Stored Hive shape, manifest/spec, fingerprints, migrators/tests. Runtime `getBox()` runs `ensureSchema` when schema set. |
| Integration journeys | [`engineering/integration_journey_map.md`](engineering/integration_journey_map.md) | End-to-end flow changes. |
| Plans/history | [`plans/README.md`](plans/README.md), [`changes/README.md`](changes/README.md), [`audits/README.md`](audits/README.md) | Active contracts, rationale, historical snapshots. |
| Active trackers | `../tasks/codex/todo.md`, `../tasks/cursor/todo.md` | Current plan/proof. |
| Repeated lessons | [`../tasks/lessons.md`](../tasks/lessons.md) | Durable user corrections. |

## Plans As Artifacts

- Small changes: tracker notes.
- Non-trivial: [`tasks/codex/todo.md`](../tasks/codex/todo.md) or [`tasks/cursor/todo.md`](../tasks/cursor/todo.md) with scope/risks/write set/validation.
- Durable plans: `docs/plans/`; completed rationale: `docs/changes/`; debt: owning doc/ADR/plan.

## Harness Controls

| Control | Examples |
| --- | --- |
| Computational guides | Types, layer boundaries, lint rules, check scripts, route constants. |
| Inferential guides | Source docs, ADRs, feature plans, review protocol, trackers. |
| Computational sensors | `flutter analyze`, targeted tests, `./bin/checklist`, guard scripts. |
| Inferential sensors | AI review gate, risk review, explicit cross-host review. |

Use deterministic sensors first; use inferential review for business fit, edge cases, and architecture.

## Invariant Enforcement

- Enforce layer boundaries, routing reachability, lifecycle cleanup, retry/replay safety, sync behavior, validation routing mechanically where possible.
- Guard-script errors should tell future agents remediation.
- Validation scripts are quality gates. Script edits should **remove false positives** (narrow match/scope, add fixtures, or allowlisted `check-ignore` suppressions with reasons), not weaken invariants via broad exclusions.
- Promote repeated review comments into tests/scripts/ADRs/source docs.
- Surgical diffs. Changed lines trace to request or required validation/doc updates.
- Keep custom checks narrow/reversible; delete/relax stale checks.

## Business logic must be separated from UI (agent rule)

Owner docs: [`clean_architecture.md`](clean_architecture.md),
[`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md),
[`review/architecture_checklist.md`](review/architecture_checklist.md).

**Goal:** keep `build()` and reusable widgets pure rendering. Keep rules and data
shape decisions testable without widget pumps.

### Allowed in UI (widgets/pages)

- Render immutable state + handle user gestures.
- Call cubit methods (`onPressed: cubit.doThing`) and navigate (presentation-only).
- **Pure visual math** (layout sizing, chart bounds, formatting for display).

### Forbidden in UI (widgets/pages)

- **Repository calls** (even via constructor-injected repo) inside widgets/pages.
- Derived business rules in `build()`:
  - filtering/grouping products or entities
  - counting/aggregating domain state
  - “find by id” lookups across domain lists
  - default scheduling windows or date windows used by workflows
- Network/storage/auth decisions in `build()` or reusable widgets.

### Where this logic goes instead

- **Cubit/state** (`presentation/cubit`): derived view data getters (counts,
  filtered lists, lookup helpers), action orchestration, lifecycle guards.
- **Domain** (`domain/`): pure rules/helpers (no Flutter imports), used by cubits.
- **Data** (`data/`): persistence, SDK/HTTP, offline-first/sync.

### Quick detection (scripts)

- `bash tool/check_clean_architecture_imports.sh`
- `bash tool/check_solid_presentation_data_imports.sh`
- `bash tool/check_direct_getit.sh`

### Fix pattern (repeatable)

- Move `.where()/.map()/.reduce()/.sort()` from UI into a state getter.
- Replace widget repo calls with a cubit method (async work stays out of UI).
- If the UI needs defaults (e.g. week start, shift window), extract a **pure
  domain helper** and call it from cubit, not from the widget.

## Codex And Cursor

- Same doctrine. Source docs own behavior; host templates summarize/route.
- Codex: direct repo shell entrypoints, tracker `../tasks/codex/todo.md`.
- Cursor: thin skills/commands, tracker `../tasks/cursor/todo.md`.
- Shared behavior changes start in owning source doc, then `tool/agent_host_templates/`, then `./bin/agent-maintain after-host-edit` (or `./tool/sync_agent_assets.sh --apply`). Agents: `preflight` at start, `closeout` before done. See [`agent_kb/host_maintenance_automation.md`](agent_kb/host_maintenance_automation.md).
- Cross-host review explicit-request-only; never replaces own review/validation/self-check.
- Host prompts stay short: slice, constraints, files, validation, report fields.

## Multi-Agent Hub

Cursor uses hub-and-spoke `Task`s only when team improves quality/speed/risk. Main chat = **Coordinator**; bounded `Task`s = **Specialists**.

### Benefit gate

Use team when >=2 indicators: blast radius, cross-layer read, high-risk logic (auth/sync/migrations/routing gates), separate implement/review bars, or user asked plan+implement+verify. Use single for small/local/mechanical. Tie-break: **single**.

Record one branch in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md):

```text
Benefit: team - short reason
Benefit: single - short reason
```

Trivial may use `trivial - gate skipped`. Non-trivial = multi-step delivery, runtime behavior, DI/sync/routes/codegen, unknown blast radius, plan+implement+verify, or anything gate could reasonably send to team.

### Coordinator

- Owns phase, artifacts, validation, tracker.
- `single`: Plan -> Execute -> Verify -> Report; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` with goal, findings, plan, diff-summary/diff, and review markdown artifacts.
- Spawn with inline context; never path-only when upstream content required.
- Serialize dependent phases; invalidate downstream artifacts after replan.
- Max two Implementer fix loops unless user extends.

### Specialists

- **Researcher** (`explore`, read-only): facts, sources, confidence, stale-risk.
- **Analyst** (`explore`, read-only): write set, risks, validation plan, exact codegen commands/paths.
- **Implementer** (`generalPurpose`): plan-scoped edits only.
- **Reviewer** (`code-reviewer`, optional `ce-*`): findings only; coordinator validates.

Every spawn: paste goal + canon excerpts + upstream artifacts inline; return summary + final result + verified artifacts only (no transcript dumps). Redact tokens/cookies/secrets. No specialist-to-specialist comms.

### Repo-sensitive role matrix

Analyst lists, Implementer respects, Reviewer checks when touched:

- DI/`get_it`: registration, scope, disposal, wiring.
- Dio/HTTP/auth: interceptors, replay, error mapping, token/header flow, storage boundary.
- Routes/l10n/codegen: exact commands + generated paths.
- Offline-first/sync: dedupe, debounced resume, no overlapping flush, idempotency, user scope.
- Hive migrations: manifest-driven, not semantic diff detection. Runtime `getBox()` runs `ensureSchema` when schema set; shape changes still require manifest spec bump, fingerprints, migrator/tests.
- Render/FastAPI/deploy: env contract, timeout, auth assumptions; never leak secrets.
