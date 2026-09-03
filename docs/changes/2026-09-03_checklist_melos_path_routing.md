# Checklist Melos path routing

## Problem

Checklist auto-routing retained app-relative `lib/**` and `test/**` selectors
after application moved under `apps/mobile/`. Changed repository paths therefore
missed Mix, focused regression, Todo layout, and action-bar layout selectors.

## Decision

Normalize `apps/mobile/` only at route-selection boundaries. Preserve original
repository paths for changed-file output, formatting, and validation-cache
fingerprints.

`./bin/checklist --explain --print-changed` now reports each automatic route as
`run` or `skip`. CLI contract creates `apps/mobile/` fixtures and proves Mix,
focused regression, Todo layout, and action-bar layout routing remains selected.

Fast-checklist inventory fallback now selects newest dated report without
parsing `ls` output. Redundant shadowed action-bar glob was removed.

## Scope

No app behavior, test content, coverage policy, or CI workflow changed.
