# GEMINI — Flutter BLoC App

Keep work lean, clean, and tested.

## Delivery Checklist (run top to bottom)
1. `flutter pub get`
2. If Freezed/JSON changed → `dart run build_runner build --delete-conflicting-outputs`
3. `dart format .`
4. `flutter analyze`
5. `dart run custom_lint`
6. `flutter test --coverage`
7. `dart run tool/update_coverage_summary.dart`
8. `flutter build ios --simulator` (only for platform/build-risk changes)

## Architecture Guardrails
- Enforce Clean Architecture flow (Domain → Data → Presentation) with MVP: Widgets ↔ Cubits ↔ Repositories/Models.
- Domain stays Flutter-agnostic; presentation depends on abstractions only; shared utilities live under `lib/shared/` when cross-cutting.
- House business rules inside domain use cases or cubits; widgets limit themselves to layout, theming, navigation triggers.
- Inject dependencies via `get_it`; avoid constructing services inside widgets/cubits unless they are pure value objects.
- Timer logic routes through `TimerService` (or `FakeTimerService` in tests) for deterministic flows.
- Cubit states remain immutable + `Equatable`/`freezed`; expose derived values with getters.
- Await async work; channel failures through domain failures or `ErrorHandling`.
- Keep hand-written files under ~250 lines and resolve lint warnings before handoff.

## Delivery Workflow
1. Update domain contracts/models.
2. Implement data repositories and register them in `get_it`.
3. Extend cubits/blocs and inject dependencies.
4. Build focused presentation widgets.
5. Add/update unit, bloc, widget, and golden tests using fakes for determinism.

## Testing Playbook
- Use `bloc_test` for cubit/bloc flows.
- Cover UI with widget/golden tests (e.g., `CountdownBar`, `CounterDisplay`).
- Auth flows rely on `MockFirebaseAuth` + `mock_exceptions`.
- Drive time-dependent behaviour via `FakeTimerService().tick(n)`; abort runs >3 minutes and investigate hangs.
- Update `NativePlatformService` fakes and integration coverage when platform contracts change.

## Key Notes
- Counter auto-decrements every 5 s and never drops below 0.
- Supported locales live in `MaterialApp.supportedLocales`.
- Platform info comes from `NativePlatformService` (MethodChannel).
- Counter widgets are under `lib/features/counter/presentation/widgets/` (exported via `features/counter.dart`).
- Theme & locale logic stays in `lib/features/settings/`.
- After modifying tests, rerun coverage scripts (`flutter test --coverage`, `dart run tool/update_coverage_summary.dart`).

## DI Reference

```dart
return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => CounterCubit(
        repository: getIt<CounterRepository>(),
        timerService: getIt(),
      )..loadInitial(),
    ),
    BlocProvider(
      create: (_) => ThemeCubit(
        repository: getIt<ThemeRepository>(),
      )..loadInitial(),
    ),
  ],
  child: ...,
);
```

## Figma Agent Playbook

**Purpose**: Generate Flutter layouts from `figma-sync` exports.

**Setup**
1. `cd figma-sync && npm install` (first run).
2. Create/update `figma-sync/.env` with either:
   - `FIGMA_TOKEN`, `FILE_KEY`, `NODE_IDS`, `EXPORT_FORMAT=png`, or
   - `FIGMA_TOKEN`, `FIGMA_URL`, `EXPORT_FORMAT=png` (auto extracts keys).

**Fetch Assets**
- Run `npm run fetch` (or `npm run watch` for auto-refresh). Outputs per-node folders under `figma-sync/figma-data/{Frame}_{Node}/` containing JSON, PNG/SVG assets, `layout_manifest.json`, and `all_nodes.json`.

**Implement Layout**
1. Copy assets to `assets/figma/{Frame}_{Node}/` and add that folder to `pubspec.yaml`.
2. Read `layout_manifest.json` to drive layout; subtract the frame origin from asset positions to get `left/top`.
3. Render assets respecting ascending `zIndex` (background → foreground). Prefer semantic Flutter widgets; otherwise use `SvgPicture.asset` or `Image.asset`.
4. Load SVGs with embedded rasters via `ResilientSvgAssetImage`, falling back to PNGs or sized placeholders when needed.

**Prompt Triggers**
- Treat requests like “create design/layout from Figma {Frame}_{Node}”, “generate Flutter screen from node {id}”, or direct Figma URLs as signals to run this playbook.

**Direct Figma URLs**
1. Parse `FILE_KEY` and `NODE_ID` from the URL (convert `0-702` → `0:702`).
2. Update `.env`, then run `npm run fetch`.
3. Proceed with the layout workflow above.

**Quality Checks**
- After integrating assets/code: run the delivery checklist (format, analyze, tests, coverage).
- Keep platform fakes and integrations in sync with new assets or channel usage.
