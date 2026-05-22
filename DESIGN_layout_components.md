# Flutter BLoC App Design (continued)

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
