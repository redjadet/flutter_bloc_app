---
name: agents-figma
description: Figma design-to-code for this repo (figma-sync assets, Flutter adaptation, MCP).
---

# Figma (this repo)

**Alias:** `figma-this-repo`. **Canon:** `DESIGN.md`, `docs/design_system.md`.

**figma-sync:** `figma-sync/.env` → `npm run fetch` → `assets/figma/<Frame>_<Node>/` + `pubspec.yaml`; `layout_manifest.json`; `ResilientSvgAssetImage`; responsive extensions (no raw Figma px).

**MCP:** `get_design_context` (React+Tailwind reference only) → map to `Row`/`Column`, `colorScheme`/Mix, `apps/mobile/lib/shared/` widgets, `AppConstants` spacing.
