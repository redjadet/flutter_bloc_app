---
name: caveman-compress
description: Compress shared agent-facing markdown via the repo-local wrapper. Use when reducing context in docs used by AI agents.
---

# caveman-compress

Thin adapter. Repo wrapper wins.

Use from repo root:

```bash
./tool/compress_agent_doc.sh [--overwrite-backups] PATH [PATH ...]
```

Rules:

- Use only for shared agent-facing markdown and repo canon.
- Do not depend on `ANTHROPIC_API_KEY` or `claude` CLI auth.
- `README*.md` stays out of scope.
- Use `--overwrite-backups` when replacing an existing `.original.md`.
- Validate touched agent docs with `./tool/check_agent_knowledge_base.sh` and targeted markdown checks.

Repo docs and shell entrypoints own the flow. This skill is adapter only.
