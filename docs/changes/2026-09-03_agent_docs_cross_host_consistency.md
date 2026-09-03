# Agent Documentation Cross-Host Consistency

## Scope

Reviewed root entry points and high-frequency owners selected by inbound
Markdown references: context/routing, operating and safety policy, review,
validation/testing, architecture/BLoC, product/design, Git workflow, harness,
host parity, and maintenance.

Codex and Cursor remain the primary validated hosts. Other AI agents use the
same repository map and canonical docs without inheriting host-only behavior.

## Findings And Repairs

- Root [`AGENTS.md`](../../AGENTS.md) duplicated policy and host commands. It is now a short
  Start / Task Map / Finish index with detailed rules left to owners.
- Context and knowledge-base docs referenced removed AGENTS sections and a
  nonexistent context-ladder step. Links now target current owners.
- Shared architecture, BLoC, testing, and risk docs described themselves as
  Codex/Cursor-only. They now apply to all AI agents while identifying Codex
  and Cursor as the scored hosts.
- Project context contained host-specific runtime/package instructions. It now
  links to those owners with capability-neutral wording.
- Project AGENTS was configured to copy into global Codex home and other
  worktrees. Sync now leaves the map project-scoped; each worktree uses its
  checked-out version.
- Review guidance used a secondary article as its top-level attribution. It now
  points to current official safety guidance and keeps repository checks as the
  acceptance authority.
- Generated AI discovery maps targeted an older repository revision. The
  repo-owned refresh path updated metadata, bounded metrics, and indexes while
  preserving human-maintained narrative.
- Existing safety, finish, validation, architecture, detailed testing, design,
  and Git owners remain authoritative. Live repository inspection confirmed
  the documented Git ruleset is still disabled.

## Current External Compatibility References

Reviewed 2026-09-03:

- [OpenAI Codex instruction loading](https://openai.com/index/unrolling-the-codex-agent-loop/)
- [OpenAI harness engineering](https://openai.com/index/harness-engineering/)
- [OpenAI Codex safety and review](https://openai.com/index/introducing-upgrades-to-codex/)
- [Cursor rules](https://docs.cursor.com/context/rules)
- [Cursor CLI](https://docs.cursor.com/en/cli/using)

## Verification Route

- Agent knowledge, safety, failure-risk, memory, and harness gates
- Host asset dry-run and shell/CLI fixtures
- Documentation gardening and link normalization
- AI snapshot refresh self-test and strict freshness gate
- Full delivery checklist with fresh evidence

## Follow-up (same day)

- Documented unmanaged Codex home AGENTS under host notes and host parity
  (explicit authorization required before host rewrite).
- Aligned [`AGENTS.md`](../../AGENTS.md) Start with
  [`context_loading.md`](../ai/context_loading.md): ladder first; project
  context/safety for non-trivial work; operating manual for T1/T2 only.
- Clarified project-only `agent-execution.mdc` wording: AGENTS is map, docs own
  rules.
- Human replaced Codex home AGENTS with a 7-line host-neutral pointer; original
  preserved as `AGENTS.md.backup-2026-09-03-pre-project-scope`. Host docs updated
  to describe that intended home-file shape.
