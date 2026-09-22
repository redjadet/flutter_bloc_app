# PR decision handoff guidance

**Date:** 2026-09-22  
**Scope:** Documentation only (PR contract + review/agent guidance).

## Why

Code can be traceable while its safety conditions remain unknown to teammates.
An incident involving retries, partial success, or similar behavior can then
depend on the author's memory or an inaccessible AI conversation. Shipping code
quickly is insufficient when others cannot safely maintain and operate it.

## Decision

For consequential changes, the PR contract now calls for a short decision note:
the invariant that must remain true, the failure modes and recovery behavior,
and a tempting alternative rejected for a concrete reason. The GitHub PR
template surfaces those fields; non-consequential PRs use `N/A — <reason>`.
The review playbook asks reviewers to verify that note against code and proof.
The operating manual defines success in terms of team understanding and safe
recovery.

Keep details proportional to risk. Link durable repo documentation when the
reasoning must outlive the PR; do not make AI chat the only record.

## Owners updated

- [`.github/pull_request_template.md`](../../.github/pull_request_template.md) — Decision note section
- [`docs/git_and_branching_strategy.md`](../git_and_branching_strategy.md) — PR contract + N/A rule
- [`docs/review/code_review_playbook.md`](../review/code_review_playbook.md) — reviewer check
- [`docs/ai/agent_operating_manual.md`](../ai/agent_operating_manual.md) — communicate / recheck

## Scope

Documentation only. No application behavior or validation tooling changed.
