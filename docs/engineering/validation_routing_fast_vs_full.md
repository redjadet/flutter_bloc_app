# Validation Routing: Fast vs Full

This guide defines when to run fast, scoped validation versus full validation.

## Fast Path

Use fast path for narrow, low-risk edits where routing/auth/gates are unchanged.

- Local formatting/lints/tests for touched files
- Optional targeted regression tests

## Scoped Router/Auth Path

Use `./bin/router_feature_validate` when changes touch:

- `lib/app/router/**`
- `lib/core/router/**`
- feature presentation gate/auth/sign-in/login/register pages or widgets

Command:

```bash
./bin/router_feature_validate
```

## Full Path

Use full path for broad, medium/high-risk, or pre-ship changes.

Command:

```bash
./bin/checklist
```

## Integration Path

Use for integration-covered workflows, release-candidate lanes, and upgrade lanes.

Command:

```bash
./bin/integration_tests
```

Optional full upgrade lane:

```bash
./bin/upgrade_validate_all
```
