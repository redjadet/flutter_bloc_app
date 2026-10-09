# README and human–AI documentation delivery

## Goal

Deliver a concise badges-first README with screenshots last, linked details,
and actionable architecture/intent/edge-case ownership guidance; merge to main
after current-head hosted checks pass.

## Write-set

- `README.md`
- `docs/EVIDENCE.md`
- `docs/README.md`
- `docs/features/README.md`
- `docs/features/screenshots.md`
- `docs/engineering/critical_human_skills.md`
- `docs/ai/human_ai_collaboration.md`
- `docs/ai-sdlc/README.md`
- `docs/ai-sdlc/templates/intent.md`
- `docs/ai-sdlc/templates/spec.md`
- `docs/ai-sdlc/templates/REVIEW.md`
- `docs/changes/2026-10-09_ai_typing_human_focus_triad.md`
- `docs/changes/2026-10-09_readme_concise_entrypoint.md`
- `docs/changes/README.md`
- `tasks/codex/readme-human-ai-docs/todo.md`

## Plan

- [x] Start an isolated worktree from current `origin/main` and carry the eight local documentation refinements into it.
- [x] Shorten README; move the existing role explanation and full gallery into linked owner docs.
- [x] Check links, anchors, image preservation, badge contracts, documentation gates, and rendered layout.
- [ ] Review the full diff, commit, push, and create a pull request.
- [ ] Wait for fresh hosted checks, merge to main, verify the merge, and archive only this task's worktree.

## Risks

- Moving images can break relative paths or lose captions/alternate text.
- Removing badge or scorecard wiring can violate existing deterministic gates.
- Incoming `#reviewer-path` links and the four-path collaboration map must remain valid.
- Generated tests must not become the source of expected behavior; human acceptance still owns intent and risk.
- Shared host tooling has a missing cached Dart MCP executable; report local failures without modifying SDK/cache state.

## Accountability

- Detection signal: broken links/images, badge drift, failed documentation/hosted gates, or docs implying humans stop understanding code.
- Blast radius: repository onboarding and reviewer interpretation; no application runtime changes.
- Acceptance verdict: requested outcome and merge-when-ready authorized by İlker Sevim; implementation self-review passed; merge awaits current-head hosted checks.
- Scope discovered during execution: preserve all gallery images and move existing contribution text to `docs/EVIDENCE.md`.
- Deferred findings: pre-existing managed-host drift and missing cached Dart MCP executable; no host mutation authorized by this documentation task.
- Host: Codex desktop on macOS; implementation and verification performed by Codex.

## Validation command

- `bash tool/check_docs_gardening.sh --paths <changed Markdown files>`
- `AGENT_MEMORY_AUTO_MAINTAIN=0 bash tool/check_agent_knowledge_base.sh`
- `bash tool/check_ai_snapshot_freshness.sh --strict-head`
- `bash tool/check_harness_scorecard_gate.sh`
- `bash tool/update_harness_score_badge.sh --check`
- `bash tool/check_engineering_quality_scorecard_gate.sh --skip-coverage-proof`
- `bash tool/validate_task_trackers.sh --paths tasks/codex/readme-human-ai-docs/todo.md`
- `./bin/checklist-fast --no-reuse`
- `./bin/agent-maintain closeout`
- `git diff --check`
- `gh pr checks <PR> --watch`

## Evidence/result

- Base: `f36c068d72f10e7be12c54098a64697fa09f7d78` (`origin/main`, 2026-10-09).
- Scoped docs gardening, knowledge-base checks, strict snapshot freshness, harness gate/badge, engineering wiring gate, explicit tracker validation, and `git diff --check`: PASS.
- Local Markdown links/anchors/image references: 676 checked across all 15 changed files; PASS.
- GitHub-rendered Markdown preview: desktop and 375px README layouts inspected; no broken images or page-width overflow. All 33 gallery images loaded.
- `./bin/checklist-fast --no-reuse`: FAIL at `check_runtime_errors --self-test`. `dart mcp-server --help` confirms the cached `dart_mcp_server/hosted/1.2.0/bundle/bin/dart_mcp_server` executable is absent. No SDK/cache changes made.
- `./bin/agent-maintain closeout`: PASS; existing managed-host asset drift reported without applying a host sync. Engineering coverage proof omitted by the documented docs-only lane.
- Pull-request creation, current-head hosted checks, and merge: pending at this documentation commit; the PR's submitted head, checks, and final state are the delivery record.
- Dart format, analyze, and Flutter tests: N/A for this documentation-only write-set.
- Historical application/native proof in `docs/EVIDENCE.md` remains dated and unchanged.
