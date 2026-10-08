# Agent customization layers (Codex + Cursor)

## What changed

- Added [`docs/ai/agent_customization_layers.md`](../ai/agent_customization_layers.md):
  lightest-layer ladder (knowledge → rules → shared skills → hooks → git/CI),
  hook limits, secrets defense-in-depth, pre-commit pointer.
- Cursor project `beforeReadFile` hook (git source:
  `tool/agent_host_templates/cursor/hooks/`; applied to workspace `.cursor/hooks/`
  via `./bin/agent-maintain sync --apply` — `.cursor/*` stays gitignored).
- Local `.cursorignore` optional secret patterns:
  [`docs/agent_kb/cursorignore_secrets.example`](../agent_kb/cursorignore_secrets.example).
- Thin pointers from [`AGENTS.md`](../../AGENTS.md), skill routing, AI-SDLC kit,
  environment setup, agent knowledge base details.

## Why

Translate industry “customization layer” guidance into this repo’s existing
Codex/Cursor harness without Claude-specific config or duplicating the AI-SDLC
kit / self-improvement owners.

## Verification

```bash
printf '%s' '{"file_path":"/tmp/.env","content":"x"}' | bash .cursor/hooks/block-sensitive-file-read.sh
bash tool/check_agent_knowledge_base.sh
bash tool/check_docs_gardening.sh --paths AGENTS.md docs/ai/agent_customization_layers.md docs/ai/README.md docs/ai/skill_routing.md docs/ai-sdlc/README.md docs/agent_environment_setup.md docs/agent_knowledge_base_details.md docs/agent_kb/cursorignore_secrets.example docs/changes/2026-10-08_agent_customization_layers.md
```

Hook path deny smoke: expect `permission":"deny"`. Knowledge-base + doc gardening:
exit 0.

## Deliberately skipped

- New shared skills for workflows already covered (`agents-delivery-workflow`,
  checklist skills, AI-SDLC institutional skills).
- Codex repo hooks (`.codex/hooks.json` remains gitignored user config).
- `beforeShellExecution` secret scanning (high false-positive surface; documented bypass).
- Committing `.cursorignore` (stays local per existing policy).
