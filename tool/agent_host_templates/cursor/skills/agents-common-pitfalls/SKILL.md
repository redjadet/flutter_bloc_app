---
name: agents-common-pitfalls
description: Pre-flight checklist of frequent agent mistakes. Use before writing or reviewing code.
---

# Common pitfalls

Scan before coding. Full rules: **`agents-canonical-rules`** (+ matching `agents-canonical-rules-*` slice).

| Area | Don't | Do |
| ------ | ----- | ----- |
| Architecture | Flutter in `domain/`; duplicate `shared/` code | Pure Dart domain; search `lib/shared/` first |
| BLoC | `context.read` / `BlocProvider.of` | `context.cubit<T>()`, `context.state<T,S>()` — skill `type-safe-bloc-access` |
| Lifecycle | emit after `await` without `isClosed`; UI after `await` without `mounted`; `Future.delayed` in prod | guards; `TimerService.runOnce` + dispose in `close()` |
| Async utils | ad-hoc request ids / in-flight maps; raw `controller.add` on shared controllers | `RequestIdGuard`, `InFlightCoalescer`/`KeyedInFlightCoalescer`, `StreamControllerSafeEmit` |
| Offline-first | older remote over newer local | `docs/offline_first/dont_overwrite_guide.md`; `agents-shared-patterns` |
| Persistence | direct `Hive.openBox`; ad-hoc Dio | `HiveService`/Hive bases; `lib/shared/http/app_dio.dart` |
| Logging | `print`/`debugPrint` | `AppLogger` |
| Styling | hardcoded colors/strings; per-widget `GoogleFonts` | theme/`context.l10n`/`AppConstants`; `lib/core/theme/`, Mix tokens |
