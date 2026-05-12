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

## Layout

Spacing follows the existing `UI` scale: 6, 8, 12, and 16px gaps, with 20px
horizontal card padding and 16px vertical card padding. Use responsive helpers
and existing breakpoints: mobile below 800px, tablet from 800px, desktop from
1200px.

Operational screens should be quiet and scannable: grouped controls, stable
row heights, predictable page padding, and no nested cards. Mobile is not a
squeezed desktop; rows and panels may stack while preserving touch targets and
text legibility.

## Elevation & Depth

Use shallow Material elevation sparingly. Cards default to low elevation and
dark mode should reduce visible shadows. Prefer tonal surfaces, outlines, and
spacing for hierarchy before adding more depth.

Avoid decorative shadow systems, blurred panels, and gradient backgrounds.
Depth should clarify grouping, not create a landing-page feel.

## Shapes

Default cards, inputs, and panels use 16px corners through `UI.radiusM`.
Compact controls may use 8px. Pills are reserved for buttons, chips, badges,
and clearly pill-shaped controls.

Do not mix sharp and highly rounded corners inside the same component group.
Do not introduce larger rounded cards unless the shared token scale changes.

## Components

- **Cards and panels:** Use `CommonCard` or `AppStyles.card`. Keep panels
  un-nested; split sections with spacing or headings instead.
- **Buttons:** Use primary filled buttons for the main action and outlined
  buttons for secondary actions. States must stay theme-aware and accessible.
- **Inputs:** Use `AppStyles.inputField`, `inputFieldShell`, or `inputOutline`
  for custom controls; helper and error text should come from Material
  form-field behavior where possible.
- **Chips and badges:** Use `AppStyles.chip` or `CommonCard` with a border for
  compact status. Chips should not invent custom padding or colors.
- **Compact status:** Use `AppStyles.statusSuccess` / `statusError` with the
  paired text styles for success and error badges.
- **Banners and empty states:** Use `AppStyles.banner` and
  `AppStyles.emptyState` for shared surfaces. Keep content concise and
  action-oriented.
- **Lists:** Prefer Material `ListTile` for standard rows. Use
  `AppStyles.listTile` only for custom row shells that cannot be expressed with
  `ListTile`.

## Do's and Don'ts

- Do keep visual roles semantic: primary, surface, outline, error, success.
- Do use `Theme.of(context).colorScheme`, `AppStyles`, `AppTypography`, and
  Mix text tokens instead of hardcoded values.
- Do keep app/demo screens dense but readable, with stable dimensions for
  controls that hold dynamic content.
- Do update this file and `docs/design_system.md` when adding shared visual
  roles or component tokens.
- Don't rebrand the app from the current Material 3 purple identity without an
  explicit product decision.
- Don't add per-screen colors, fonts, radii, or shadows that bypass shared
  tokens.
- Don't use nested UI cards, decorative gradient/orb backgrounds, or
  marketing-style hero layouts for operational tools.
- Don't rely on this file as runtime enforcement; validate Flutter code with
  repo checks and widget tests.

### Agent prompt guide

When generating or refactoring UI, keep these constraints in working memory:

- **Use tokens first**: `Theme.of(context).colorScheme`, `UI.*`, `AppStyles.*`,
  Mix tokens (`AppMixTokens`, `AppMaterialColorTokens`, `AppTextStyleTokens`).
- **Spacing scale**: 6/8/12/16 for gaps; cards use 20px horizontal + 16px vertical.
- **Shapes**: cards/inputs 16px; compact controls 8px; pills only for buttons/chips/badges.
- **Color roles**: primary for “most important action”, error only for failure, success only for positive status.
- **Workflow first**: open on the real workflow/demo surface; prioritize
  scanning, comparison, repeated action, not marketing/hero composition.
- **Complete states**: loading, empty, error, disabled, offline/sync, success.
- **Responsive proof**: stable constraints for boards/rows/counters/icon
  buttons; check mobile/desktop for clipped text, overlap, unusable taps, or
  hidden primary content.
