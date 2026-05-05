# Codex bootstrap for Flutter BLoC app

Use repo-local canon + shell entrypoints first. This bootstrap is map only;
structured docs under `docs/` are system of record.
Repo source map is root `AGENTS.md`; this file is synced Codex host
bootstrap template, copied to `~/.codex/AGENTS.md` and Codex worktrees.

## Read first

1. `AGENTS.md`
1. `docs/agent_knowledge_base.md`
1. `docs/ai_code_review_protocol.md`
1. `docs/agents_quick_reference.md` for command lookup
1. task-specific docs from `docs/README.md`

## Codex route

- **`flutter-bloc-app-quick-reference`**: orientation, commands, explicit-only cross-host review pointer.
- **`flutter-bloc-app-delivery-workflow`**: non-trivial delivery through proof, including subagent rules.

Details live in `docs/agents_quick_reference.md` and
`docs/engineering/validation_routing_fast_vs_full.md`.

## Default loop

1. **Plan:** Understand business goal; open only relevant docs.
2. **Plan:** For non-trivial existing-code work, use context ladder: map docs -> durable memory -> code-review-graph -> targeted raw files.
3. **Plan:** Plan once (<=10 lines for normal tasks), then execute end-to-end.
4. **Plan:** Ask only on hard blockers: missing credentials/tooling, unsafe ambiguity below 95% confidence, or user-owned product decision.
5. **Plan:** For non-trivial work, keep plan and verification in `tasks/codex/todo.md`.
6. **Execute:** Implement inside existing repo seams.
7. **Verify:** Apply AI review gate before trusting draft output.
8. **Verify:** Run smallest honest repo validation.
9. **Verify:** Self-check final response vs request, diff, proof, blockers, risk.
10. **Report:** Prove result before calling work done.

## Operating defaults

- Use repo shell entrypoints directly; don't invent Codex-only command layers.
- Prefer smallest reversible change satisfying business goal + reliability bar.
- Don't change files until at least 95% confident in goal/scope/approach.
- If business intent/safe scope materially ambiguous, ask or document tradeoff.
- Design for scale when touching shared architecture, routing, sync, lifecycle, security, CI, validation, or operational load.
- Shared state belongs in Cubit/BLoC. Keep business rules out of widgets.
- Use `WidgetTester.view` for widget-test viewport/pixel-ratio setup; avoid
  deprecated `tester.binding.window` test-value APIs.
- Capture repeated user corrections in `tasks/lessons.md`.
- Repeated struggle => add missing repo capability, not longer prompt.
- File verified reusable conclusions into source doc, `docs/changes/`, `docs/plans/`, or `tasks/lessons.md`; don't leave chat-only.
- For agent/docs changes, semantic-lint stale plans, duplicate rules, source/host-template contradictions.
- Surgical diff: changed lines trace to request or required validation/doc update.
- UI/app changes prefer app-visible proof over logs-only claims.
- Docs-only changes still need validation; agent/docs changes should run
  `./tool/check_agent_knowledge_base.sh`.
- Agent behavior changes start in source docs, then sync both Codex and Cursor host templates; don't fork host doctrine unless capabilities differ.
- Host-template changes validate `./tool/check_agent_asset_drift.sh` and
  `./tool/sync_agent_assets.sh --dry-run`.
- Don't invoke `./tool/request_codex_feedback.sh` from Codex unless user explicitly asks for second opinion or cross-host review.
- Scale reasoning depth to task complexity; don't default max for local/low-risk work.

Communication style:

- Keep commentary short and decision-oriented.
- Prefer: current step, notable finding, next validation, blocker if any.
- Put durable tradeoffs, assumptions, and residual risks in `tasks/codex/todo.md` for non-trivial work.
