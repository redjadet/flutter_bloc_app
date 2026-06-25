# Skill Routing For AI Agents

Canonical skill picker. Repo canon wins over vendor skill text.

## Start Rule

| Situation | Action |
| --- | --- |
| Non-trivial task start | Read [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight; invoke `agents-common-pitfalls`; run `./bin/agent-maintain preflight` |
| Implementation / refactor / tests / validation / debugging / host setup | Pick a matching skill before edits or broad commands |
| Pure read-only Q&A | Skill optional; use repo docs first |
| Trivial one-line fix with obvious convention | Skill optional only when confidence is at least 95% |
| Unsure | Invoke `agents-skill-routing`, then `./bin/agent-maintain find QUERY` |

Load only the selected skill entrypoint; then follow repo validation overrides.
Full context ladder: [`context_loading.md`](context_loading.md).

## Authority

1. User instructions
2. [`AGENTS.md`](../../AGENTS.md) and repo `docs/`
3. `.cursor/rules/*.mdc` and synced templates under `tool/agent_host_templates/`
4. Global vendor skills
5. Model defaults

## Discovery

```bash
./bin/agent-maintain find QUERY
bash tool/find_global_agent_skills.sh QUERY
npx skills find QUERY
npx skills ls -g
```

Install/update globals: [`agent_environment_setup.md`](../agent_environment_setup.md),
[`operations_host_skills.md`](../validation_scripts/operations_host_skills.md).
Host parity: Cursor/Codex sync shim `agents-skill-routing`; Codex installs it as
`flutter-bloc-app-skill-routing`.

## Repo-First Routing

| Trigger | Skill(s) / owner |
| --- | --- |
| Pre-flight / frequent agent mistakes | `agents-common-pitfalls`; owner [`ai_failure_risks.md`](ai_failure_risks.md) |
| Cold start / commands / validation chooser | `agents-quick-reference` |
| Non-trivial delivery / finish gate | `agents-delivery-workflow` |
| Non-trivial coding / operating discipline | `agents-delivery-workflow`; [`agent_operating_manual.md`](agent_operating_manual.md) |
| Plan / delegation reminders | `agents-meta-behavior` |
| Feature code in this repo | `agents-feature-delivery`, then `agents-canonical-rules` + matching child (`architecture`, `async`, `platform`, `presentation`) |
| New feature / external API / DTO / cubit state / sync / typed errors | [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md), [`architecture/reference_features.md`](../architecture/reference_features.md), then `agents-feature-delivery` + `agents-canonical-rules-architecture` |
| Cubit/BLoC state, lifecycle, side effects, tests | `agents-bloc-standards`, then `agents-validation-testing` |
| Add new Cubit | `agents-create-cubit`, then `agents-bloc-standards` |
| Flutter baseline / theme / l10n / BLoC access | `agents-canonical-rules-presentation`, `flutter-cross-platform-modern`; search `type-safe-bloc-access` if available |
| Cross-platform / responsive behavior | `flutter-cross-platform-modern` |
| Checks / regression guards / test routing | `agents-validation-testing` |
| After non-trivial bug fix | `agents-regression-capture` same turn, then `agents-validation-testing` |
| Analysis / layout / runtime errors | [`agent_kb/devtools_runtime_errors.md`](../agent_kb/devtools_runtime_errors.md); `dart-fix-runtime-errors`, `systematic-debugging`, `flutter-fix-layout-issues` |
| Pub dependency / version-sensitive API | [`agent_kb/package_docs_mcp.md`](../agent_kb/package_docs_mcp.md); Context7 + `user-dart`; `context7-mcp`, `flutter-ai-rules` |
| Supabase schema / migrations | `agents-supabase`; search `ai-safe-supabase-workflow` if available |
| Figma to code | `agents-figma` / `figma-this-repo` |
| Install / trim / sync globals | `agents-global-skills-setup` if available; otherwise `./bin/agent-maintain install/update/trim` |

Repo skill sources: [`tool/agent_host_templates/shared/skills/`](../../tool/agent_host_templates/shared/skills/).
New shared skills must be listed in `tool/agent_asset_lib.sh`.

## Vendor Skills

Use official Dart/Flutter skills only when they add task-specific procedure not
already owned by repo docs: tests, CLI, coverage, mocks, analyzer, package
conflicts, patterns, widget/integration tests, responsive/layout fixes, routing,
l10n, JSON/HTTP.

Process skills: ambiguous scope -> `brainstorming`; multi-step plan -> `writing-plans`;
bug/test failure -> `systematic-debugging`; before done/commit -> `verification-before-completion`;
new logic/tests -> `test-driven-development`; after bug fix -> `agents-regression-capture`.

## Repo Validation Overrides

- Fast sanity: `./bin/checklist-fast`
- Feature validation: [`validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
- Integration: `./bin/integration_tests`
- Agent docs changed: `./tool/check_agent_knowledge_base.sh`

Related: [`context_loading.md`](context_loading.md), [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md), [`governance.md`](governance.md).
