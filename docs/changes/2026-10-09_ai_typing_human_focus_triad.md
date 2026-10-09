# AI typing vs human focus triad (architecture, intent, edge cases)

**Date:** 2026-10-09  
**Scope:** Documentation only. No product or harness behavior change.

## Summary

Name the industry “AI handles typing/syntax; human focuses on architecture,
intent, and edge cases” split inside the existing human skills guide. Soften
“entirely”: CI/analyze still verify typing; agents also err on architecture.
No new parallel rule book.

## What changed

| Doc | Change |
| --- | --- |
| [`engineering/critical_human_skills.md`](../engineering/critical_human_skills.md) | New § Human focus triad with soft limits on the slogan |
| [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) | First-path pointer names the triad |
| [`engineering/README.md`](../engineering/README.md), [`docs/README.md`](../README.md) | Catalog blurbs mention the triad |

## Out of scope

- No re-index page or AGENTS.md hosting of the human skills guide
- No invent-product features
- No claim that humans stop verifying diffs or that AI never chooses architecture
