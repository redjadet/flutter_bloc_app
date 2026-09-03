# Skill Routing For AI Agents

Canonical skill picker. Repo canon wins over vendor skill text.

## Start Rule

| Situation | Action |
| --- | --- |
| Non-trivial task start | Read [`ai_failure_risks.md`](ai_failure_risks.md) Pre-Flight; invoke `agents-common-pitfalls`; run `./bin/agent-maintain preflight --intent "<task goal>"` |
| Implementation / refactor / tests / validation / debugging / host setup | Pick a matching skill before edits or broad commands |
| Pure read-only Q&A | Skill optional; use repo docs first |
| Trivial one-line fix with obvious convention | Skill optional only when confidence is at least 95% |
| Unsure | Invoke `agents-skill-routing`, then `./bin/agent-maintain find QUERY` |

Load only the selected skill entrypoint; then follow repo validation overrides.
Full context ladder: [`context_loading.md`](context_loading.md).

## Discovery

```bash
./bin/agent-maintain tools --intent "<task goal>" --paths <files>
./bin/agent-maintain find QUERY # owner or skill still unknown
```

Use global search/install only on explicit host-skill work:
[`agent_environment_setup.md`](../agent_environment_setup.md).

## Repo-First Routing

| Trigger | Skill(s) / owner |
| --- | --- |
| Pre-flight / common mistakes | `agents-common-pitfalls`; owner [`ai_failure_risks.md`](ai_failure_risks.md) |
| Cold start / commands / validation chooser | `agents-quick-reference` |
| Non-trivial delivery / finish gate | `agents-delivery-workflow` |
| Non-trivial coding | `agents-delivery-workflow`; [`agent_operating_manual.md`](agent_operating_manual.md) |
| Plan / delegation reminders | `agents-meta-behavior` (**Cursor template**; Codex: same canon via [`agent_knowledge_base.md`](../agent_knowledge_base.md) + multi-agent hub) |
| Feature code in this repo | `agents-feature-delivery`, then `agents-canonical-rules` + matching child (`architecture`, `async`, `platform`, `presentation`) |
| New feature / external API / DTO / cubit state / sync / typed errors | [`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md), [`architecture/reference_features.md`](../architecture/reference_features.md), then `agents-feature-delivery` + `agents-canonical-rules-architecture` |
| Cubit/BLoC state, lifecycle, side effects, tests | `agents-bloc-standards`, then `agents-validation-testing`; access helper: global `type-safe-bloc-access` (`context.cubit<T>()`) |
| Add new Cubit | `agents-create-cubit`, then `agents-bloc-standards` |
| Flutter baseline / theme / l10n / BLoC access | `agents-canonical-rules-presentation`, `flutter-cross-platform-modern`; global `type-safe-bloc-access` |
| Cross-platform / responsive behavior | `flutter-cross-platform-modern` |
| Checks / regression guards / test routing | `agents-validation-testing` |
| After non-trivial bug fix | `agents-regression-capture` same turn, then `agents-validation-testing` |
| Analysis / layout / runtime errors | [`agent_kb/devtools_runtime_errors.md`](../agent_kb/devtools_runtime_errors.md); `systematic-debugging` + matching Dart/Flutter skill |
| Pub dependency / version-sensitive API | [`agent_kb/package_docs_mcp.md`](../agent_kb/package_docs_mcp.md); Dart MCP + current official docs |
| Supabase schema / migrations | `agents-supabase`; search `ai-safe-supabase-workflow` if available |
| Figma to code | `agents-figma` / `figma-this-repo` |
| Install / trim / sync globals | Prefer `./bin/agent-maintain install/update/trim`; Cursor may use `agents-global-skills-setup` |
| Watch GitHub PR CI and merge when green | `gh-watch-merge-pr` (script: `tool/commit_push_pr_watch_merge_cleanup.sh`); failing checks → global `gh-fix-ci` if installed, else `gh pr checks` / `gh run view --log-failed` |

### Host availability (do not invent skills)

Codex and Cursor are first-class validated hosts. Other AI agents use the same
owner docs and the closest available capability; missing host integration does
not weaken repository safety or validation requirements.

| Kind | Where | Examples |
| --- | --- | --- |
| Shared (Codex + Cursor) | `tool/agent_host_templates/shared/skills/` | `agents-quick-reference`, `agents-delivery-workflow`, `agents-feature-delivery`, `gh-watch-merge-pr`, … |
| Cursor-only templates | `tool/agent_host_templates/cursor/skills/` | `agents-meta-behavior`, `agents-global-skills-setup`, `agents-cursor-integration` |
| Global / vendor | `~/.cursor/skills`, `~/.codex/skills`, `~/.agents/skills` | `type-safe-bloc-access`, `gh-fix-ci`, process skills (`brainstorming`, …) |

Missing on this host → use the **owner doc** or `./bin/agent-maintain find QUERY`; do not block on a Cursor-only skill name.
Parity policy: [`agent_kb/host_parity_and_enforcement.md`](../agent_kb/host_parity_and_enforcement.md).

## Vendor Skills

Use vendor skills only for task-specific procedure absent from repo canon.

Process skills: ambiguous scope -> `brainstorming`; multi-step plan -> `writing-plans`;
bug/test failure -> `systematic-debugging`; before done/commit -> `verification-before-completion`;
new logic/tests -> `test-driven-development`; after bug fix -> `agents-regression-capture`.

## Repo Validation Overrides

- Fast sanity: `./bin/checklist-fast`
- Feature validation: [`validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
- Integration: `./bin/integration_tests`
- Agent docs changed: `./tool/check_agent_knowledge_base.sh`

Related: [`context_loading.md`](context_loading.md), [`governance.md`](governance.md).
