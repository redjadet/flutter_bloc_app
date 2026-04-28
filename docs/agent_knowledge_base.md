# Agent Knowledge Base

Source of truth for how agents find/use repo knowledge. Goal: progressive disclosure; start from map, open only task-needed files.

## Core Beliefs

| Belief | Repo rule |
| --- | --- |
| Context beats instructions. | Ground in real files, current docs, current diff, repo scripts. |
| Plan != execute. | Non-trivial work starts with tracker plan before edits. |
| Feedback loops mandatory. | AI output draft until review gate + scope-matched validation. |
| Closed loop by default. | Plan once, execute end-to-end, verify, report proof. |
| Goals beat activity. | Vague asks need success criteria before code. |
| One unit at time. | Small coherent slice, finish, verify, move on. |
| Codebase = knowledge base. | Durable context lives in versioned docs/plans/tests/scripts/ADRs. |
| Knowledge should compound. | File reusable conclusions back into owning repo memory instead of leaving them in chat. |
| Harness parts deletable. | Host assets thin; delete stale rules once validation proves redundant. |
| Missing capability beats retry. | If stuck, add doc/tool/test/fixture/script so next run succeeds. |
| Timing matters. | Add abstraction/features only when current need justifies them. |
| Enforce invariants, not taste. | Encode boundaries + reliability mechanically; keep local freedom. |

## Progressive Disclosure

Don’t load the whole handbook up front.

1. Read [`AGENTS.md`](../AGENTS.md) for map.
2. Read this document for knowledge-base layout and harness rules.
3. Read [`ai_code_review_protocol.md`](ai_code_review_protocol.md) for review gate
   and AI-generated-code risk matrix; route helper details through
   [`validation_scripts.md`](validation_scripts.md).
4. Use [`agents_quick_reference.md`](agents_quick_reference.md) for command lookup.
5. Use [`README.md`](README.md) for task-specific docs.
6. Open only docs/code/tests/plans needed for current slice.

## Adaptive Execution

Scale process to task value; avoid max-depth, broad validation, or delegation by default.

1. Classify task by complexity, risk, scope, and uncertainty.
2. Calibrate effort: local mechanical = light; cross-system/ambiguous/high-risk = deeper plan + review.
3. Plan once (<=10 lines for normal tasks), then execute end-to-end.
4. Ask only on hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confidence, or user-owned product decision.
5. Do not edit until 95% confident in goal/scope/approach; ask until clear.
6. For vague asks, name assumptions, success criteria, and the smallest verifiable slice before coding.
7. If interpretations change behavior/blast radius, surface them. Ask when needed; otherwise make lowest-regret call and record tradeoff.
8. Non-trivial: compare 2-3 approaches; pick lowest-regret by correctness, maintainability, reversibility, blast radius, and failure tolerance.
9. Debug root cause: reproduce/reason, isolate, fix cause, verify. If unsure,
   say so + narrow search space.
10. Before report, predict failures: assumptions, edge cases, scale, side effects, maintenance cost. Harden material risks.
11. Stop when value is met, major risks are handled, proof matches scope, and more work mostly adds cost.

## Agent Legibility

Agents reason over inspectable state. Make product/runtime/quality signals visible in repo or repo scripts.

- Prefer app-visible proof: screenshots, widget tests, integration flows, route validators, emulator/browser evidence.
- Prefer repo-local observability/log helpers over chat-only claims.
- Keep fixtures, schemas, API examples, generated clients, and test harnesses versioned so Codex and Cursor see the same truth.
- For UI/runtime work, expose the narrowest runnable surface first: route tile, demo control, smoke test, or fixture.
- Prefer inspectable dependencies/abstractions. In-repo helpers earn their keep by centralizing instrumentation or invariants with tests.

## Missing Capability Loop

Don’t answer repeated failure with bigger prompt.

1. Identify missing capability: context, tool, fixture, test, script,
   ownership boundary, or acceptance criterion.
2. Add it to repo in smallest durable place.
3. Validate it directly.
4. Update host templates only if Codex/Cursor need cold-start discovery.
5. Remove old guidance once mechanical guard makes it redundant.

Examples:

- recurring route mistake -> route validation check or route doc
- repeated review comment -> invariant, linter, test helper, or source-doc update
- UI proof gap -> runnable smoke path, screenshot expectation, or integration map

## Memory Compounding

Useful agent work should leave the next session smarter without growing a broad
wiki.

- Treat source docs, ADRs, plans, changes, tests, scripts, fixtures, and host
  trackers as the compiled memory layer.
- File reusable conclusions into the owning source doc, `docs/changes/`,
  `docs/plans/`, or [`../tasks/lessons.md`](../tasks/lessons.md). Keep
  transient execution state in host trackers.
- Preserve source-of-truth boundaries: code/tests beat generated summaries;
  source docs beat host templates; human/user corrections beat inferred rules.
- Do not dump chat transcripts or generic summaries into docs. Add only compact,
  cited, task-relevant facts that future agents can act on.
- Prefer fat skills only for repeated, validated workflows with clear triggers,
  write scope, tools, and quality bar. Do not add cron/autonomous behavior
  without explicit user approval.
- For large or fast-changing external corpora, use retrieval/search. For this
  repo, prefer maps, `rg`, code-review-graph, and targeted validation over a
  separate RAG layer.
- Semantic lint during doc/agent changes: check for stale plans, duplicate
  rules, contradictions between [`AGENTS.md`](../AGENTS.md), source docs, and host templates,
  and reusable conclusions still stranded in task notes.

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

Small changes can use tracker notes. Complex work should use versioned plan/change note.

