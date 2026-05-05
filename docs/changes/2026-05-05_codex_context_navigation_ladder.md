# Codex Context Navigation Ladder

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

Codex should use this context ladder for non-trivial existing-code work:

1. repo map docs
2. durable repo memory
3. `code-review-graph`
4. targeted raw-file reads

This preserves long-term memory and full-codebase awareness without creating a
parallel chat transcript vault or treating generated graph output as source of
truth.

## Scope

- Source docs expose the ladder.
- Bootstrap output prints the ladder and graph-cache presence.
- Memory guard checks the ladder stays discoverable.
- Host templates stay synced from repo-managed source.
