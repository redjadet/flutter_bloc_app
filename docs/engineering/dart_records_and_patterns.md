# Dart records and patterns (repo practice)

Pinned language: **Dart 3.13.x** (Flutter **3.47.x**). Records, patterns, and
switch expressions have been stable since Dart 3.0; this page teaches **when to
use them here**, not a language tour.

Official references:

- [Records](https://dart.dev/language/records)
- [Patterns](https://dart.dev/language/patterns)
- [Pattern types](https://dart.dev/language/pattern-types)
- [Switch expressions / exhaustiveness](https://dart.dev/language/branches#switch-expressions)

## Decision table

| Situation | Prefer | Avoid |
| --- | --- | --- |
| Domain entity, Cubit/BLoC state, JSON model with codegen | Existing `@freezed` / sealed unions | Rewriting Freezed models as records “for fashion” |
| Multi-value helper return (title+message, colors+label) | Positional or named **record** + destructure | Ad-hoc `List`, untyped `Map`, one-off class for two fields |
| Exhaustive mapping over sealed/enum | `switch` **expression** (no `_` if sealed) | `if` chains that drop a new variant silently |
| Nullable → non-null local | `if (x case final v?)` / null-check patterns | Force unwrap (`!`) when a pattern fits |
| Validating a small JSON/map shape | `if (data case {'key': [String a, int b]})` | Long `is` + `containsKey` ladders for the same shape |
| Iterating map entries when key/value both used | `for (final MapEntry(:key, :value) in map.entries)` | Optional; fine to keep `entry.key` if clearer |
| Operation that must stay with the type (methods, invariants) | Class / Freezed / sealed | Record (records hold data only) |

## Records: multi-return and local UI tuples

Records are anonymous, immutable, fixed-shape aggregates. Field names on
**named** records are part of the type; names on positional fields in a type
annotation are documentation only ([Records](https://dart.dev/language/records)).

**Good fit in this repo:** sync banner helpers, connection-status palette
tuples, short cache lookups like `({String token, String source})`.

```dart
(String title, String message) syncBannerTitleAndMessage(...) =>
    switch ((isOffline, isSyncing)) {
      (true, _) => (l10n.offlineTitle, l10n.offlineMessage(pendingCount)),
      (false, true) => (l10n.syncingTitle, l10n.syncingMessage(pendingCount)),
      (false, false) when !kShowPendingSyncQueueUi => ('', ''),
      (false, false) => (l10n.pendingTitle, l10n.pendingMessage(pendingCount)),
    };

final (String title, String message) = syncBannerTitleAndMessage(...);
```

Use a `typedef` when the same record shape appears in several APIs
([Records and typedefs](https://dart.dev/language/records#records-and-typedefs)).
Prefer a class or Freezed type once you need methods, validation, or a stable
public domain name.

## Patterns and switch expressions

Every `case` is a pattern. Prefer switch **expressions** for value-producing
maps; use statements when the body needs multiple statements.

Sealed classes and enums get **exhaustiveness checking**: adding a subtype
breaks incomplete switches at compile time. Keep that property — do not paper
over with a lazy `_` on sealed domain states unless the default is truly
intentional ([exhaustiveness](https://dart.dev/language/branches#exhaustiveness-checking)).

Object patterns destructure getters (`FailureResult(:final failure)`,
`DioException(response: Response(:final statusCode?))`). Logical-or and
relational patterns sharpen HTTP/status maps (`401 || 403`, `>= 400 && < 500`).

Guards (`when`) refine a matched case without exiting the switch when the
guard is false — useful for flags layered on a record shape (see sync banner
above).

## Freezed / sealed vs records

- **Freezed / hand-written sealed:** domain models, Cubit states, Result/error
  unions, anything that participates in equality, codegen, or feature contracts.
- **Records:** local multi-returns, private helper shapes, ephemeral UI tuples.
- **Do not** mass-migrate Freezed entities to records. That fights codegen,
  copyWith, and the feature structure contract.

Sealed UI mapping already lives in
[`compile_time_safety.md`](../architecture/compile_time_safety.md) and
[`bloc_standards.md`](../bloc_standards.md). Null-safe pattern matching is also
called out in [`CODE_QUALITY.md`](../CODE_QUALITY.md).

## Repo anchors (examples, not a checklist to copy)

| Pattern | Example |
| --- | --- |
| Record multi-return + switch | `apps/mobile/lib/app/sync/sync_banner_helpers.dart` |
| Record + exhaustive enum switch | `apps/mobile/lib/features/realtime_market/presentation/widgets/connection_status_pill.dart` |
| Sealed `Result` + object patterns | `packages/core/lib/src/domain/result.dart` |
| Relational / logical-or switches | `apps/mobile/lib/app/utils/network_error_mapper_classification.dart` |
| `if-case` null / object | Design-system widgets; `HiveKeyManager` FailureResult cases |
| `MapEntry` object pattern | `packages/app_shared_flutter/lib/src/utils/log_redaction.dart` |

## Agent / review guardrails

1. Prefer the smallest clarity win; skip drive-by “patternize everything.”
2. Preserve exhaustive switches on sealed types (`default` / `_` only when
   intentional).
3. After Dart edits: `./bin/format` (or `dart format .`), then the narrowest
   analyze + tests for touched packages.
4. Teaching updates belong in this file + a `docs/changes/` note — not only in
   agent store analyses.
