# Known Workarounds and Temporary Fixes

This document lists **temporary workarounds** used in this project when upstream packages or tooling have known issues. These are not ideal long-term solutions.

**For maintainers and AI agents:** Prefer finding or contributing **upstream fixes** (package updates, Flutter/Xcode fixes, or alternative approaches). When a better fix exists, remove the workaround from this doc and from the codebase (e.g. `dependency_overrides` in `pubspec.yaml`), and add a short note in the relevant section below.

---

## 1. [Resolved 2026-02] path_provider_foundation on iOS 26.2 Simulator (objective_c FFI crash)

**Long-term solution applied:** Override to **path_provider_foundation 2.6.0** (not 2.5.1). Version 2.6.0 re-landed the FFI implementation with fixes for iOS 26 simulator compatibility (Flutter 3.38.4+, objective_c 9.2.1, Flutter issue #178915). The project uses Flutter 3.41.1, so the fix is valid. We keep a `dependency_overrides: path_provider_foundation: 2.6.0` until `path_provider` updates its dependency range to include 2.6.0; then the override can be removed.

---

## 2. Other workarounds (template)

Add new workarounds below in the same format:

- **Title:** Short name of the issue.
- **Symptom:** What fails (error message, platform, version).
- **Root cause:** Why it happens (package/tool version, known bug).
- **Current workaround:** What we did (override, config change, code patch).
- **Where to look for a better fix:** Links or keywords for upstream fix.

When the workaround is no longer needed, replace the section with a one-line note and date, e.g.:

```text
### 2. [Resolved YYYY-MM] Some issue – fixed in package X.Y.Z / Flutter 3.x.
```

---

## References

- **pubspec.yaml** `dependency_overrides`: current overrides and short comments.
- **Flutter issues:** [flutter/flutter](https://github.com/flutter/flutter/issues) (e.g. labels `p: path_provider`, `platform-ios`).
- **Package changelogs:** Always check pub.dev changelog before removing a workaround.
