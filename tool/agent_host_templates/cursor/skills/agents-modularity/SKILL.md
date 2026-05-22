---
name: agents-modularity
description: Dependency direction and feature composition. Use for shared/core changes, cross-feature deps, auth/theme contracts.
---

# Modularity

**Canon:** [`docs/modularity.md`](../../../../../docs/modularity.md). Paths: `agents-references`.

**Rules (summary):** `lib/shared/` never imports features; no feature→feature imports (compose in app/router); core contracts for cross-cutting; capabilities not concrete cubits; no vague `Utils`/`Helper` buckets.

**Checks:** `grep -r "import.*features/" lib/shared` empty; route/DI → `./bin/router_feature_validate`.
