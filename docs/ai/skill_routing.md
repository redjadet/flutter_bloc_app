# Skill Routing For AI Agents

**Canonical** guide for discovering and invoking suitable skills automatically in this repo. Install/update globals: [`agent_environment_setup.md`](../agent_environment_setup.md) and [`operations_host_skills.md`](../validation_scripts/operations_host_skills.md).

## When to invoke a skill

| Situation | Action |
| --- | --- |
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

Official [Dart and Flutter skills](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae) are task blueprints. For this app, prefer **repo** skills (`agents-canonical-rules-*`, `agents-delivery-workflow`, `agents-validation-testing`) over generic vendor architecture/test skills when both apply.

## Discovery (find a skill automatically)

Use in order:

1. **Session skill list** — match user intent to each skill's `description` frontmatter.
2. **This routing table** — choose task category → skill name(s) below.
3. **Repo shim** — invoke `agents-skill-routing` when routing is ambiguous.
4. **Search globals:**

   ```bash
   ./bin/agent-maintain find QUERY
   bash tool/find_global_agent_skills.sh QUERY
   npx skills find QUERY
   npx skills ls -g
   ```

5. **Inventory snapshot** — `docs/audits/skill_inventory_latest.json` (report-only; optional until generated). Regenerate after install/trim: `dart run tool/skill_inventory.dart docs/audits/skill_inventory_latest.json`. If missing, `./bin/checklist-fast` falls back to the newest dated `docs/audits/skill_inventory_*.json`.

Reload Cursor after install/update (**Developer: Reload Window**).

**Host parity:** Cursor and Codex both sync the shim with `name: agents-skill-routing`. Codex path: `~/.codex/skills/flutter-bloc-app-skill-routing/SKILL.md`.

## Automatic selection rule

For any non-trivial task:

1. Normalize the request to task verbs: implement, refactor, test, debug, validate, design, host setup, docs, release.
2. Pick repo skill first if a row below matches.
3. Add official Dart/Flutter skill only when it gives task-specific procedure missing from repo docs.
4. Read only the selected skill's `SKILL.md` (from the session list, routing table, or search) — not every skill upfront — then follow repo validation overrides below.
5. If no route matches, run `./bin/agent-maintain find "<task keywords>"`; if still none, continue from repo docs and report no skill match.

## Repo-first routing (always consider)

| Trigger | Skill(s) |
| --- | --- |
| Cold start / commands / validation chooser | `agents-quick-reference` |
| Non-trivial delivery loop | `agents-delivery-workflow` |
| Plan, delegation, finish gates | `agents-meta-behavior` |
| Feature code in this repo (layers, Cubit, DI, Freezed) | `agents-canonical-rules` → open matching child (`architecture`, `async`, `platform`, `presentation`) |
| Flutter baseline (theme, l10n, BLoC access) | `agents-canonical-rules-presentation`, `flutter-cross-platform-modern`; search `type-safe-bloc-access` if available |
| Cross-platform / responsive / platform behavior | `flutter-cross-platform-modern` |
| Checks, regression guards, test routing | `agents-validation-testing` |
| Analysis / layout / runtime errors (active debug) | `systematic-debugging`, `dart-fix-runtime-errors`, `flutter-fix-layout-issues` |
| Supabase schema / migrations | `agents-supabase`; search `ai-safe-supabase-workflow` if available |
| Figma → code | `agents-figma` / `figma-this-repo` |
| Install/trim/sync global skills | `agents-global-skills-setup` when available; otherwise `./bin/agent-maintain install/update/trim` |
| Unknown skill exists? | `find-skills` (vendor) |

Repo skill sources: [`tool/agent_host_templates/shared/skills/`](../../tool/agent_host_templates/shared/skills/) (and `cursor/skills/` for Cursor-only shims).

## Official Dart skills (`dart-lang/skills`)

| Task | Skill |
| --- | --- |
| Unit tests (`package:test`) | `dart-add-unit-test` |
| CLI / scripts | `dart-build-cli-app` |
| Coverage / LCOV | `dart-collect-coverage` |
| Active app stack trace + hot reload fix | `dart-fix-runtime-errors` |
| Mockito + build_runner mocks | `dart-generate-test-mocks` |
| Matcher → checks migration | `dart-migrate-to-checks-package` |
| `pub get` version conflicts | `dart-resolve-package-conflicts` |
| `dart analyze` / `dart fix --apply` | `dart-run-static-analysis` |
| Switch expressions / patterns | `dart-use-pattern-matching` |

## Official Flutter skills (`flutter/skills`)

| Task | Skill |
| --- | --- |
| Integration tests / `integration_test` | `flutter-add-integration-test` |
| Widget previews (`previews.dart`) | `flutter-add-widget-preview` |
| Widget tests (`WidgetTester`) | `flutter-add-widget-test` |
| Layered UI/Logic/Data (greenfield only; repo rules override here) | `flutter-apply-architecture-best-practices` |
| Responsive layout | `flutter-build-responsive-layout` |
| Overflow / unbounded constraints | `flutter-fix-layout-issues` |
| Manual JSON models | `flutter-implement-json-serialization` |
| GoRouter / `MaterialApp.router` | `flutter-setup-declarative-routing` |
| l10n setup | `flutter-setup-localization` |
| `http` package REST | `flutter-use-http-package` |

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
