# Agent memory auto-maintain (2026-05-22)

Safe automation so memory/ladder optimizations run during common actions without new manual steps or CI file mutation.

## Script

[`tool/agent_memory_auto_maintain.sh`](../../tool/agent_memory_auto_maintain.sh)

| Mode | CI | Behavior |
| --- | --- | --- |
| `--verify` | yes | Runs [`check_agent_memory_compounding.sh`](../../tool/check_agent_memory_compounding.sh) |
| `--fix-links` | no (skip) | `normalize_doc_links.py` on agent-scope markdown |
| `--if-changed` | fix skip in CI | Local: fix-links when git shows agent-scope edits; always ends with verify when combined |
| `--codex-memory-health` | yes | Report-only `~/.codex/memories` / memory-registry automation health; never edits Codex MEMORY |

Opt-out: `AGENT_MEMORY_AUTO_MAINTAIN=0`.
Optional local report hook: `AGENT_MEMORY_CODEX_HEALTH=1`.

## Wiring

| Common action | Auto step |
| --- | --- |
| `./bin/checklist-fast` / `check_agent_knowledge_base.sh` | `--if-changed` (local link normalize before KB checks) |
| `./tool/sync_agent_assets.sh --apply` | `--verify` after copy |
| `./bin/checklist` | Existing `check_agent_memory_compounding.sh` (unchanged lane) |

Not automated (explicit / risky): `compress_agent_doc.sh`, `trim_duplicate_agent_skills.sh --mode full`, continual-learning index refresh, direct writes to Codex compiled memory.

## Related

- Ladder canon: [`2026-05-22_agent-memory-ladder-dedupe.md`](2026-05-22_agent-memory-ladder-dedupe.md)
- Context/token pass: [`2026-05-22_agent-context-optimization.md`](2026-05-22_agent-context-optimization.md)
