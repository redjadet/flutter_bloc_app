# Agent customization layers (Codex + Cursor)

Pick the **lightest layer that works**, then stop. Heavier layers cost context,
duplication, and review surface. This repo keeps **one tool-agnostic map**
([`AGENTS.md`](../../AGENTS.md)) and pushes detail into owner docs, shared host
templates, and mechanical gates.

Official references (verify when upgrading hosts):

- Cursor rules: [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules)
- Cursor agent hooks: [cursor.com/docs/agent/hooks](https://cursor.com/docs/agent/hooks)
- OpenAI Codex loop / scoped instructions: [openai.com/index/unrolling-the-codex-agent-loop](https://openai.com/index/unrolling-the-codex-agent-loop/)

There is **no** repo-managed Claude Code layer (no vendor root instruction
file, `.claude/`, or Anthropic hook packs). Industry “code-level mods” (vendor
plugins that rewrite
tool behavior inside the model loop) have **no** Codex/Cursor equivalent here —
use scripts, tests, and CI instead.

## Decision ladder (first match wins)

| Need | Layer | This repo |
| --- | --- | --- |
| Stable facts, routing, safety pointers | **Project knowledge** | [`AGENTS.md`](../../AGENTS.md) (≤50 lines), [`docs/agent_knowledge_base.md`](../agent_knowledge_base.md), owner docs under `docs/` |
| Always-on thin guardrails for a host | **Rules** | Cursor: `tool/agent_host_templates/cursor/rules/*.mdc` → synced `.cursor/rules/` (project-only; not global `~/.cursor/rules`) |
| Repeatable multi-step procedure | **Skill** | **Source:** `tool/agent_host_templates/shared/skills/<name>/SKILL.md` synced to host skill homes; **picker:** [`skill_routing.md`](skill_routing.md). Cursor-only templates under `tool/agent_host_templates/cursor/skills/`. Optional globals via `./bin/agent-maintain install` → `~/.agents/skills/` (skills CLI) with host links — see [`agent_environment_setup.md`](../agent_environment_setup.md). Do **not** duplicate shared skills into repo `.cursor/skills/` (drift guard). |
| Block / allow / nudge at a fixed agent moment | **Agent hook** | Cursor project: `.cursor/hooks.json` + `.cursor/hooks/*.sh` (template: `tool/agent_host_templates/cursor/`). **Convenience only** — see limits below. Codex: optional user-local hook config (`.codex/hooks.json` is gitignored here; not synced). |
| Hard guarantee before commit / merge | **Git hook + CI** | Optional local: `./bin/install-git-hooks` → `githooks/pre-commit` (RequestIdGuard lane). Merge gate: [`ai-sdlc/gates.md`](../ai-sdlc/gates.md), `./bin/checklist`, GitHub Actions. |

**Skills vs docs:** If the workflow is policy or architecture, update the **owner
doc** first. Add or extend a **shared skill** only when agents repeatedly miss
the same steps and the owner doc already exists ([`self_improvement.md`](../agent_kb/self_improvement.md) — no verifier, no persistence).

**Rules vs docs:** Rules are short reminders that point at owner docs. Do not
copy long checklists into `.mdc` files.

## Agent hooks: what they are (and are not)

Cursor command hooks run as separate processes with JSON on stdio ([hooks
spec](https://cursor.com/docs/agent/hooks)). Cloud agents load **project**
`.cursor/hooks.json`; user `~/.cursor/hooks.json` does not run in cloud.

| Trust level | Examples |
| --- | --- |
| **Soft** | `sessionStart` context injection; `afterFileEdit` format-on-save style helpers (fail-open) |
| **Medium** | `beforeReadFile` / `beforeShellExecution` with `permission: deny` — blocks that **tool path** only |
| **Hard** | `tool/check_*.sh`, `./bin/checklist`, CI required checks |

**Leakage paths hooks do not close:**

- Shell reads (`cat`, `sed`, heredocs) bypass `beforeReadFile`.
- MCP tools, subagents, or scripts may read paths the hook never sees.
- `afterFileEdit` does not run when a shell script rewrites files.

Therefore: **format / analyze / tests before “done”** stay in
[`legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md),
[`gates.md`](../ai-sdlc/gates.md), and CI — not in hook JSON alone.

### Project hooks shipped here

| Hook | Script | Intent |
| --- | --- | --- |
| `sessionStart` | `.cursor/hooks/session-flutter-context.sh` | Short Flutter session reminder (fail-open) |
| `afterFileEdit` | `.cursor/hooks/format-dart-after-edit.sh` | Format edited `.dart` (fail-open; `./bin/format` still required at closeout) |
| `beforeReadFile` | `.cursor/hooks/block-sensitive-file-read.sh` | Deny agent **Read** on common local secret paths (see script header) |

**Trade-off:** `beforeReadFile` receives file content on stdin for policy hooks;
this script matches **paths only** and does not log content. Deny list mirrors
[`security_and_secrets.md`](../security_and_secrets.md); samples under `*.sample`,
`*.example`, and `**/ci/**` stay allowed.

**Verification:** Manual — pipe JSON into the script (see script footer). Not run
in CI (host-specific).

## Secrets out of agent context (defense in depth)

| Control | Role | Tested |
| --- | --- | --- |
| Gitignore + `tool/check_tracked_secret_literals.sh` | Prevent committed secrets | CI / checklist |
| Owner doc [`security_and_secrets.md`](../security_and_secrets.md) | Human + agent policy | Doc gardening |
| Local `.cursorignore` | Indexing noise + optional secret path exclusion | Local only (gitignored); patterns in [`cursorignore_secrets.example`](../agent_kb/cursorignore_secrets.example) |
| `beforeReadFile` hook | Block agent file-read tool on sensitive paths | Manual smoke only |

Treat every hook script like application code: small, reviewed, no network, no
secret logging.

## Git pre-commit (optional local)

Narrow early lane — **not** a full static gate:

```bash
./bin/install-git-hooks   # core.hooksPath=githooks
```

Runs `tool/check_mutation_success_after_guard.sh --staged` only. Full proof:
[`validation_scripts/operations_running.md`](../validation_scripts/operations_running.md).

## Related owners

- Host parity / sync: [`host_parity_and_enforcement.md`](../agent_kb/host_parity_and_enforcement.md)
- AI-native SDLC artifact loop: [`../ai-sdlc/README.md`](../ai-sdlc/README.md)
- Skill picker: [`skill_routing.md`](skill_routing.md)
- Environment setup: [`agent_environment_setup.md`](../agent_environment_setup.md)
