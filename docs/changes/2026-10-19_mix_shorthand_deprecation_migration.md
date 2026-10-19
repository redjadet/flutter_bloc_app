# Mix shorthand deprecation migration (design_system)

## Why

Mix 2.2.x marks spacing/radius convenience helpers
(`paddingX` / `paddingY` / `borderRadiusAll`) as `deprecated_member_use` ahead
of Mix 3.0. `packages/design_system` had 22 call sites; blocking Mix 3 later.

## What landed

Mechanical replacements in `AppStyles` (+ layout part):

- `paddingX(v)` → `padding(.horizontal(v))`
- `paddingY(v)` → `padding(.vertical(v))`
- `borderRadiusAll(r)` → `borderRadius(.all(r))`

No visual or token changes. Feature brief N/A (no `lib/features/` surface).

## Verification

- `cd packages/design_system && dart analyze` — zero `deprecated_member_use`
  for those Mix helpers
- `cd packages/design_system && flutter analyze` — same
