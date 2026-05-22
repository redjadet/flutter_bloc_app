# Validation scripts — theme and l10n

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Staff demo Firestore seed vs parser contract

- **Canonical payloads (Dart)**: `test/features/staff_app_demo/data/staff_demo_seed_document_fixtures.dart` must stay aligned with `functions/tool/seed_staff_demo.js` field names and literals.
- **Contract test**: `test/features/staff_app_demo/data/staff_demo_seed_firestore_contract_test.dart` asserts those payloads parse through shared mappers under `lib/features/staff_app_demo/data/staff_demo_*_firestore_map.dart`.
- **When to update**: Any change to seed payloads or mapper logic must update fixtures + seed + mappers in same PR; CI catches drift via `tool/check_regression_guards.sh` (included in `./bin/checklist` when focused regression guards run).

---

## Theme & Colors

### `check_hardcoded_colors.sh`

**Purpose**: Prevents hard-coded colors in presentation layer.

**What it checks**:

- `Colors.black`, `Colors.white`, `Colors.grey`, `Colors.gray`, and other hard-coded color constants
- Excludes `colorScheme` usage (which is correct)

**Why it matters**:

- Hard-coded colors break dark mode support
- Inconsistent with Material 3 color scheme
- Reduces accessibility and theme adaptiveness

**Example violation**:

```dart
Text('Hello', style: TextStyle(color: Colors.black)) // ❌ Hard-coded color
```

**Correct pattern**:

```dart
Text('Hello', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)) // ✅ Theme-aware
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

## Localization

- **`check_missing_localizations.sh`**: Ensures localization keys referenced in code exist in ARB files; run after adding new `context.l10n.*` usages.

### `check_hardcoded_strings.sh`

**Purpose**: Prevents hard-coded strings in `Text` widgets.

**What it checks**:

- `Text('...')` or `Text("...")` with user-facing strings
- Excludes `context.l10n.*` usage (which is correct)
- Filters out very short strings (likely debug/test)

**Why it matters**:

- Hard-coded strings prevent localization
- Breaks UX for non-English users
- Inconsistent with app's localization strategy

**Example violation**:

```dart
Text('Search...') // ❌ Hard-coded string
```

**Correct pattern**:

```dart
Text(context.l10n.searchHint) // ✅ Localized
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---
