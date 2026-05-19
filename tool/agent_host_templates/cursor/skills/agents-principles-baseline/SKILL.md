---
name: agents-principles-baseline
description: Architectural principles and non-negotiable baseline for this repo. Use when implementing features or reviewing code for DRY, SRP, architecture, or baseline (theme, l10n, lifecycle).
---

# Principles and baseline

Canon: `docs/clean_architecture.md`, `docs/solid_principles.md`, `docs/dry_principles.md`, `docs/CODE_QUALITY.md`. **Numbered rules:** `agents-canonical-rules` (+ scoped `agents-canonical-rules-*`).

## Principles (summary)

TDD; DRY (search `lib/shared/` and features before new utils); SRP; SoC (domain contracts, data I/O, presentation UI/state); SOLID detail in `docs/solid_principles.md`; small interfaces; pass capabilities not concrete feature classes; low coupling / high cohesion; `AppLogger` observability; KISS; YAGNI.

## Non-negotiable baseline

- Lifecycle: `isClosed` before `emit` after `await` in cubits; `context.mounted` in widgets.
- Responsive: phone/tablet/desktop, safe areas, keyboard insets, text scale `>= 1.3`.
- No hardcoded user strings/colors/spacing/radii/durations; `context.l10n`, theme/Mix tokens, `AppConstants`.
- Type-safe BLoC only (`context.cubit<T>()`, typed selectors); skill `type-safe-bloc-access`.
- `AppLogger` only (no `print`/`debugPrint`); `///` on public APIs.
