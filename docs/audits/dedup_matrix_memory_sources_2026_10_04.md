# Memory-source deduplication matrix: 4 October 2026

This pass edits documentation only. It preserves lesson headings, historical
facts, technical paths, and source-of-truth boundaries.

| Target | Class | Change | Authority retained |
| --- | --- | --- | --- |
| [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md) | Echo | Merge adjacent memory-routing bullets. | Owning docs, ADRs, plans, changes, lessons, and host trackers retain their roles. |
| [`agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md) | Echo / stale | Merge Git bullets and remove contradictory unsolicited-commit wording. | [`agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md), `SAFETY-03`. |
| [`agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md) | Canonical pointer | Route Codex communication defaults to its host instructions. | User-supplied home [`~/.codex/AGENTS.md`](../agent_host_notes.md#codex); Cursor keeps its own host rule. |
| [`tasks/lessons.md`](../../tasks/lessons.md), 2026-07-04 coverage lesson | Stale | Replace repeated obsolete instructions with compact history and a supersession link. | 2026-07-13 lesson and the current durable delivery preference. |
| [`tasks/lessons.md`](../../tasks/lessons.md), 2026-04-17 communication lesson | Stale for Codex | Keep history and identify the current full-mode default. | The user's 2026-10-04 host instructions and session overrides. |

No byte-identical duplicate source files or repeated substantive bullets were
found in the four reviewed memory documents. Similar lessons from different
incidents remain separate. Generated local Codex memories and account-side
ChatGPT memories require their supported controls rather than database edits.

The local audit and timestamped backup manifest are in
`/Users/ilkersevim/Documents/ChatGPT/Memory`. Scheduled maintenance belongs to
that chat; this change introduces no repository cron job or host asset sync.
