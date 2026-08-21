# Docs and skill consistency (indexes + host availability)

## What changed

Aligned entry indexes and skill routing so humans and agents share one map:

- [`docs/ai/README.md`](../ai/README.md): list `skill_routing`, failure risks, harness docs (were on disk but missing from the folder index).
- [`docs/README.md`](../README.md) + [`docs/features/README.md`](../features/README.md): add social feed and other shipped feature guides to walkthrough tables.
- [`docs/ai/skill_routing.md`](../ai/skill_routing.md) + [`docs/agent_kb/host_parity_and_enforcement.md`](../agent_kb/host_parity_and_enforcement.md): document shared vs Cursor-only vs global/vendor skills; stop implying Cursor-only / optional globals are always present.
- Shared skills `agents-common-pitfalls`, `gh-watch-merge-pr`: fall back to owner docs / `gh` when global skills are missing.
- [`CODEMAP.md`](../../CODEMAP.md) + [`docs/new_developer_guide.md`](../new_developer_guide.md): social-feed path + AGENTS/skill-routing pointers for onboarding.
- Carry-forward link hygiene: social-feed feature README relative path; host-local Documents note in prior change note.

## Why

Index gaps and host-skill name ambiguity slowed cold start. Canon already existed; pointers and availability notes were inconsistent.

## Verification

```bash
bash tool/check_docs_gardening.sh --paths docs/ai/README.md docs/ai/skill_routing.md docs/README.md docs/features/README.md docs/new_developer_guide.md docs/agent_kb/host_parity_and_enforcement.md CODEMAP.md
./bin/agent-maintain after-host-edit
bash tool/check_agent_knowledge_base.sh
bash tool/check_agent_asset_drift.sh
```

## Rollback

Revert this note and the listed doc/template edits.
