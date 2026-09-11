# Senior engineering judgment guidance (2026-09-11)

Repair living reduce-surprise / review ownership so P1–P7 decisions have
repository-specific boundaries, exceptions, owners, and honest enforcement
labels. Documentation only.

## Decisions

- Deep owners: P1/P4 → [`bloc_standards.md`](../bloc_standards.md); P3/P5 →
  [`use_case_dto_policy.md`](../architecture/use_case_dto_policy.md); P6 →
  reliability + observability + logging; P7 → review playbook + git strategy.
- Spine ([`reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md))
  holds the decision table and thin links.
- Replace universal ≤400 LOC mandate with coherence / reversibility / review
  burden; size remains a non-blocking prompt.
- Keep June
  [`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md)
  immutable.
- Update gold exemplars per Codex pre-build keep/replace/drop evidence, then
  re-narrow after Codex implementation review: staff `messageFor`, IoT
  `toString` detail, and Counter `unknown` raw message are **not** gold.
- Do not promote AP-11 warn scan to a fail gate; record tool root repair as
  deferred outside this change.

## Rejected

- New top-level “senior patterns” document
- Copying Medium article examples as canon
- Universal always-early-return / always-sealed / always-mapper language
- Rewriting June audit; AGENTS.md prose expansion; Dart/tool/CI edits

## Files

- [`docs/architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md)
- [`docs/bloc_standards.md`](../bloc_standards.md)
- [`docs/review/architecture_checklist.md`](../review/architecture_checklist.md)
- [`docs/review/bloc_checklist.md`](../review/bloc_checklist.md)
- [`docs/review/code_review_playbook.md`](../review/code_review_playbook.md)
- [`docs/git_and_branching_strategy.md`](../git_and_branching_strategy.md)
- [`docs/bloc/cubit_file_template.md`](../bloc/cubit_file_template.md)
- [`docs/README.md`](../README.md)
- [`docs/audits/senior_engineering_judgment_guidance_review_2026-09.md`](../audits/senior_engineering_judgment_guidance_review_2026-09.md)
- [`docs/audits/README.md`](../audits/README.md)
- this change note + [`docs/changes/README.md`](README.md)

## Verification

Worktree: `../flutter_bloc_app-senior-judgment-guidance` on
`codex/senior-judgment-guidance` @ baseline `0c6c708…`.

```bash
git diff --check
bash tool/check_docs_gardening.sh --paths \
  docs/architecture/reduce_surprise_patterns.md \
  docs/bloc_standards.md \
  docs/review/architecture_checklist.md \
  docs/review/bloc_checklist.md \
  docs/review/code_review_playbook.md \
  docs/git_and_branching_strategy.md \
  docs/audits/senior_engineering_judgment_guidance_review_2026-09.md \
  docs/audits/README.md \
  docs/bloc/cubit_file_template.md \
  docs/README.md \
  docs/changes/2026-09-11_senior_engineering_judgment_guidance.md \
  docs/changes/README.md
./tool/check_agent_knowledge_base.sh
./bin/checklist-fast --no-reuse
./bin/agent-maintain closeout
```

Results:

- `git diff --check` — pass
- Scoped `check_docs_gardening.sh` — pass
- `check_agent_knowledge_base.sh` — pass
- `checklist-fast --no-reuse` — **fail (pre-existing on main)**:
  `check_ai_snapshot_freshness` reports `ai/CONTEXT_MAP.md` and
  `ai/reports/*` `git_head` `076b1a0…` ≠ HEAD `0c6c708…`. Same failure on clean
  main worktree without this docs change. Plan excludes `ai/reports/**` edits;
  snapshot regen is a separate follow-up.
- `agent-maintain closeout` — pass (managed host asset drift warning only;
  templates out of this docs write-set; no host sync applied)
- Codex delegate review (`gpt-5.6-sol`) — two Major gold-exemplar findings
  fixed in spine/audit; Minor stale closeout wording fixed here

## Residual risk / follow-up

- Live two-reviewer walkthrough of plan scenarios 1–7 after PR review
- Repair `tool/check_domain_wire_leaks.sh` app root (deferred tooling)
- Refresh stale `ai/` snapshot `git_head` metadata (harness hygiene; not this PR)
- Next edit of mobile–backend boundaries doc: replace mismatched warn-scan cite
