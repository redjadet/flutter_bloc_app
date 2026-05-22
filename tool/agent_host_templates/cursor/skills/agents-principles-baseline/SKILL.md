---
name: agents-principles-baseline
description: Architectural principles and non-negotiable baseline for this repo. Use when implementing features or reviewing code for DRY, SRP, architecture, or baseline (theme, l10n, lifecycle).
---

# Principles and baseline

**Canon:** [`docs/clean_architecture.md`](../../../../../docs/clean_architecture.md), [`docs/solid_principles.md`](../../../../../docs/solid_principles.md), [`docs/dry_principles.md`](../../../../../docs/dry_principles.md), [`docs/CODE_QUALITY.md`](../../../../../docs/CODE_QUALITY.md). **Rules router:** `agents-canonical-rules` (+ scoped children).

TDD; DRY/SRP/SoC; low coupling; `AppLogger`; KISS/YAGNI. **Baseline:** `isClosed`/`mounted` guards; responsive + l10n/theme tokens; type-safe BLoC (`type-safe-bloc-access`).
