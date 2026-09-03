# 2026-09-03 — Docs link repair (plans redirects)

## Why

Living docs still linked to gitignored `docs/plans/**` paths and a few wrong
relatives (`.env.example`, host-rule paths). Fresh clones/worktrees saw ~165
broken markdown links.

## Change

- Allow tracked [`plans/README.md`](../plans/README.md) while keeping other
  plan files gitignored; document redirect map to tracked owners.
- Retarget promoted templates/gates to `docs/engineering/**`.
- Retarget deferred/observability/auth/chat/shared-utils links to living owners;
  expand AUTH-D0x anchors in [`authentication.md`](../authentication.md).
- Demote intentional local artifacts (generated coverage summary, secret scrub
  list, local audits) to plain path mentions.
- Refresh [`PLAN.md`](../../PLAN.md) and [`CODEMAP.md`](../../CODEMAP.md) indexes.

## Proof

```bash
bash tool/check_docs_gardening.sh
bash tool/check_agent_knowledge_base.sh
# markdown relative-link scan: 0 remaining broken in docs/ai/root/supabase
```
