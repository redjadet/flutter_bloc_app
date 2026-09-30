# README evidence links and scorecard compatibility

The portfolio README now opens with the project summary and reviewer links.
Static coverage and self-assessed rating badges are replaced by direct links to
measurement scope, engineering evidence, and AI workflow safeguards.

## Validation contract

The badge maintenance scripts previously required numeric README badges even
when no rating was claimed. That made the evidence-link presentation fail CI
and would reinsert a rating during routine maintenance.

Both scripts now accept a standalone Markdown link to their canonical scorecard
and preserve it in check and update modes. Scorecard parsing still runs first.
If a numeric badge is present, it takes precedence: stale badges fail `--check`,
update mode derives the minimum score, and malformed badges fail. Missing or
incorrect evidence destinations fail check mode. All existing scorecard proof
gates and measured coverage thresholds remain in place.

## Regression capture

`tool/run_harness_fixtures.sh` exercises both representations for both
scorecards in temporary directories. Cases cover preservation of neutral links,
valid and stale badges, minimum-score derivation, malformed badges, missing or
wrong links, absent scores, and out-of-range scores. This extends the existing
fixture lane already run by the delivery checklist.

The evidence-link case failed before the fix with a missing badge anchor, then
passed after the fix. Owner guidance lives in the engineering and harness
scorecards; the reusable lesson is recorded in [`tasks/lessons.md`](../../tasks/lessons.md).

The later freshness fixture also found that discovery snapshots on the PR base
preceded subsequent app-source changes. `bash tool/refresh_ai_reports.sh`
regenerated their source revision, date, and bounded metrics through the
existing owner script. Narrative guidance and app sources were unchanged.

## Proof commands

```bash
bash tool/run_harness_fixtures.sh
bash tool/check_harness_scorecard_gate.sh
bash tool/check_engineering_quality_scorecard_gate.sh --skip-coverage-proof
./bin/checklist-fast --no-reuse
bash tool/check_agent_knowledge_base.sh
./bin/agent-maintain closeout
git diff --check
```

`--skip-coverage-proof` is the existing documentation/tooling wiring check; it
does not establish measured coverage. The final PR also runs the required
hosted delivery checklist and integration preflight because shell scripts are
included. Exact pass/fail results and host limitations are recorded in the PR.
