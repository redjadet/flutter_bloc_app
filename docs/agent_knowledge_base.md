# Agent Knowledge Base

This document is the source of truth for how AI agents should discover and use
repo knowledge. The goal is progressive disclosure: start with a small stable
map, then open the narrow source that answers the current task.

## Core Beliefs

| Belief | Repo rule |
| --- | --- |
| Context beats instructions. | Ground work in real files, current docs, current diff, and repo scripts before implementing. |
| Planning and execution are separate. | Non-trivial work starts with a tracker plan before edits. |
| Feedback loops are mandatory. | AI output stays draft until review gate plus scope-matched validation pass. |
| One unit at a time. | Pick the smallest coherent slice, finish it, verify it, then move on. |
| The codebase is the knowledge base. | Durable context lives in versioned repo docs, plans, tests, scripts, and ADRs. |
| Harness parts should be deletable. | Keep host assets thin and remove stale rules when validation proves they no longer help. |
| Missing capability beats retrying harder. | When an agent struggles, add a legible doc, tool, test, fixture, or script so the next run can succeed. |
| Enforce invariants, not taste micromanagement. | Encode boundaries and reliability rules mechanically while leaving local implementation freedom. |

## Progressive Disclosure

Agents should not load the whole repository handbook up front.

1. Read [`AGENTS.md`](../AGENTS.md) for the map.
2. Read this document for knowledge-base layout and harness rules.
3. Read [`ai_code_review_protocol.md`](ai_code_review_protocol.md) for the
   review gate.
4. Use [`agents_quick_reference.md`](agents_quick_reference.md) only for command
   lookup.
5. Use [`README.md`](README.md) to find task-specific docs.
6. Open only task-specific docs, code, tests, and plans needed for the current
   slice.

## Agent Legibility

Agents can only reason over what they can inspect during the run. Make product,
runtime, and quality signals visible inside the repo or through repo scripts.

- Prefer app-visible proof for user-facing changes: screenshots, widget tests,
  integration flows, route validators, or emulator/browser evidence.
- Prefer repo-local observability and logs over chat-only explanation. If a bug
  requires a log pattern to diagnose, document the command or add a helper.
- Keep fixtures, schemas, API examples, generated clients, and test harnesses in
  versioned paths so Codex and Cursor see the same truth.
- For UI/runtime work, expose the narrowest runnable surface before asking an
  agent to judge behavior. Route tiles, demo controls, and focused smoke tests
  are harness features, not polish.
- Favor dependencies and abstractions agents can inspect, test, and reason about.
  Stable boring packages are usually better than opaque magic; in-repo helpers
  are justified when they centralize instrumentation or invariants with tests.

## Missing Capability Loop

Do not respond to repeated failure with a larger prompt.

1. Identify the missing capability: context, tool, fixture, test, script,
   ownership boundary, or acceptance criterion.
2. Add it to the repo in the smallest durable place.
3. Validate it directly.
4. Update host templates only if Codex and Cursor need to discover the new
   capability during cold start.
5. Remove old guidance once the mechanical guard makes it redundant.

Examples:

- A recurring route mistake should become a route validation check or route doc,
  not another paragraph in the map.
- A repeated review comment should become an invariant, linter, test helper, or
  source-doc update.
- A UI proof gap should become a runnable smoke path, screenshot expectation, or
  integration journey mapping.

## System Of Record Layout

