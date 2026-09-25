# Rename `authority_*` docs to clear names

**Date:** 2026-09-25  
**Branch:** `cursor/authority-rename-d7ce`

## What

| Old | New |
| --- | --- |
| `docs/authority_scope_register.md` | `docs/scope_register.md` |
| `docs/offline_first/authority_invariants.md` | `docs/offline_first/invariants.md` |

## Why

Visitor-facing filenames still said “authority” after label scrub (#908/#912).
Rename to match content (`scope_` / `invariants_`).

## Also

- Updated links in docs, `llms.txt`, `CONTRACTS.md`, `CODEMAP.md`.
- Historical `docs/changes/2026-09-24_authority_phase_*` note **filenames** kept.
- AIDLC `operation_authority` fixtures / harness scorecard substrings untouched.
- Main `README.md` still has no “authority” prose.

## Out of scope

- Renaming historical change-note files.
- Rewriting English “authority” in AIDLC / safety / secrets docs.
