---
name: agents-canonical-rules-presentation
description: Canonical rules — UI, theme, l10n, Mix, type-safe BLoC access, list/build performance. Part of agents-canonical-rules split.
---

# Presentation (UI, BLoC access, perf)

Slice of **`agents-canonical-rules`**. **Canon:** `DESIGN.md`, [`docs/design_system.md`](../../../../../docs/design_system.md) (§ Reusable widgets for preview/test/iteration), skill `type-safe-bloc-access`, [`docs/CODE_QUALITY.md`](../../../../../docs/CODE_QUALITY.md).

Open when touching UI/theme/l10n/Mix/lists — full rules in design canon + CODE_QUALITY, not here.

## Reusable widgets (summary)

- Extract **constructor-driven** leaf widgets under `presentation/widgets/`.
- Pages wire cubit → props; leaf widgets do not call `context.read` / `get_it`.
- Add **`@Preview`** + component widget test for non-trivial UI (same fixtures).
- Use design tokens (`AppStyles`, `UI`, theme); `ValueKey` on tappable controls.

## Responsive layout (summary)

- **No fixed sizes** on shells, text blocks, or action rows that must reflow.
- **`LayoutBuilder`** — branch/size from **parent** `constraints`.
- **`MediaQuery`** — keyboard, text scale, safe area, screen width when parent is narrow.
- **Prefer** `context.responsive*` / shared widgets before custom breakpoints.
- Canon: [`design_system.md`](../../../../../docs/design_system.md) § Responsive layout.

## Cross-platform form factors (summary)

- **Mobile, tablet, web, desktop** — all shared widgets must work on four targets.
- Breakpoints: mobile &lt;800, tablet 800–1199, desktop ≥1200; tablet ≠ stretched phone.
- Web: safe imports + routing; desktop: keyboard/focus + narrow window.
- No `dart:io` / unguarded `Platform.is*` in presentation.
- Canon: [`design_system.md`](../../../../../docs/design_system.md) § Cross-platform form factors; skill `flutter-cross-platform-modern`.