| Area | Source | Status | Use when |
| --- | --- | --- | --- |
| Docs index | [`README.md`](README.md) | Current index | Finding the right source of truth. |
| Agent harness | [`agent_knowledge_base.md`](agent_knowledge_base.md) | Current policy | Updating agent behavior, host templates, trackers, or validation. |
| Review gate | [`ai_code_review_protocol.md`](ai_code_review_protocol.md) | Current policy | Accepting AI-written code or reporting completion. |
| Commands | [`agents_quick_reference.md`](agents_quick_reference.md) | Current lookup | Choosing repo entrypoints without rereading long docs. |
| Validation routing | [`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md) | Current policy | Picking fast vs full validation. |
| Architecture | [`architecture_details.md`](architecture_details.md), [`clean_architecture.md`](clean_architecture.md), [`adr/`](adr/) | Current design | Touching structure, routing, DI, layers, or feature seams. |
| Quality | [`CODE_QUALITY.md`](CODE_QUALITY.md), [`testing_overview.md`](testing_overview.md), [`validation_scripts.md`](validation_scripts.md) | Current gates | Reviewing risk, test depth, and guardrails. |
| Lifecycle | [`REPOSITORY_LIFECYCLE.md`](REPOSITORY_LIFECYCLE.md), [`reliability_error_handling_performance.md`](reliability_error_handling_performance.md) | Current patterns | Touching async, subscriptions, timers, retry, sync, or background work. |
| Integration journeys | [`engineering/integration_journey_map.md`](engineering/integration_journey_map.md) | Current map | Adding or changing end-to-end flows. |
| Plans | [`plans/README.md`](plans/README.md), [`changes/README.md`](changes/README.md) | Active or historical as labeled | Complex work, execution contracts, and completed rationale. |
| Audits | [`audits/README.md`](audits/README.md) | Historical snapshots | Understanding why a guard exists or finding debt trends. |
| Active host trackers | [`../tasks/codex/todo.md`](../tasks/codex/todo.md), [`../tasks/cursor/todo.md`](../tasks/cursor/todo.md) | Active work state | Non-trivial current task plan, decisions, and validation proof. |
| Repeated lessons | [`../tasks/lessons.md`](../tasks/lessons.md) | Durable corrections | Capturing user corrections that should shape future work. |

## Plans As Artifacts

Small changes can use a lightweight tracker entry. Complex work should use a
versioned plan or change note.

- Active implementation state lives in [`tasks/codex/todo.md`](../tasks/codex/todo.md) or
  [`tasks/cursor/todo.md`](../tasks/cursor/todo.md).
- Durable execution plans live under `docs/plans/` when they are still useful
  for future agents.
- Completed or point-in-time rationale lives under `docs/changes/`.
- Known technical debt belongs in the owning source-of-truth doc, an ADR, or a
  tracked plan; avoid burying it in chat-only context.
- Plans must include goal, scope, write set, edge cases, validation target, and
  decision log when decisions are likely to matter later.

## Harness Controls

Use both feedforward guides and feedback sensors.

| Control | Examples |
| --- | --- |
| Computational guides | Types, layer boundaries, lint rules, check scripts, generated route constants. |
| Inferential guides | This knowledge base, ADRs, feature plans, review protocol, task trackers. |
| Computational sensors | `flutter analyze`, targeted tests, `./bin/checklist`, static guard scripts. |
| Inferential sensors | AI review gate, risk review, explicit cross-host review when the user asks. |

Prefer deterministic sensors first because they are cheaper, faster, and easier
to audit. Use inferential review for business fit, edge cases, architecture, and
behavior that static checks cannot see.

## Invariant Enforcement

This repo should constrain architecture and reliability centrally while leaving
implementation expression local.

- Enforce layer boundaries, routing reachability, lifecycle cleanup, retry/replay
  safety, sync behavior, and validation routing mechanically where possible.
- Write guard-script error messages as remediation instructions for future
  agents.
- Promote repeated review comments into tests, scripts, ADRs, or source docs.
- Do not encode every stylistic preference. A change meets the bar when it is
  correct, maintainable, validated, and legible to future agent runs.
- Keep custom checks narrow and reversible. Delete or relax checks when they stop
  catching real risk.

## Codex And Cursor

Both hosts use the same repository knowledge base.

- Codex should call repo shell entrypoints directly and keep task state in
  [`tasks/codex/todo.md`](../tasks/codex/todo.md).
- Cursor should use thin skills/commands that point back to the same docs and
  keep task state in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md).
- Shared behavior changes start in this document or the owning source doc, then
  sync to host templates with `./tool/sync_agent_assets.sh --apply`.
- Cross-host review is optional and explicit-request-only. It is not a substitute
  for the reporting agent's own review, validation, and self-check.
- Host-specific prompts should be short because the repo already carries the
  context. Use prompts to name the slice, constraints, files to inspect,
  validation, and report fields.

## Final Agent Contract

For Codex and Cursor, the finished harness loop is:

1. Start from the map and open only task-relevant sources.
2. Record non-trivial scope, risks, write set, and validation target in the
   host tracker.
3. Make the task legible before coding: current files, runnable surface,
   fixtures, logs, route proof, or acceptance criteria.
4. Implement the smallest coherent slice inside existing seams.
5. Validate with deterministic checks first, then risk-based review.
6. If the agent hit missing context or repeated review feedback, add a durable
   repo capability before reporting done.
7. Sync host assets when agent behavior changed.
8. Report only after checking the final answer against request, changed files,
   proof, blockers, and residual risk.

## Host Parity

Codex and Cursor should not grow separate operating doctrines.

- Source docs own behavior. Host templates only summarize and route.
- When changing agent behavior, update the owning source doc first.
- If the behavior affects command choice, update
  [`agents_quick_reference.md`](agents_quick_reference.md).
- If the behavior affects acceptance of AI-written work, update
  [`ai_code_review_protocol.md`](ai_code_review_protocol.md).
- If the behavior affects host cold start, update both Codex and Cursor
  templates under `tool/agent_host_templates/`.
- After host-template changes, run sync apply, dry-run, and drift checks in
  sequence.
- Do not add a Cursor-only or Codex-only workaround unless the host capability
  truly differs; document that difference in the template, not the source rule.

## Mechanical Enforcement

The knowledge base is validated by repo tooling:

- `./tool/check_agent_knowledge_base.sh` keeps local [`AGENTS.md`](../AGENTS.md) short when it
  is present and always checks required cross-links and source-of-truth indexes.
- `./tool/validate_validation_docs.sh` keeps validation docs aligned with
  checklist scripts.
- `./tool/normalize_doc_links.py` keeps local doc links clickable.
- `./tool/check_agent_asset_drift.sh` checks managed Cursor/Codex assets against
  repo templates.
- `./bin/checklist` runs the full gate; `./bin/checklist-fast` is local-only for
  clean trees or narrow docs/tooling changes.
- `.original.md` compression backups are temporary. Delete them after verifying
  the active docs are present and correct.

When adding a new durable agent rule, update the owning source doc first, then
thin host templates, then validation if the rule should be mechanically checked.

## Doc Gardening

Agents should garden docs as part of touched work, not as a separate memory
dump.

- If behavior changes, update the owning source-of-truth doc in the same change.
- If a plan becomes obsolete, mark it historical or move durable decisions into
  an ADR/source doc.
- If a doc contradicts code, trust code plus tests first, then repair the doc.
- If a rule no longer earns its keep, remove it from host templates and keep the
  source doc smaller.
- Keep cleanup continuous and small. Prefer targeted guardrails and tiny
  refactors over periodic large "AI cleanup" sweeps.
- Track golden principles in source docs or checks, then let agents apply them
  repeatedly without re-litigating the same review comments.
- For broad doc-gardening sweeps, run targeted markdown/link checks and escalate
  to `./bin/checklist` when validation or agent policy changes materially.
