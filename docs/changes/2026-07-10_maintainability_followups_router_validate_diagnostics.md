# Maintainability follow-ups: router validate paths + chat diagnostics GetIt

**Date:** 2026-07-10

## Problem

1. `./bin/router_feature_validate` still referenced `lib/core/router/` and
   `test/core/{router,di}/` paths removed when app shell moved under
   `lib/app/` and `test/app/`.
2. `chat_render_orchestration_diagnostics.dart` (feature data layer) called
   `getIt.isRegistered<FirebaseAuth>()`, coupling diagnostics to the service
   locator outside composition.

## Fix

### Router validate

- Format/analyze `lib/app/router/` only (drop missing `lib/core/router/`).
- Run tests under `test/app/router/`, `test/app/composition/`, plus existing
  IoT and sign-in coverage.

### Chat diagnostics

- `renderOrchestrationNotRunnableReason` / `logChatRenderOrchestrationIfDebug`
  take `bool Function() isFirebaseAuthRegistered`; optional overrides for tests.
- `ChatRenderOrchestrationDiagnosticsAdapter` stores the callback; composition
  wires `() => getIt.isRegistered<FirebaseAuth>()` in `register_chat_services.dart`.
- `DemoFirstChatRepository` and `RenderFastApiChatRepository` log via injected
  `logOrchestrationDiagnostics` callback (routes through diagnostics port).
- Removed `injector.dart` import from diagnostics data file.

## Files

| Area | Paths |
| --- | --- |
| Script | `bin/router_feature_validate` |
| Chat data | `chat_render_orchestration_diagnostics.dart`, `chat_render_orchestration_diagnostics_adapter.dart`, `demo_first_chat_repository.dart`, `render_fastapi_chat_repository.dart`, `render_fastapi_chat_repository_send.part.dart` |
| Composition | `register_chat_services.dart`, `register_chat_services_render.part.dart` |
| Tests | `test/features/chat/data/chat_render_orchestration_diagnostics_test.dart` |
| Docs | this note, `docs/changes/README.md`, `docs/plans/2026-07-10_maintainability_program.md` |

## Verification

```bash
cd apps/mobile && flutter test test/features/chat --reporter compact
./tool/analyze.sh
./bin/router_feature_validate
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
rg -n "getIt|injector" apps/mobile/lib/features/chat/data/chat_render_orchestration_diagnostics.dart || echo clean
```

## Out of scope

Rank 3 presentation config leftovers (flavor, `FirebaseBootstrap`, IoT BLE
runtime config, calculator constants) remain optional backlog items.
