# Flutter SDK Mutation Guard

AI agents must not patch core Flutter/Dart SDK or framework sources to fix app
issues. The pinned toolchain is an external dependency; local edits under
`/Users/ilkersevim/Flutter_SDK/flutter/**` create unreproducible builds and hide
real repo defects.

Current rule owners:

- [`AGENTS.md`](../../AGENTS.md) Must Keep
- [`agent_project_context.md`](../agent_project_context.md) Current Caveat Shortlist
- [`ai_failure_risks.md`](../ai/ai_failure_risks.md) `RISK-FLUTTER-SDK-MUTATION`
- `agents-common-pitfalls` shared host skill

Allowed paths: repo-owned code, tests, docs, tool scripts, adapters/workarounds,
or a documented dependency/toolchain upgrade flow. If SDK files are already
dirty, stop and restore the toolchain from clean source with user approval before
continuing repo work.
