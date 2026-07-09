---
name: agents-modularity
description: Dependency direction and feature composition. Use for shared package/app-shell changes, cross-feature deps, auth/theme contracts.
---

# Modularity

**Canon:** [`docs/modularity.md`](../../../../../docs/modularity.md). Paths: `agents-references`.

**Rules (summary):** packages never import `apps/mobile` or features; no feature→feature imports (compose in app/router); package-owned contracts for cross-cutting; capabilities not concrete cubits; no vague `Utils`/`Helper` buckets.

**Checks:** `bash tool/check_package_dependency_dag.sh`; `bash tool/check_feature_modularity_leaks.sh`; route/DI → `./bin/router_feature_validate`.
