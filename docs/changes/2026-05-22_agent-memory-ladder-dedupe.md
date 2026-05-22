# Agent memory ladder dedupe (pass 2, 2026-05-22)

Removed a **second numbered “ladder”** that competed with the canonical cold-start list in [`context_loading.md`](../ai/context_loading.md).

## Change

- [`memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md): renamed **Context Navigation Ladder** → **File discovery layers** (bullet layers, not numbered steps); pointed cold-start order at [`context_loading.md`](../ai/context_loading.md) only.
- [`agent_knowledge_base.md`](../agent_knowledge_base.md): **Context Navigation Ladder** section now distinguishes cold-start vs unknown-path routing.
- [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md): added rows for file-discovery vs cold-start ladder.

## Prior work (same day)

Pass 1: repo + host template trim, skill budgets — [`2026-05-22_agent-context-optimization.md`](2026-05-22_agent-context-optimization.md), matrix [`dedup_matrix_2026-05-22.md`](../audits/dedup_matrix_2026-05-22.md).

## Follow-up (post-push)

- [`agent_session_bootstrap.sh`](../../tool/agent_session_bootstrap.sh): stop printing a second 1–4 ladder; `read_next` + pointer to [`context_loading.md`](../ai/context_loading.md).
- [`2026-05-05_codex_context_navigation_ladder.md`](2026-05-05_codex_context_navigation_ladder.md): historical banner so linked “See also” does not revive old steps.

## Agent rule

- **One numbered context ladder** → [`ai/context_loading.md`](../ai/context_loading.md).
- **Unknown file path** → [`memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) § File discovery layers (unnumbered).
- Classify further edits via `docs/audits/dedup_matrix_*.md` (canonical / echo / stale).
