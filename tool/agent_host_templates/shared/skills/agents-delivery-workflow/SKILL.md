---
name: agents-delivery-workflow
description: >-
  Shared Codex/Cursor delivery loop for non-trivial work, validation routing,
  tracker choice, and completion gate before done or commit. Includes finish
  gate with post-bug agents-regression-capture before report.
---

# Delivery workflow

Use for non-trivial feature/fix, validation routing, completion before done/commit.

**Lifecycle:** phase-gated / AIDLC / resume active run → `agents-aidlc-workflow`
(owner `docs/ai/aidlc_workflow.md`); this skill stays the finish-gate loop.

**Start:** `AGENTS.md` + **context ladder** (`docs/ai/context_loading.md`).

**Operating discipline:** `docs/ai/agent_operating_manual.md` (T1/T2; pointer-only).

**Tracker:** Codex `tasks/codex/todo.md`; Cursor `tasks/cursor/todo.md`.

**Loop:** Plan -> Execute -> Verify -> Report; **95% confident**; **Surgical diff**; **Report only after Verify**; **Self-verify final response**.

Commands/routing: `docs/agents_quick_reference.md`. Doctrine/review/validation: `docs/agent_knowledge_base.md`, `docs/ai_code_review_protocol.md`, `docs/engineering/validation_routing_fast_vs_full.md`, `tool/check_agent_knowledge_base.sh`.

UI/platform: `DESIGN.md`, `docs/design_system.md`.

Host maintain: `agent-maintain preflight`, `agent-maintain closeout`, `host_maintenance_automation.md`.

**File verified reusable conclusions** -> owning doc / `docs/changes/` / `tasks/lessons.md`.

## Finish gate (before done / commit)

1. **Agent pre-complete gate** — owner `docs/agent_kb/legibility_and_finish_gate.md` § Agent pre-complete gate: (a) `./bin/format` or `dart format .` when any `.dart` changed; (b) `flutter analyze` / `./tool/analyze.sh` when Dart/analyzer surface touched; (c) targeted `flutter test <paths>` (docs-only may skip with explicit Verification note). Prefer `./bin/format --changed` only for huge trees; default is `./bin/format`.
2. **Verify** — run narrowest honest validation lane (`docs/engineering/validation_routing_fast_vs_full.md`); full `./bin/checklist` keeps analyze + Flutter tests — do not strip them. Report proof, not intent.
3. **Bug-fix hardening** — if this task fixed a non-trivial bug, race, lifecycle issue, flaky test, or one-off failure that could recur: invoke `agents-regression-capture` **same turn** (before step 4). Skip only with explicit reason in report.
4. **Report** — `SAFETY-REPORT` including **What We Learned** teach-back (or mechanical skip), Goal / Context / Boundaries / Verification; **Regression capture** block when step 3 ran (or skip reason).
5. **Host** — `./bin/agent-maintain closeout` when templates or agent docs touched.

**Cursor-only:** Multi-agent hub anchors `Benefit: team` / `Benefit: single`; `tasks/cursor/team/<run-id>/`; `agent_knowledge_base.md#multi-agent-hub`.
