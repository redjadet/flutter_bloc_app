---
name: theme-tokens
description: Apply when changing colors, typography, spacing, radii, Mix styles, or shared UI chrome.
---

# Skill: theme-tokens

**Owner:** [`DESIGN.md`](../../../DESIGN.md),
[`docs/design_system.md`](../../design_system.md).

Runtime sources of truth: `AppTheme`, `buildAppMixScope`, `AppStyles`, `UI`
(`package:design_system` + app theme assembly).

## Must

1. Use design-system tokens (`UI.gap*`, `UI.radius*`, theme `ColorScheme` / textTheme, Mix `AppStyles`) — not one-off hex in feature widgets.
2. When tokens diverge from [`DESIGN.md`](../../../DESIGN.md), patch **runtime first**, then update [`DESIGN.md`](../../../DESIGN.md) to match.
3. Keep `packages/design_system` free of feature and l10n imports.
4. Prove responsive layouts at compact + wide widths when layout branches.
5. Run design checks when touching theme/Mix surfaces.

## Must not

- Hardcode brand colors in feature pages.
- Invent a parallel token file outside the design system package.
- Skip [`DESIGN.md`](../../../DESIGN.md) when changing visual policy.

## Proof

```bash
./tool/check_design_md.sh
./tool/run_mix_lint.sh
cd apps/mobile && flutter test <widget-test-paths>
```
