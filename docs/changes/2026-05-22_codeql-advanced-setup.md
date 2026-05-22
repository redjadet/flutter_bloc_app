# CodeQL advanced setup (2026-05-22)

## Problem

GitHub **automatic** CodeQL still surfaced failed configurations for
`/language:java-kotlin` and `/language:swift` (autobuild / build command failures).
This Flutter repo does not need those extractors; Dart is not supported by CodeQL.

## Fix

Added [`.github/workflows/codeql.yml`](../../.github/workflows/codeql.yml) to move
from default setup to **advanced setup** with an explicit language matrix:

- `actions`, `javascript-typescript`, `python`, `ruby`, `c-cpp`
- `build-mode: none` for all matrix entries (no autobuild)
- **Excluded:** `java-kotlin`, `swift`

## GitHub settings (required once)

Default setup and `codeql.yml` **cannot run together**. While default setup stays on,
workflow SARIF upload fails with: *advanced configurations cannot be processed when
the default setup is enabled*.

Disable default setup (done on repo via API for PR #243 verification):

```bash
gh api repos/redjadet/flutter_bloc_app/code-scanning/default-setup \
  --method PATCH --input - <<< '{"state":"not-configured"}'
```

Or **Settings → Code security → Code scanning → CodeQL → Default setup → Disable**.

Removed stale failed analyses for `java-kotlin` / `swift` via
`DELETE /repos/.../code-scanning/analyses/{id}` (`confirm_delete=true`).

## Verify

1. Merge PR #243; **Actions → CodeQL** uses `.github/workflows/codeql.yml` only.
2. All five matrix jobs green; no dynamic `github-code-scanning/codeql` default run.
3. **Security → Code scanning → CodeQL** — no new java/swift autobuild failures.
