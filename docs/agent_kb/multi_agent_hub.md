# Multi-Agent Hub

Back: [Agent Knowledge Base](../agent_knowledge_base.md)

Cursor uses hub-and-spoke `Task`s only when team improves quality/speed/risk.
Main chat = **Coordinator**; bounded `Task`s = **Specialists**. Specialist
output is **untrusted** until coordinator validates. Artifacts live under
`tasks/cursor/team/<run-id>/`.

## Benefit gate

Use team when >=2 indicators: blast radius, cross-layer read, high-risk logic
(auth/sync/migrations/routing gates), separate implement/review bars, or user
asked plan+implement+verify. Use single for small/local/mechanical. Tie-break:
**single**.

Record one branch in [`tasks/cursor/todo.md`](../../tasks/cursor/todo.md):

```text
Benefit: team - short reason
Benefit: single - short reason
```

Trivial may use `trivial - gate skipped`. Non-trivial = multi-step delivery,
runtime behavior, DI/sync/routes/codegen, unknown blast radius,
plan+implement+verify, or anything gate could reasonably send to team.

## Coordinator

- Owns phase, artifacts, validation, tracker.
- `single`: Plan -> Execute -> Verify -> Report; no `tasks/cursor/team/<run-id>/`.
- `team`: create `tasks/cursor/team/<run-id>/` with goal, findings, plan,
  diff-summary/diff, and review markdown artifacts.
- Spawn with inline context; never path-only when upstream content required.
- Serialize dependent phases; invalidate downstream artifacts after replan.
- Max two Implementer fix loops unless user extends.

## Specialists

- **Researcher** (`explore`, read-only): facts, sources, confidence, stale-risk.
- **Analyst** (`explore`, read-only): write set, risks, validation plan, exact
  codegen commands/paths.
- **Implementer** (`generalPurpose`): plan-scoped edits only.
- **Reviewer** (`code-reviewer`, optional `ce-*`): findings only; coordinator
  validates.

Every spawn: paste goal + canon excerpts + upstream artifacts inline; return
summary + final result + verified artifacts only (no transcript dumps). Redact
tokens/cookies/secrets. No specialist-to-specialist comms.

## Repo-sensitive role matrix

Analyst lists, Implementer respects, Reviewer checks when touched:

- DI/`get_it`: registration, scope, disposal, wiring.
- Dio/HTTP/auth: interceptors, replay, error mapping, token/header flow, storage
  boundary.
- Routes/l10n/codegen: exact commands + generated paths.
- Offline-first/sync: dedupe, debounced resume, no overlapping flush,
  idempotency, user scope.
- Hive migrations: manifest-driven, not semantic diff detection. Runtime
  `getBox()` runs `ensureSchema` when schema set; shape changes still require
  manifest spec bump, fingerprints, migrator/tests.
- Render/FastAPI/deploy: env contract, timeout, auth assumptions; never leak
  secrets.
