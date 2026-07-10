# Agent context loading deduplication

## Problem

Session bootstrap labeled seven general docs and two specialized docs as
`read_next`. That contradicted progressive disclosure and could force roughly
4,000 words of unrelated context before task routing.

## Change

- Keep three cold-start core files: [`AGENTS.md`](../../AGENTS.md), [`ai/context_loading.md`](../ai/context_loading.md), and
  [`ai/skill_routing.md`](../ai/skill_routing.md).
- Route doctrine, review, commands, validation detail, design, and localization
  docs through explicit task triggers.
- Replace long universal ladder with core steps plus conditional owners.

## Proof

Run `bash tool/agent_session_bootstrap.sh`; only three entries use `read_core`.
Agent knowledge-base, checklist-fast, closeout, and diff checks remain required.
`check_agent_memory_compounding.sh` now fails when core count changes or any
conditional owner route disappears; harness fixtures prove negative behavior.
