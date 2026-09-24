# PR CI documentation-only routing

## Must remain true

- Branch protection receives `build` and `integration-preflight` on every PR and merge-queue commit.
- Merge-queue commits and pushes run full checks; the fast route applies only to documentation-only PR diffs.
- Code, workflow, configuration, dependency, and mixed diffs run the full `build` checklist and integration preflight.
- A nonempty documentation-only diff runs the checklist's documentation checks without Flutter installation, app analysis, tests, or coverage.
- An unknown change scope takes the full route.

## Failure modes that shaped the design

The checklist already had a documentation-only branch, but CI installed Flutter
before reaching it and always ran Chrome integration preflight. Its prior
path rule also accepted any file under `docs/` or `ai/`, including executable
or configuration files. A skipped required job would block protected merges.
The scope detector now uses a narrow documentation path rule shared with CI,
and both required jobs still report results. CodeQL skips its language matrix
for documentation-only diffs; dependency review and OSV remain required.

## Rejected alternatives

- Workflow-level `paths-ignore` for required checks: the checks could be absent on documentation-only PRs.
- Job-level skipping of `integration-preflight`: branch protection could treat the required check as skipped.
- A second CI-specific path allowlist: it could drift from the checklist's actual validation route.
