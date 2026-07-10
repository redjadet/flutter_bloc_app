# ADR quality hardening

## Problem

Accepted ADRs could retain removed app ownership paths because only links and
general agent-doc anchors were checked. ADR metadata also omitted decision dates.

## Change

- Updated ADR 0001 to current app-shell and workspace-package ownership.
- Updated ADR 0004 to current type-safe BLoC helper/widget paths and valid owner
  docs.
- Added decision dates to all accepted ADRs.
- Added deterministic ADR structure/stale-path guard, doc-gardening wiring, and
  missing-date negative fixture.

## Proof

`bash tool/check_adr_quality.sh`, harness fixtures, architecture boundary checks,
validation-doc sync, checklist-fast, and agent-maintain closeout.
