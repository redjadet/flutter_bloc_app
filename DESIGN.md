---
version: alpha
name: Flutter BLoC App
description: >-
  Material 3 Flutter demo app with offline-first workflows, polished utilities,
  and agent-readable design memory.
colors:
  primary: "#6750A4"
  on-primary: "#FFFFFF"
  surface: "#FFFBFE"
  on-surface: "#1D1B20"
  surface-container-low: "#F7F2FA"
  surface-container-highest: "#E6E0E9"
  outline-variant: "#CAC4D0"
  error: "#B3261E"
  success: "#4CAF50"
typography:
  display-large:
    fontFamily: Comfortaa
    fontSize: 57px
    fontWeight: 400
    lineHeight: 1.12
  title-large:
    fontFamily: Roboto
    fontSize: 22px
    fontWeight: 400
    lineHeight: 1.27
  title-medium:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.5
  body-large:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
  body-medium:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.43
  label-large:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.43
  label-medium:
    fontFamily: Roboto
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.33
rounded:
  sm: 8px
  md: 16px
  full: 999px
spacing:
  xs: 6px
  sm: 8px
  md: 12px
  lg: 16px
  card-pad-h: 20px
  card-pad-v: 16px
components:
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.card-pad-v}"
  chip:
    backgroundColor: "{colors.surface-container-low}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-medium}"
    rounded: "{rounded.full}"
    padding: "{spacing.sm}"
  button-filled:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    padding: "{spacing.md}"
  button-outlined:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    padding: "{spacing.md}"
  input-field:
    backgroundColor: "{colors.surface-container-highest}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-medium}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
  input-outline:
    backgroundColor: "{colors.outline-variant}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.sm}"
    size: 1px
  banner:
    backgroundColor: "{colors.surface-container-low}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-medium}"
    rounded: "{rounded.md}"
    padding: "{spacing.card-pad-h}"
  status-error:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-medium}"
    rounded: "{rounded.full}"
    padding: "{spacing.sm}"
  status-success:
    backgroundColor: "{colors.success}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-medium}"
    rounded: "{rounded.full}"
    padding: "{spacing.sm}"
---

# Flutter BLoC App Design

## Overview

The app should feel like a capable Material 3 workbench: clear, reliable,
pleasant, and dense enough for repeated demo and operational use. Visual
choices should support scanning state, understanding sync/auth flows, and
moving through feature demos without marketing-style decoration.

This file is agent-readable design memory. Runtime values live in
`AppTheme`, `buildAppMixScope`, `AppStyles`, and `UI`; keep those files as the
implementation source when Flutter behavior and this brief diverge.

## Colors

The palette preserves the current Material 3 purple identity and uses semantic
roles instead of one-off color picks.

- **Primary (#6750A4):** Main action, selected state, and trust signal. Use for
  the most important command or active element, not as general decoration.
- **Surface (#FFFBFE):** Default app and card foundation in light mode.
- **Surface containers (#F7F2FA, #E6E0E9):** Quiet filled surfaces for chips,
  inputs, badges, and low-emphasis panels.
- **Outline variant (#CAC4D0):** Field borders, dividers, and subtle structure.
- **Error (#B3261E):** Destructive and failure states only.
- **Success (#4CAF50):** Confirmation and positive status. This is decorative
  only for effects when used through `ConfettiTheme`.

Do not introduce new blues, grays, or accent colors for individual screens.
Start from `Theme.of(context).colorScheme` and add a named token only when a
shared role appears in multiple places.

## Typography

Roboto carries functional UI, data, labels, body copy, forms, and navigation.
Comfortaa is reserved for display styles so brand personality appears in
large titles without weakening readability. Arabic text uses the bundled Cairo
font through `AppTheme.createArabicTextTheme`; do not fetch fonts at runtime.

Use theme text styles or Mix text tokens. Avoid per-widget font families,
arbitrary font sizes, and heavy display weights. Keep labels concise and use
larger sizes only where the surrounding layout gives them enough space.

Continued in [`DESIGN_layout_components.md`](DESIGN_layout_components.md).
