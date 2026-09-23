<!-- markdownlint-disable MD041 -->
## Summary

<!-- What and why -->

## Accountability

- Intended outcome:
- Human verdict: approve / revise / block
- Why safe: evidence and commands
- If wrong: detection signal, blast radius, rollback
- Owner: person accepting consequence

## Decision note

<!-- Required for consequential behavior/design changes (retry, concurrency,
     offline merge, migration, auth, recovery). Otherwise write
     `N/A — <reason>` (for example docs-only or dependency bump).
     Canon: docs/git_and_branching_strategy.md § Pull request contract -->

- Must remain true:
- Failure modes / recovery:
- Rejected alternative:

## Validation

<!-- Link the feature brief when it contains the contract. Use N/A with a
     reason for docs-only or mechanical changes. -->

- Behavior contract: invariant, boundary/invalid input, failure behavior (or link)
- Adversarial proof: focused test paths/results; generated property or reference check when useful (or N/A with reason)
- Commands and exact results:
- Changed tests: removed/skipped/weakened assertions or mocks replacing the behavior under test, with reason (or none)
- Full diff: unexpected files, dependency/lockfile, config, and CI changes reviewed (or none)
- Required CI checks on submitted PR head: reviewer confirms before merge

## Memory / lifecycle

- [ ] N/A — no resource ownership or lifecycle change
- [ ] Reviewed [docs/performance/memory_checklist.md](../docs/performance/memory_checklist.md): every created disposable's life-cycle is explicitly ended; attached applicable proof
