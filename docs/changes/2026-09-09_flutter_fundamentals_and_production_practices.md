# Flutter fundamentals and production practices doc

## Why

Interview and onboarding questions about widgets, state libraries, hot
reload/restart, offline, performance, team structure, and unreproducible
crashes were answered across many owner docs. Needed one synthesis that cites
**this repo’s** seams and shipped stories without duplicating those owners.

## Change

- Added
  [`engineering/flutter_fundamentals_and_production_practices.md`](../engineering/flutter_fundamentals_and_production_practices.md):
  Part 1 (Stateless vs Stateful, widget/element/render trees, setState vs
  Provider/Riverpod/Cubit-BLoC, hot reload vs restart, “everything is a
  widget”); Part 2 (offline Counter + Social Feed, Todo measurement-gated
  perf, feature contract/modularity, Crashlytics + macOS EventChannel + web
  startup stories).
- Indexed from [`docs/README.md`](../README.md),
  [`engineering/README.md`](../engineering/README.md),
  [`case_studies/README.md`](../case_studies/README.md),
  [`interview_showcase.md`](../interview_showcase.md), and
  [`new_developer_guide.md`](../new_developer_guide.md).

## Ownership

Synthesis hub only. Deep rules stay in `bloc_standards`, offline_first ADR/guides,
performance case studies, modularity, and Crashlytics runbook.

## Validation

```bash
bash tool/check_docs_gardening.sh --paths \
  docs/engineering/flutter_fundamentals_and_production_practices.md \
  docs/engineering/README.md \
  docs/case_studies/README.md \
  docs/interview_showcase.md \
  docs/new_developer_guide.md \
  docs/README.md \
  docs/changes/2026-09-09_flutter_fundamentals_and_production_practices.md \
  docs/changes/README.md
./bin/agent-maintain closeout
```

## Review

- Codex CLI (`request_codex_feedback` / `codex exec`) hit ChatGPT usage limit
  before a final findings payload; no Codex findings returned.
- Pre-merge pass applied: complete code sample, Social Feed simulated-scope
  caveat, Riverpod decision pointer to `state_management_choice` + ADR 0001;
  relative links verified present.
