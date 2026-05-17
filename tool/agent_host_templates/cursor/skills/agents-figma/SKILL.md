---
name: agents-figma
description: Figma design-to-code for this repo (figma-sync assets, Flutter adaptation, MCP).
---

# Figma (this repo)

**Alias:** `figma-this-repo` → this skill. **Design canon:** `DESIGN.md`, `docs/design_system.md`.

## figma-sync

1. `figma-sync/.env` (file key + token) → `npm install` → `npm run fetch`
2. Assets: `assets/figma/<Frame>_<Node>/`; register in `pubspec.yaml`
3. Stack from `layout_manifest.json`; `ResilientSvgAssetImage`; `lib/shared/extensions/responsive.dart` (no raw Figma px)

## MCP → Flutter

Prefer **`plugin-figma-figma`** (or `user-Figma`): `get_design_context` with URL `fileKey` + `nodeId` (`-` → `:` in node id). Output is React+Tailwind reference only.

| Figma / MCP | This repo |
| ------------- | ----------- |
| Flex | `Row`/`Column`/`Wrap`/`Stack` + `Expanded`/`Flexible` |
| Colors | `colorScheme` / Mix `AppStyles` — no hex |
| Type | `AppTypography` / Mix text tokens — no per-widget `GoogleFonts` |
| Spacing | `AppConstants`, spacing extensions, Mix tokens |
| Widgets | Reuse `lib/shared/` (`CommonCard`, `CommonPageLayout`, …) before new |
| Icons | Material or `assets/figma/` |

Optional desktop MCP: `http://127.0.0.1:3845/mcp`.
