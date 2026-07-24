# Agent runtime memory candidate v1 — `keep_legacy`

**Date:** 2026-07-23 → 2026-07-24
**Plan (local, gitignored):** [`docs/plans/2026-07-23_meterless_equivalent_agent_runtime_memory.md`](../plans/2026-07-23_meterless_equivalent_agent_runtime_memory.md)
**Transcript:** [Meterless runtime memory](e3c4fd4c-9948-4a47-8bb6-2c504556b965)

## Verdict

| Field | Value |
| --- | --- |
| Machine decision | `keep_legacy` |
| Operator | Accepted |
| `candidate_v1` | **Rejected** |
| Task 12 cutover | **Permanently skipped** for v1 |
| Active AI-agent memory runtime | **Legacy only** (existing docs/scripts/host workflows) |
| Product claim | **No** Meterless-equivalent runtime shipped on `main` |

Do **not** treat this session as a successful Meterless-equivalent cutover.
Guidance-layer Meterless adaptations remain those in
[`2026-07-23_meterless_context_layer_guidance.md`](2026-07-23_meterless_context_layer_guidance.md)
only.

## What this session did

### Worktrees / SHAs

| Role | Path (session) | Git |
| --- | --- | --- |
| Candidate | `…/flutter_bloc_app-meterless-agent-runtime-memory` | Branch `codex/meterless-agent-runtime-memory` @ `31e84759` |
| Control (host baseline) | `…/flutter_bloc_app-meterless-memory-baseline-control` | Detached `31e84759` |
| Main IDE | `…/flutter_bloc_app` | Left without candidate package / default host wiring |

`baseSha` for evaluation: `31e847598686005f057d9dc10bffb197081ed7ed`.

### Built in candidate worktree (Tasks 0 offline + 1–10)

- `packages/agent_memory_runtime` — domain, SQLite/FTS schema v2, capture/redact,
  retrieve/rank, review, consolidate, checkpoints, JSON CLI, MCP (`dart_mcp`)
- Evaluation corpus: `analysis/agent_memory/fixtures/evaluation_cases.json`
  (24 cases; 8 `hostCase`)
- Evaluator: `tool/evaluate_agent_memory_candidates.dart` (+ tests)
- Gates: freeze, candidate decision, runtime conformance, host parity/smoke helpers
- Host adapter scripts under candidate only (not enabled as default memory route)

### Task 0 Step 6 — host baseline

- Ran from **control** worktree (no candidate package).
- **Codex** 8×3 completed earlier; raw `legacy-host-codex.json` preserved
  (no repair/normalize of floor failures).
- **Cursor** 8×3 completed after local `agent` login.
  - Model class: `gpt-5.6-family`
  - Cursor slug used: `gpt-5.6-terra-medium` (CLI rejects bare `gpt-5.6`)
  - Sandbox: `disabled` (OS `enabled` unavailable); `--mode ask` + `--trust`
- Frozen into `analysis/agent_memory/baselines/legacy_v1.json`:
  - `hostBaselineStatus: frozen`
  - `fixtureHash: 2cd5c692507e0f18831a64068377811d26f4f0e8adb72074973d26f34c49f8d1`
  - `worstHostScore ≈ 80.41` (min of Codex ~88.97 and Cursor ~80.41)
  - Both hosts **failed** hard floors (honest; not patched)

### Task 11 — candidate eval + decision

- Runtime offline + hostCase package-path eval → `candidate_v1.json`
- Candidate worst-host ≈ **85.0**; floors **failed**
- Margin ≈ **4.59** (< 5.0 replace threshold)
- `decision.json`: **`keep_legacy`** (candidate failed hard floor)
- Operator accepted; stamped:
  - `candidateStatus: rejected`
  - `task12Status: permanently_skipped_for_candidate_v1`
  - `activeRuntime: legacy`
  - Receipt: `candidate_v1_rejected.json`

### Explicitly not done

- Task 12/13 cutover
- Merge of candidate into default Codex/Cursor workflows
- Memory state migration
- Removal of legacy memory scripts/docs
- Claiming Meterless-equivalent product status on `main`

Worktree cleanup was approval-gated; as of 2026-07-24 afternoon the candidate
and control worktrees are **no longer listed** under `git worktree list` on this
machine. JSON evidence that lived only there may be gone unless recovered from
backup. This change note + plan status lines are the durable `main` record.

## Evidence paths (as written during the session)

Under the candidate worktree root (not on `main`; may be unavailable if that
worktree was removed):

- analysis/agent_memory/baselines/legacy_v1.json
- analysis/agent_memory/results/candidate_v1.json
- analysis/agent_memory/results/decision.json
- analysis/agent_memory/results/decision.md
- analysis/agent_memory/results/candidate_v1_rejected.json
- analysis/agent_memory/results/raw/ (Codex + Cursor dumps)
- analysis/agent_memory/fixtures/evaluation_cases.json
- analysis/agent_memory/fixtures/host_response_schema.json

## Main tree invariants after session

- No `packages/agent_memory_runtime` on `main`
- No default host route to candidate runtime
- Accidental `main` leak of `analysis/agent_memory/` removed at closeout
- Continual-learning pass: no high-signal `AGENTS.md` learned-section updates

## Follow-ups (only if operator asks)

1. Recover candidate/control worktree or archived evidence if JSON dumps still needed.
2. Any new candidate (`v2`) requires new fixture/baseline versioning — do not
   mutate frozen `legacy_v1` / `evaluation_cases_v1` in place.
3. Do not revive Task 12 for `candidate_v1`.
