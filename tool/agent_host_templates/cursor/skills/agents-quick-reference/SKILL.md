---
name: agents-quick-reference
description: Canon pointers, lifecycle, trackers, approved shell entrypoints, and host wrapper rules. Repo canon wins.
---

# Quick reference

Open only needed repo-local canon:

1. `AGENTS.md`
2. `docs/agent_knowledge_base.md`
3. `docs/agents_quick_reference.md`
4. `docs/ai_code_review_protocol.md` when reviewing AI-written code

Non-trivial delivery/completion bar: **`agents-delivery-workflow`**.
Delegation discipline: **`agents-meta-behavior`**.

Repo profile:

- Flutter 3.41.9 / Dart 3.11.5
- `Presentation -> Domain <- Data`

Closed-loop default:

- Plan once (<=10 lines) -> execute -> verify -> report.
- Keep going end-to-end; ask only on hard blockers.
- Context budget: targeted search + narrow reads.

Fast reminders:

- non-trivial work -> `tasks/cursor/todo.md`
- repeated user correction -> `tasks/lessons.md`
- reusable agent conclusion -> source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`
- agent docs/map drift -> `./tool/check_agent_knowledge_base.sh`
- agent memory-compounding drift -> `./tool/check_agent_memory_compounding.sh`
- repeated agent failure -> add missing repo capability, not bigger prompt
- UI/app changes -> prefer app-visible proof over logs-only claims
- lifecycle / memory-pressure work -> `docs/REPOSITORY_LIFECYCLE.md` and `docs/reliability_error_handling_performance.md`
- prefer `DisposableBag`, `CubitSubscriptionMixin`, `SubscriptionManager`, `TimerHandleManager`
- widget-test viewport sizing -> `tester.view.*` + reset methods; avoid deprecated `tester.binding.window`
- shared agent-doc compression -> `./tool/compress_agent_doc.sh [--overwrite-backups] PATH [PATH ...]` or `caveman-compress`
- agent/docs changes -> semantic-lint stale plans, duplicate rules, source/host-template contradictions
- before final report -> self-verify vs request, changed files, proof, blockers, risk
- multi-agent hub -> `agents-delivery-workflow` (benefit gate, team run dir `tasks/cursor/team/<run-id>/`) + `agents-meta-behavior` (Task roles + redaction); doctrine `docs/agent_knowledge_base.md#multi-agent-hub`

Approved shell entrypoints:

```text
./bin/router_feature_validate
./bin/checklist
./bin/integration_tests
./bin/upgrade_validate_all
./tool/check_agent_knowledge_base.sh
./tool/check_agent_memory_compounding.sh
./tool/check_agent_asset_drift.sh
./tool/sync_agent_assets.sh --dry-run
./tool/sync_agent_assets.sh --apply
./tool/request_codex_feedback.sh
```

Host wrapper rules:

- Cursor slash commands are convenience wrappers only.
- Codex should call same repo scripts directly.
- Cross-host review helpers must not self-delegate.
- Docs-only changes need targeted doc/link checks; use `./bin/checklist` when guidance changed materially.
- Self-verification is mandatory and local to reporting agent.

This skill is adapter only. Repo canon wins.
