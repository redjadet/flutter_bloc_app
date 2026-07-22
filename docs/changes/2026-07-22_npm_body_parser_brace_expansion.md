# 2026-07-22 — npm body-parser + brace-expansion security overrides

## Summary

Closed Dependabot #570 (stale lockfile regen failing `dependency-review`) and
replaced it with focused `package.json` overrides in
`backend/firebase/functions`:

- `body-parser` → `1.20.6`
- `brace-expansion` majors pinned to patched lines (`1.1.16` / `2.1.2` /
  `5.0.7`) for [GHSA-3jxr-9vmj-r5cp](https://github.com/advisories/GHSA-3jxr-9vmj-r5cp)

## Verification

- `npm audit` in `backend/firebase/functions`: high brace-expansion finding
  cleared (remaining: moderate `ts-deepmerge` via `firebase-functions-test`,
  left alone — force fix is breaking).
