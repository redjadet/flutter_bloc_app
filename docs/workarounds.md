# Known Workarounds and Temporary Fixes

This document lists **temporary workarounds** used in this project when upstream packages or tooling have known issues. These are not ideal long-term solutions.

**For maintainers and AI agents:** Prefer finding or contributing **upstream fixes** (package updates, Flutter/Xcode fixes, or alternative approaches). When a better fix exists, remove the workaround from this doc and from the codebase (e.g. `dependency_overrides` in `pubspec.yaml`), and add a short note in the relevant section below.

---

## 1. path_provider_foundation on iOS 26.2 Simulator (objective_c FFI crash)

### Symptom

On **iPhone 17 Pro (iOS 26.2)** simulator (and likely other iOS 26.x simulators), the app crashes at runtime with:

```text
Invalid argument(s): Couldn't resolve native function 'DOBJC_initializeApi' in 'package:objective_c/objective_c.dylib'
Failed to load dynamic library 'objective_c.framework/objective_c': ... (no such file)
```

Stack trace points to `path_provider_foundation` → `objective_c` FFI when resolving directories (e.g. `getApplicationDocumentsDirectory()`).

### Root cause

- **path_provider_foundation 2.6.0** replaced the plugin-based iOS/macOS implementation with **direct FFI** using the `objective_c` Dart package.
- On iOS 26.2 simulator, the native `objective_c.framework/objective_c` dynamic library is not found (e.g. paths like `RuntimeRootobjective_c.framework` suggest a path or runtime lookup issue).

### Current workaround

In **pubspec.yaml** we pin `path_provider_foundation` to **2.5.1**, which uses the **plugin-based** implementation (no FFI/objective_c):

```yaml
dependency_overrides:
  path_provider_foundation: 2.5.1
```

### Where to look for a better fix

- [path_provider_foundation](https://pub.dev/packages/path_provider_foundation) changelog and [Flutter path_provider issues](https://github.com/flutter/flutter/issues?q=is%3Aissue+label%3A%22p%3A+path_provider%22): check for a release that fixes FFI/objective_c on iOS 26 simulators.
- [objective_c](https://pub.dev/packages/objective_c) package: iOS 26 / Xcode 26 compatibility.
- Flutter SDK: simulator runtime or FFI lookup changes for new iOS versions.

When a fixed version is available (e.g. path_provider_foundation 2.6.x or 2.7.x with a fix), **remove** the `path_provider_foundation: 2.5.1` override and update this section (or remove it).

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
