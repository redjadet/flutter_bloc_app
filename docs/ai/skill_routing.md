# Skill Routing For AI Agents

Canonical guide for choosing skills in this repo. Install/update globals:
[`agent_environment_setup.md`](../agent_environment_setup.md) and
[`operations_host_skills.md`](../validation_scripts/operations_host_skills.md).

## When to invoke a skill

| Situation | Action |
| --- | --- |
| Non-trivial task start (app code, harness, validation, architecture) | Read [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight; invoke `agents-common-pitfalls`; `./bin/agent-maintain preflight` |
| Implementation, refactor, tests, validation, host setup, or debugging | **Find and invoke** a matching skill before editing or broad commands |
| Pure read-only Q&A with no code change | Skill optional; use repo docs first |
| Trivial one-line fix with obvious local convention | Skill optional only when confidence is at least 95% |
| Unsure whether a skill exists | Invoke `agents-skill-routing`, then search globals |

Progressive disclosure: skills load procedure, not full policy. **Repo canon wins** over vendor skill text on conflict.

## Authority stack

1. User instructions (this session)
2. [`AGENTS.md`](../../AGENTS.md) → repo `docs/` (including this file)
3. `.cursor/rules/*.mdc` and synced repo shims under `tool/agent_host_templates/`
4. Global vendor skills (`~/.agents/skills/`, Cursor plugin skills)
5. Model defaults

Official [Dart and Flutter skills](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae)
are task blueprints. Repo skills win when both apply.

## Discovery (find a skill automatically)

Use in order:

1. Match user intent to session skill descriptions.
2. Use the repo-first table below.
3. Invoke `agents-skill-routing` when ambiguous.
4. Search globals:

   ```bash
   ./bin/agent-maintain find QUERY
   bash tool/find_global_agent_skills.sh QUERY
   npx skills find QUERY
   npx skills ls -g
   ```

5. Optional inventory: `docs/audits/skill_inventory_latest.json`.

Reload Cursor after install/update (**Developer: Reload Window**).

**Host parity:** Cursor and Codex both sync the shim with `name: agents-skill-routing`.
Codex installs it as the `flutter-bloc-app-skill-routing` skill.

## Automatic selection rule

For any non-trivial task:

1. Normalize the request to task verbs: implement, refactor, test, debug, validate, design, host setup, docs, release.
2. Pick repo skill first if a row below matches.
3. Add official Dart/Flutter skill only when it gives task-specific procedure missing from repo docs.
4. Read only the selected skill entrypoint (from the session list, routing table, or search) — not every skill upfront — then follow repo validation overrides below.
5. If no route matches, run `./bin/agent-maintain find "<task keywords>"`; if still none, continue from repo docs and report no skill match.

## Repo-first routing (always consider)

| Trigger | Skill(s) |
| --- | --- |
| Pre-flight / frequent agent mistakes | `agents-common-pitfalls`; owner [`ai_failure_risks.md`](ai_failure_risks.md) |
| Cold start / commands / validation chooser | `agents-quick-reference` |
| Non-trivial delivery loop | `agents-delivery-workflow` |
| Plan, delegation, finish gates | `agents-meta-behavior` |
| Feature code in this repo (layers, Cubit, DI, Freezed) | `agents-feature-delivery`, then `agents-canonical-rules` → open matching child (`architecture`, `async`, `platform`, `presentation`) |
| Cubit/BLoC state, lifecycle, side effects, or tests | `agents-bloc-standards`, then `agents-validation-testing` |
| Add new Cubit to a feature | `agents-create-cubit`, then `agents-bloc-standards` |
| Flutter baseline (theme, l10n, BLoC access) | `agents-canonical-rules-presentation`, `flutter-cross-platform-modern`; search `type-safe-bloc-access` if available |
| Cross-platform / responsive / platform behavior | `flutter-cross-platform-modern` |
| Checks, regression guards, test routing | `agents-validation-testing` |
| Analysis / layout / runtime errors (active debug) | [`agent_kb/devtools_runtime_errors.md`](../agent_kb/devtools_runtime_errors.md); then `dart-fix-runtime-errors`, `systematic-debugging`, `flutter-fix-layout-issues` |
| Pub dependency / version-sensitive API | [`agent_kb/package_docs_mcp.md`](../agent_kb/package_docs_mcp.md); Context7 `resolve-library-id` + `query-docs`; `user-dart` `read_package_uris` / `rip_grep_packages`; skill `context7-mcp`, `flutter-ai-rules` |
| Supabase schema / migrations | `agents-supabase`; search `ai-safe-supabase-workflow` if available |
| Figma → code | `agents-figma` / `figma-this-repo` |
| Install/trim/sync global skills | `agents-global-skills-setup` when available; otherwise `./bin/agent-maintain install/update/trim` |
| Unknown skill exists? | `find-skills` (vendor) |

Repo skill sources: [`tool/agent_host_templates/shared/skills/`](../../tool/agent_host_templates/shared/skills/) (and `cursor/skills/` for Cursor-only shims). New shared skills must be listed in `tool/agent_asset_lib.sh` for both Cursor and Codex.

## Official Dart/Flutter Skills

Use official skills only for task procedure missing from repo docs:

- Dart tests, CLI, coverage, mocks, analyzer, version conflicts, patterns.
- Flutter widget/integration tests, responsive/layout fixes, routing, l10n,
  JSON/HTTP implementation.
- Search exact names with `./bin/agent-maintain find <task>`.

## Process skills (vendor; use when trigger matches)

| Trigger | Skill |
| --- | --- |
| Ambiguous feature / scope unclear | `brainstorming` |
| Multi-step work before coding | `writing-plans` |
| Bug / test failure / unexpected behavior | `systematic-debugging` |
| Before claiming done / commit / PR | `verification-before-completion` |
| New logic or bugfix with tests requested | `test-driven-development` |

## Repo validation overrides

Skills do not replace repo scripts. Prefer:

- Fast sanity: `./bin/checklist-fast`
- Feature validation: [`docs/engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
- Integration: `./bin/integration_tests` (not only `flutter-add-integration-test`)
- Agent docs changed: `./tool/check_agent_knowledge_base.sh`

## Related

- Context ladder: [`context_loading.md`](context_loading.md)
- Memory / vendor shims: [`agent_kb/memory_and_context_ladder.md`](../agent_kb/memory_and_context_ladder.md)
- Governance roles: [`governance.md`](governance.md)
