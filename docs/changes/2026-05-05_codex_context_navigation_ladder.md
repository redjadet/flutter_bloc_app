# Codex Context Navigation Ladder

> **Historical (2026-05-05).** Current canon: cold-start load order in [`context_loading.md`](../ai/context_loading.md); unknown-path layers in [`memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md). This note records the Codex memory/graph decision below—not a second numbered ladder.

## Why

The linked reference setup,
<https://github.com/lucasrosati/claude-code-memory-setup>, combines durable
project memory, imported chat history, and a persistent structural graph so an
agent does not repeatedly reread the same codebase context.

This repo already has stronger source-of-truth boundaries than a standalone
vault: versioned docs, plans, changes, validation scripts, host trackers, and
`code-review-graph` support. The improvement is to make Codex use those layers
in a fixed order.

## Decision

Codex should follow the repo’s canonical discovery routing (no second ladder
text here): cold-start order in [`context_loading.md`](../ai/context_loading.md)
and unknown-path layers in
[`memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md).

This preserves long-term memory and full-codebase awareness without creating a
parallel chat transcript vault or treating generated graph output as source of
truth.

## Scope

- Source docs expose the ladder.
- Bootstrap output prints the ladder and graph-cache presence.
- Memory guard checks the ladder stays discoverable.
- Host templates stay synced from repo-managed source.
