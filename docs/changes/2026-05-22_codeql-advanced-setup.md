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

After merge, disable or remove the repo **Code scanning → CodeQL → Default setup**
entry in GitHub Settings if the UI still offers both default and advanced setups.

## Verify

1. Push/merge the workflow to `main`.
2. Confirm **Actions → CodeQL** runs from `.github/workflows/codeql.yml`.
3. Open **Security → Code scanning → CodeQL** — new analyses for the five
   languages above; java/swift configurations should stop updating with failures.
