# Authority Phase 2 — platforms teaching pack

**Date:** 2026-09-24  
**Branch:** `cursor/authority-phase-2`  
**Worktree:** `/Volumes/Lacie_Ssd/projects/bloc_test_app/flutter_bloc_app-authority-phase-2`  
**Base SHA:** `297fc935` (post #900 merge)

## Delivered

| Artifact | Role |
| --- | --- |
| [`docs/platforms/README.md`](../platforms/README.md) | Capability + fidelity matrices; adaptive chrome pointer; non-goals |
| [`docs/platforms/ios.md`](../platforms/ios.md) | iOS host file map |
| [`docs/platforms/android.md`](../platforms/android.md) | Android host file map |
| [`docs/platforms/native_interop.md`](../platforms/native_interop.md) | Layering, typed stub statuses, adaptive APIs |

Cross-links: root README thesis + native section, `CODEMAP.md`, `docs/README.md`,
`authority_scope_register.md`, feature README, `interview_showcase.md`.

## Design-system ↔ code check (this slice)

| Claim | Code truth | Action |
| --- | --- | --- |
| Showcase uses `PlatformAdaptive` | `NativePlatformShowcaseAdaptive` → `isCupertino` / `listTile` | Documented exact APIs |
| Material summary card | `CommonCard` + `responsiveGapS` | Documented |
| Cupertino summary | `CupertinoListSection` / `CupertinoListTile` | Documented |
| New tokens in teaching pack | None introduced | OK |
| Spine “adaptive” | Spine uses shared `PlatformAdaptive.*` / gaps; not showcase helper | Clarified in platforms README |

No DESIGN.md / design_system.md token inventing. Prefer docs→code alignment.

## Dedupe

| Near-duplicate | Canonical | Trim |
| --- | --- | --- |
| Capability/fidelity tables | `docs/platforms/README.md` | Feature README keeps bridges only |
| Root README native prose + build commands | Teaching pack + short evidence table | Trimmed telemetry essay + extra build cmds from README |
| Host path lists | ios.md / android.md | Not copied into matrices |

## Non-goals unchanged

Background OS demo / home-screen widgets remain non-goals (scope register + ADR-0005).