- Active state lives in [`tasks/codex/todo.md`](../tasks/codex/todo.md) or [`tasks/cursor/todo.md`](../tasks/cursor/todo.md).
- Trackers follow [`engineering/task_tracker_template.md`](engineering/task_tracker_template.md).
- Durable execution plans live under `docs/plans/` while useful for future agents.
- Completed or point-in-time rationale lives under `docs/changes/`.
- Known debt belongs in owning source doc, ADR, or tracked plan; not chat-only.
- Plans include goal, scope, write set, edge cases, validation target, and decision log when decisions matter later.

## Harness Controls

Use both feedforward guides and feedback sensors.

| Control | Examples |
| --- | --- |
| Computational guides | Types, layer boundaries, lint rules, check scripts, generated route constants. |
| Inferential guides | This knowledge base, ADRs, feature plans, review protocol, task trackers. |
| Computational sensors | `flutter analyze`, targeted tests, `./bin/checklist`, static guard scripts. |
| Inferential sensors | AI review gate, risk review, explicit cross-host review when the user asks. |

Prefer deterministic sensors first: cheaper, faster, easier to audit. Use inferential review for business fit, edge cases, architecture, and behavior that static checks cannot see.

## Invariant Enforcement

Constrain architecture/reliability centrally; leave implementation expression local.

- Enforce layer boundaries, routing reachability, lifecycle cleanup, retry/replay safety, sync behavior, and validation routing mechanically where possible.
- Write guard-script errors as remediation instructions for future agents.
- Promote repeated review comments into tests, scripts, ADRs, or source docs.
- Promote reusable conclusions into durable repo memory after verification, not
  before.
- Surgical diffs. Changed lines trace to user request or required validation/doc updates.
- Don’t encode every stylistic preference. Change meets bar when correct, maintainable, validated, and legible to future agents.
- Keep custom checks narrow/reversible. Delete or relax when no longer catching risk.

## Codex And Cursor

Both hosts use same repository knowledge base.

- Codex calls repo shell entrypoints directly and tracks work in [`tasks/codex/todo.md`](../tasks/codex/todo.md).
- Cursor uses thin skills/commands pointing back here and tracks work in [`tasks/cursor/todo.md`](../tasks/cursor/todo.md).
- Shared behavior changes start in this document or owning source doc, then sync host templates with `./tool/sync_agent_assets.sh --apply`.
- Cross-host review is optional, explicit-request-only, and never replaces own review/validation/self-check.
- Host prompts stay short: name slice, constraints, files to inspect, validation, report fields.

## Final Agent Contract

For Codex and Cursor, finished loop:

1. Start from map and open only task-relevant sources.
2. Record non-trivial scope, risks, write set, validation target in host tracker.
3. Make task legible before coding: current files, runnable surface, fixtures, logs, route proof, or acceptance criteria.
4. Implement smallest coherent slice inside existing seams and keep moving until blocker/proof.
5. Validate deterministic checks first, then risk-based review.
6. If context/review failure repeats, add durable repo capability before reporting done.
7. Sync host assets when agent behavior changed.
8. Report after checking final answer against request, changed files, proof,
   blockers, residual risk.

## Host Parity

Codex and Cursor should not grow separate operating doctrines.

- Source docs own behavior. Host templates only summarize and route.
- When changing agent behavior, update owning source doc first.
- If behavior affects command choice, update [`agents_quick_reference.md`](agents_quick_reference.md).
- If behavior affects accepting AI-written work, update [`ai_code_review_protocol.md`](ai_code_review_protocol.md).
- If behavior affects host cold start, update both Codex and Cursor templates under `tool/agent_host_templates/`.
- After host-template changes, run sync apply, dry-run, and drift checks in sequence.
- Don’t add Cursor-only/Codex-only workaround unless host capability truly differs; document difference in template, not source rule.

## Mechanical Enforcement

Knowledge base is validated by repo tooling:

- `./tool/check_agent_knowledge_base.sh` keeps local [`AGENTS.md`](../AGENTS.md) short and checks required links, source indexes, host-template pointers, and closed-loop invariants.
- `./tool/check_agent_memory_compounding.sh` keeps memory-compounding guidance
  automatic, source-aligned, and explicit-approval-gated for autonomous action.
- `./tool/validate_validation_docs.sh` keeps validation docs aligned with checklist scripts.
- `./tool/normalize_doc_links.py` keeps local doc links clickable.
- `./tool/check_agent_asset_drift.sh` checks managed Cursor/Codex assets against
  repo templates.
- `./bin/checklist` runs full gate; `./bin/checklist-fast` is local-only for clean trees or narrow docs/tooling changes.
- `.original.md` compression backups are temporary. Delete after verifying active docs.

New durable agent rule: update owning source doc first, then thin host templates, then validation if the rule needs mechanical check.

## Doc Gardening

Agents garden docs as part of touched work, not separate memory dump.

- If behavior changes, update owning source-of-truth doc in same change.
- If plan becomes obsolete, mark it historical or move durable decisions into
  ADR/source doc.
- If doc contradicts code, trust code plus tests first, then repair doc.
- If tracker notes contain reusable conclusions, move them to the owning source
  doc, `docs/changes/`, or [`tasks/lessons.md`](../tasks/lessons.md) before closing the task.
- If rule no longer earns its keep, remove it from host templates and keep
  source doc smaller.
- Keep cleanup continuous/small. Prefer targeted guardrails/tiny refactors over periodic large "AI cleanup" sweeps.
- Track golden principles in source docs or checks so agents do not re-litigate the same review comments.
- For broad doc-gardening sweeps, run targeted markdown/link checks; escalate to `./bin/checklist` when validation or agent policy changes materially.
