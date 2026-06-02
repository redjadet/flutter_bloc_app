# Memory and file discovery

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

**Cold-start load order (numbered, do not duplicate elsewhere):** [`docs/ai/context_loading.md`](../ai/context_loading.md).

See also: [`agent_project_context.md`](../agent_project_context.md), [`code_review_graph.md`](../code_review_graph.md), [`changes/2026-05-05_codex_context_navigation_ladder.md`](../changes/2026-05-05_codex_context_navigation_ladder.md)

## Memory Compounding

Next session smarter, no bloated wiki.

- Treat source docs, ADRs, plans, changes, tests, scripts, fixtures, and host trackers as compiled memory.
- Root memory/error log files are not repo memory stores here. Route durable decisions to owning docs/ADRs/plans/changes/tasks, and recurring failure patterns to [`../../tasks/lessons.md`](../../tasks/lessons.md), `docs/changes/`, or the failing tool/test doc.
- File reusable conclusions into owning source doc, `docs/changes/`, `docs/plans/`, or [`../tasks/lessons.md`](../../tasks/lessons.md). Keep transient state in host trackers.
- Preserve source-of-truth boundaries: code/tests beat summaries; source docs beat host templates; user corrections beat inferred rules.
- Do not dump chat transcripts or generic summaries. Add compact, cited, actionable facts only.
- At session end, persist only reusable conclusions, current blockers, and exact next step when they matter for future work; otherwise report proof without creating memory noise.
- Prefer fat skills only for repeated, validated workflows with clear triggers/write scope/tools/quality bar. No cron/autonomous behavior without explicit user approval.
- Vendor skills may exist via Cursor plugins. If a vendor skill is high-frequency and bloats context, prefer **repo-owned shadow shims** synced into `~/.cursor/skills/` (same `name:`) that route to repo canon and keep hard gates.
- Long-term memory is retrieval, not recall: search relevant repo artifacts first, retrieve owning docs/code/tests/plans, then answer or edit from retrieved facts.
- For this repo, prefer maps, `rg`, code-review-graph, and targeted validation as the repo RAG path over a separate RAG layer.
- Semantic lint during doc/agent changes: stale plans, duplicate rules, source/host-template contradictions, reusable conclusions stranded in task notes.
- Before feature/refactor work, do a context audit: related code, tests, docs, plans, known bugs, workarounds, deprecated patterns, unusual helpers. Record only high-signal landmines in tracker or owning doc.
- If an approach needs more than two attempts, record failed approaches, cause, and final fix in the owning doc, [`tasks/lessons.md`](../../tasks/lessons.md), or `docs/changes/` so future agents avoid the same path.

## File discovery layers

Use when the target file is unknown (not a second cold-start ladder):

- **Map:** [`AGENTS.md`](../../AGENTS.md), [`agent_knowledge_base.md`](../agent_knowledge_base.md), [`README.md`](../README.md), task docs.
- **Project context:** [`agent_project_context.md`](../agent_project_context.md) — versions, caveats, migrations, performance seams, forbidden patterns.
- **Compiled memory:** owning docs, `docs/changes/`, `docs/plans/`, [`tasks/lessons.md`](../../tasks/lessons.md), current tracker. Chat is pointer only; verify drift-prone facts.
- **Structure:** code-review-graph or [`../tool/refresh_code_review_graph.sh`](../../tool/refresh_code_review_graph.sh) `--status-only` / `--if-needed`.
- **Raw files:** targeted reads for edit/proof; `rg` when graph is stale, missing, or too broad.

When archaeology finds a real landmine, carry it into `Context` or `Boundaries`; do not turn broad background into prompt bulk.

Related: [`changes/2026-05-05_codex_context_navigation_ladder.md`](../changes/2026-05-05_codex_context_navigation_ladder.md), [`code_review_graph.md`](../code_review_graph.md).
