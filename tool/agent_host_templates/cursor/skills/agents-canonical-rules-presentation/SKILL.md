---
name: agents-canonical-rules-presentation
description: Canonical rules — UI, theme, l10n, Mix, type-safe BLoC access, list/build performance. Part of agents-canonical-rules split.
---

# Presentation (UI, BLoC access, perf)

Slice of **`agents-canonical-rules`**. **Design canon:** `DESIGN.md`, `docs/design_system.md`. **BLoC API:** skill `type-safe-bloc-access`.

## UI, theme, l10n

- `lib/shared/extensions/responsive.dart`; `CommonPageLayout`, `PlatformAdaptive.*`, `showAdaptiveDialog()`.
- `Theme.of(context).colorScheme` — no raw `Colors.*`.
- `Expanded`/`Flexible`; `LayoutBuilder`/`MediaQuery`; `IconLabelRow` + ellipsis for icon+text rows.
- Small widgets; `const` where possible; private **widget classes** over helper methods returning `Widget`.
- a11y: contrast ≥ 4.5:1, `Semantics`, screen readers.
- l10n: `context.l10n.*`; all `app_*.arb`; `dart run tool/ensure_localizations.dart` / `flutter gen-l10n`.
- No inherited reads in `create`/`initState`; cubit user strings: optional page `l10n`.
- Typography in `lib/core/theme/` only; theme extensions for custom tokens.
- Mix: `AppStyles` + `mix_app_theme.dart`; `CommonCard`; prefer `$text.style.ref(AppTextStyleTokens.*)`; no consistency-only Mix migrations; primary actions visible (app bar/FAB if needed).

## Type-safe BLoC

- No `context.read<T>()` / `BlocProvider.of<T>()` — use `context.cubit<T>()`, `context.state<T,S>()`, `lib/shared/widgets/type_safe_bloc_selector.dart`.
- `tool/generate_sealed_switch.dart` for sealed helpers.

## Performance

- `TypeSafeBlocSelector` for slices; no heavy work in `build()`.
- Long lists: slivers / builders; avoid `shrinkWrap` in long scrollables.
- `RepaintBoundary` on heavy paint; bounded caches.
- JSON **> 8KB:** `decodeJsonMap` / `decodeJsonList` / `encodeJsonIsolate` (`lib/shared/utils/isolate_json.dart`).
