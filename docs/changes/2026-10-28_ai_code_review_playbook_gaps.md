# AI code review playbook gaps (DONE / proof / Spec–Standards / 3-round)

## Summary

Tighten [`docs/review/code_review_playbook.md`](../review/code_review_playbook.md)
with result-style pass/fail checks, proof-before-diff, Spec vs Standards
findings, risk → human reading depth, fresh-session second opinion, and a
three-round rethink stop. Point
[`docs/ai_code_review_protocol.md`](../ai_code_review_protocol.md) at those
named playbook anchors. Does not redo #1067 Flutter slip classes.

## Why

External five-step AI review playbook (result checks → risk → proof → second
opinion → learn/stop) already matched most of this repo’s review owners; the
gaps were operational: author evidence before deep code reading, Spec vs
Standards separation, and a hard stop after three non-converging fix rounds.

## Proof

- Docs-only: `bash tool/check_docs_gardening.sh` on touched paths when available
- `./bin/checklist-fast --no-reuse` / agent closeout as required for docs PRs
