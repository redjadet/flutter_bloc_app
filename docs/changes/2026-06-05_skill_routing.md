# Skill routing docs for AI agents

## Why

Official Dart/Flutter skills are installed globally, but agents need a repo-owned map to **discover and invoke** the right skill automatically without loading every skill up front.

## What shipped

- Canonical routing: [`docs/ai/skill_routing.md`](../ai/skill_routing.md) — automatic selection rule, authority stack, discovery commands, repo-first + official Dart/Flutter tables, process-skill triggers.
- Context ladder step 7: [`docs/ai/context_loading.md`](../ai/context_loading.md).
- Wired from `AGENTS.md`, quick reference, environment setup, memory ladder, `docs/README.md`.
- Repo shim skill: `tool/agent_host_templates/shared/skills/agents-skill-routing/SKILL.md` (auto-trigger via `description`).
- Sync manifest: `tool/agent_asset_lib.sh` (Cursor `agents-skill-routing`, Codex `flutter-bloc-app-skill-routing`).

## Follow-up (re-check)

- Fixed wrong `SKILL.md` link in automatic-selection step 4.
- Inventory snapshot: optional until `dart run tool/skill_inventory.dart`; checklist-fast fallback documented.
- Codex host path note; bootstrap `read_next` for `skill_routing.md`.
- KB regression anchors in `tool/check_agent_knowledge_base.sh` and memory compounding checks.

## Verification

- `./tool/check_agent_knowledge_base.sh`
- `./bin/agent-maintain after-host-edit` after template sync
