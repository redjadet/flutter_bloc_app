# Runtime-error check skips no active app

## Why

`dart mcp-server` can report `No active app connection` when a DTD is reachable
but no Flutter debug app is attached. The checker failed that normal no-session
state, so harness fixtures and documentation-only validation could not finish.

## Change

- Recognize the response when listing connected apps and when reading errors.
- Return the existing skipped result in default mode; `--strict` still fails.
- Assert the response classification during the runtime checker self-test.
- Run scorecard freshness only when scorecard artifacts changed; ignored local
  event archives cannot block unrelated closeout.

## Proof

- `bash tool/check_runtime_errors.sh --self-test`
- `bash tool/check_runtime_errors.sh`
- `bash tool/run_harness_fixtures.sh`
- `./bin/agent-maintain closeout`
