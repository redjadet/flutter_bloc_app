# Memory and Context Navigation Ladder

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

See also: [`agent_project_context.md`](../agent_project_context.md), [`code_review_graph.md`](../code_review_graph.md), [`changes/2026-05-05_codex_context_navigation_ladder.md`](../changes/2026-05-05_codex_context_navigation_ladder.md)

## Memory Compounding

Next session smarter, no bloated wiki.

- Treat source docs, ADRs, plans, changes, tests, scripts, fixtures, and host trackers as compiled memory.
- File reusable conclusions into owning source doc, `docs/changes/`, `docs/plans/`, or [`../tasks/lessons.md`](../../tasks/lessons.md). Keep transient state in host trackers.
- Preserve source-of-truth boundaries: code/tests beat summaries; source docs beat host templates; user corrections beat inferred rules.
- Do not dump chat transcripts or generic summaries. Add compact, cited, actionable facts only.
- Prefer fat skills only for repeated, validated workflows with clear triggers/write scope/tools/quality bar. No cron/autonomous behavior without explicit user approval.
- Vendor skills may exist via Cursor plugins. If a vendor skill is high-frequency and bloats context, prefer **repo-owned shadow shims** synced into `~/.cursor/skills/` (same `name:`) that route to repo canon and keep hard gates.
- For this repo, prefer maps, `rg`, code-review-graph, and targeted validation over separate RAG layer.
- Semantic lint during doc/agent changes: stale plans, duplicate rules, source/host-template contradictions, reusable conclusions stranded in task notes.
- Before feature/refactor work, do a context audit: related code, tests, docs, plans, known bugs, workarounds, deprecated patterns, unusual helpers. Record only high-signal landmines in tracker or owning doc.

## Context Navigation Ladder

Use when exact file is not known:

1. **Map layer:** [`AGENTS.md`](../../AGENTS.md), [`agent_knowledge_base.md`](../agent_knowledge_base.md), [`README.md`](../README.md), task docs.
2. **Project context layer:** [`agent_project_context.md`](../agent_project_context.md) for pinned versions, package caveats, migrations, performance seams, and forbidden patterns.
3. **Memory layer:** owning docs, `docs/changes/`, `docs/plans/`, [`tasks/lessons.md`](../../tasks/lessons.md), current tracker. Chat memory is pointer only; verify drift-prone facts.
4. **Structural layer:** code-review-graph or [`../tool/refresh_code_review_graph.sh`](../../tool/refresh_code_review_graph.sh) `--status-only` / `--if-needed`.
5. **Raw-file layer:** targeted raw-file reads only for edit/proof. Use `rg` when graph is stale/missing/too broad.

When archaeology finds a real landmine, carry it into `Context` or `Boundaries`; do not turn broad background into prompt bulk.

Related: [`changes/2026-05-05_codex_context_navigation_ladder.md`](../changes/2026-05-05_codex_context_navigation_ladder.md), [`code_review_graph.md`](../code_review_graph.md).
