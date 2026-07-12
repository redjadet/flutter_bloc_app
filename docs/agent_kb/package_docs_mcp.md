# Package docs via MCP (agents)

Back: [Tool orchestration](tool_orchestration.md) · [Agent quick reference](../agents_quick_reference.md)

Agents **must not guess** package or platform APIs from model memory when MCP can fetch current docs or the repo’s pinned dependency source. Training data is often stale; this repo pins versions in `pubspec.yaml` / `pubspec.lock`.

Mitigates **RISK-STALE-API** ([`ai/ai_failure_risks.md`](../ai/ai_failure_risks.md)).

## When to use

- Adding or changing code that calls a **pub dependency** (Flutter, Dart, or plugin).
- API looks unfamiliar, deprecated, or version-sensitive (`go_router`, `bloc`, `dio`, `freezed`, Firebase, Supabase, etc.).
- User asks for “latest” API, migration, or setup for a library.
- Analyzer errors mention missing members — verify against **pinned** package source, not memory.

Skip for pure repo-owned code under `lib/` when local conventions and references suffice.

## Prerequisites

Enable in Cursor MCP ([`agent_environment_setup.md`](../agent_environment_setup.md)):

| Server | Role |
| --- | --- |
| Dart MCP (`dart`; some hosts show `user-dart`) | Read **resolved** package source in the workspace (`read_package_uris`, `rip_grep_packages`, `pub_dev_search`) |
| Context7, when installed | Current library docs and examples (`resolve-library-id` → `query-docs`) |
| Ref/browser/web, when available | Official documentation lookup and URL reads |

Server display names vary by host. Discover available capabilities first; do
not fail the task because a documented label differs.

Prefer MCP over generic web search for library documentation.

## Authority order

1. **Repo canon** — [`AGENTS.md`](../../AGENTS.md), feature docs, [`agents-references`](../../tool/agent_host_templates/shared/skills/agents-references/SKILL.md), existing usage in `lib/`.
2. **Pinned version** — `pubspec.yaml` / `pubspec.lock` (implement against what the project resolves, not “latest on pub.dev”).
3. **Tool evidence** — resolved dependency source + current official docs (cite what you used).
4. **Model memory** — only when MCP unavailable; say so and narrow scope.

## Workflow

Copy and execute in order:

1. **Pin the dependency**
   - Read `pubspec.yaml` (and lockfile if needed) for package name + version constraint.
   - Grep repo for existing patterns: `lib/` imports of that package.

2. **Read resolved package source (Dart MCP)**
   - `read_package_uris` — open `package:<name>/<path>.dart` (API entrypoints, typedefs, extensions).
   - `rip_grep_packages` — search dependency `lib/` for symbol names, deprecated annotations, examples.
   - Use project root as `file:///` URI (same as other Dart MCP tools).

3. **Fetch current library docs**
   - `resolve-library-id` with library name + task context (unless user gave `/org/project` or `/org/project/version`).
   - `query-docs` with a **specific** question (good: “GoRouter redirect API with refreshListenable in v14”; bad: “routing”).
   - Limit repeated `query-docs` calls; synthesize once you have enough to implement.
   - If Context7 is unavailable, use official package/platform docs through the available ref/browser/web capability.

4. **Optional: ref/browser**
   - When you need official doc URLs or exact pages, use the available documentation/browser tool.

5. **Discover alternatives (if needed)**
   - `pub_dev_search` on Dart MCP for package discovery or `dependency:<name>` queries.

6. **Implement and verify**
   - Match repo architecture (Clean Architecture, Cubit/BLoC, DI).
   - Run `analyze_files` or `./tool/analyze.sh` on touched paths.
   - Add/update tests when behavior is non-trivial.

## Tool cheat sheet

| Goal | MCP |
| --- | --- |
| Read `.dart` from a dependency | Dart MCP → `read_package_uris` |
| Find symbol in dependency source | Dart MCP → `rip_grep_packages` |
| Current docs + examples | Context7 → `resolve-library-id`, `query-docs` |
| Official doc URL content | `ref_search_documentation`, `ref_read_url` |
| Search pub.dev | Dart MCP → `pub_dev_search` |
| Static check after edit | Dart MCP → `analyze_files` |

## Do not

- Invent constructors, parameters, or renamed APIs without MCP or repo evidence.
- Assume “latest pub.dev” when the lockfile pins an older major.
- Replace repo conventions with generic tutorial code from docs.
- Load entire package trees into context — read targeted files/sections only.

## Skills

- `context7-mcp` (plugin) — Context7 tool usage.
- `flutter-ai-rules` — official Flutter/Dart AI rules when Context7 is insufficient.
- `agents-feature-delivery` — wire DI/routes/l10n after package integration.
- `agents-validation-testing` — validation after API changes.

Cursor command: `/package-docs` (template under `tool/agent_host_templates/cursor/commands/`).
