# Agent Knowledge Base (Details)

Rarely opened. Holds long tables and deeper mechanics referenced by the main [`agent_knowledge_base.md`](agent_knowledge_base.md).
Most day-to-day section bodies live under [`agent_kb/`](agent_kb/).

## System Of Record Layout

Primary need→source routing:
[`agent_project_context.md`](agent_project_context.md) § High-Value Sources.

Harness / history rows that stay here:

| Area | Source | Use when |
| --- | --- | --- |
| Docs index | [`README.md`](README.md) | Find source of truth. |
| Agent harness | [`agent_knowledge_base.md`](agent_knowledge_base.md) | Agent behavior, host templates, trackers, validation. |
| Review gate | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) | Accepting AI-written code / final report. |
| Commands | [`agents_quick_reference.md`](agents_quick_reference.md) | Choosing repo entrypoints. |
| Code graph | [`code_review_graph.md`](ai/code_review_graph.md) | Narrow non-trivial exploration. |
| Integration journeys | [`engineering/integration_journey_map.md`](engineering/integration_journey_map.md) | End-to-end flow changes. |
| Plans/history | [`plans/README.md`](plans/README.md) (local/gitignored working plans), [`changes/README.md`](changes/README.md), [`audits/README.md`](audits/README.md) | Plan routing stub, shipped rationale, historical snapshots. |
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

Owner: [`agent_kb/multi_agent_hub.md`](agent_kb/multi_agent_hub.md)
(benefit gate, Coordinator/Specialists, role matrix).
