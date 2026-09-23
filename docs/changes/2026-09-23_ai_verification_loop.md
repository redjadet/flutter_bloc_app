# Independent verification for AI-assisted changes

**Date:** 2026-09-23
**Scope:** Testing and review guidance only.

## Why

The repository already runs analysis, tests, and security checks on PRs and has
an independent review playbook. Its feature template did not explicitly require
expected results to come from a requirement or domain contract before code, and
its PR template did not surface adversarial proof or test weakening. A generated
implementation and generated tests can agree on the wrong behavior.

## Decision

- Record the invariant, valid/boundary/invalid inputs, failure behavior, and
  source of expected results in the feature brief before implementation.
- Use focused adversarial cases. Consider bounded generated-input checks for
  pure rules and serializers when an independent property or reference model is
  available; retain minimal failures as named regression tests.
- Review every changed file and changed test. Verify required CI checks on the
  submitted PR head and confirm live GitHub settings require them.
- On 2026-09-23, live `main` branch protection used strict status checks and
  required `build`, `integration-preflight`, `dependency-review`, and
  `scan-pr / osv-scan`. Recheck protection when merging; this is a snapshot.

## Must remain true

Expected behavior must be defined independently of generated code. CI and test
counts cannot replace review of the contract, changed tests, and full diff.

## Failure modes

- Generated tests assert flawed behavior: reviewer compares them with the
  requirement and challenges removed tests, weakened assertions, and mocks.
- A generated input finds a one-off failure: use a reproducible seed and keep
  the counterexample as a focused regression.
- CI is green for an earlier commit, skipped, or not required by protection:
  reviewer checks the submitted head and live merge settings before merge.

## Rejected alternatives

- Mandating property tests for every change: many UI and integration contracts
  are better proved by focused behavior tests.
- Adding Hypothesis or Ruff to the Flutter/Dart validation lane: they are
  Python tools; existing Dart/Flutter checks and PR CI already cover this repo.
- Adding another broad CI job: duplicate execution would not fix a mistaken
  expected result.

## References

- [OWASP Secure Coding with AI](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html)
- [OWASP Secure Code Review](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html)
- [Hypothesis introduction](https://hypothesis.readthedocs.io/en/latest/tutorial/introduction.html)
- [GitHub status checks](https://docs.github.com/en/pull-requests/reference/status-checks)

## Scope

No application code, test implementation, dependency, or CI workflow changed.
