---
name: agents-skill-routing
description: >-
  Discover and invoke the right agent skills for Flutter BLoC app tasks —
  repo-first routing, official Dart/Flutter skills, discovery commands, and
  bug-fix hardening via agents-regression-capture. Use when starting
  implementation, tests, debugging, validation, or host setup; or when unsure
  which skill applies.
---

# Skill Routing

Repo canon wins. Full routing table and discovery commands:

[`docs/ai/skill_routing.md`](../../../../../docs/ai/skill_routing.md)

## Quick rule

For non-trivial work, find and invoke a suitable skill before editing or broad commands. Read selected `SKILL.md`; follow repo validation.

## Repo-first (this project)

| Trigger | Skill |
| --- | --- |
| Orientation / commands | `agents-quick-reference` |
| Non-trivial delivery | `agents-delivery-workflow` |
| Feature code | `agents-canonical-rules` (+ child matching your layer) |
| Flutter baseline | `agents-canonical-rules-presentation`, `flutter-cross-platform-modern` |
| Cross-platform UI | `flutter-cross-platform-modern` |
| Checks / tests routing | `agents-validation-testing` |
| Bug fixed / prevent recurrence | `agents-regression-capture` → `agents-validation-testing` |
| Analyze / layout / runtime | [`docs/agent_kb/devtools_runtime_errors.md`](../../../../../docs/agent_kb/devtools_runtime_errors.md); `dart-fix-runtime-errors`, `systematic-debugging`, `flutter-fix-layout-issues` |
| Pub dependency / API docs | [`docs/agent_kb/package_docs_mcp.md`](../../../../../docs/agent_kb/package_docs_mcp.md); Context7 + `user-dart`; `context7-mcp`, `flutter-ai-rules` |
| Globals install/trim | `agents-global-skills-setup` or `./bin/agent-maintain install/update/trim` |

## Find skills

```bash
./bin/agent-maintain find QUERY
bash tool/find_global_agent_skills.sh QUERY
npx skills find QUERY
```

Install/update: [`docs/agent_environment_setup.md`](../../../../../docs/agent_environment_setup.md).
