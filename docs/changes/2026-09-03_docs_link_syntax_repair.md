# 2026-09-03 — Docs link syntax repair

## Why

Link-retarget sweep left accidental self-links and malformed
`[[\`label\`](url)](url)` markdown in a few living docs.

## Change

- Restore `code_graph.pdf` link target to `../code_graph.pdf`
  (local/gitignored), not a self-link to this doc.
- Point gstack Codex skill bullet at the bundled
  `.agents/skills/gstack/.../gstack-codex` SKILL path (relative from
  `docs/ai/`).
- Normalize double-bracket SHARED_UTILITIES links to standard
  `[`label`](url)` form.

## Note

`docs/plans/README.md` table already has matching 2-column header/separator;
no change required for that report.

## Proof

```bash
bash tool/check_docs_gardening.sh --paths docs/ai/code_review_graph.md docs/ai/gstack_integration.md docs/ai/repo_map.md docs/clean_architecture.md
```
