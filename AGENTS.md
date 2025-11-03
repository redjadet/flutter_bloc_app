# AGENTS — Flutter BLoC App

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

- Keep Domain → Data → Presentation flow with MVP:
  Widgets ↔ Cubits ↔ Repositories/Models.
- Domain stays Flutter-agnostic; presentation depends on abstractions only and
  shares utilities via `lib/shared/` when cross-cutting.
- Put business rules in domain use cases or cubits; widgets focus on layout,
  theming, navigation triggers.
- Resolve dependencies through `get_it`; only construct pure value objects in
  widgets/cubits.
- Drive timers through `TimerService` (and `FakeTimerService` in tests) for
  deterministic behaviour.
- Ship immutable `Equatable`/`freezed` cubit states and expose derived values
  with getters.
- Await async work and funnel failures through domain failures or
  `ErrorHandling`.
- Extract helpers before files exceed ~250 lines and leave lint warnings clean.

## Delivery Workflow

1. Update domain contracts/models.
2. Implement data repositories and register them in `get_it`.
3. Extend cubits/blocs and inject dependencies.
4. Build focused presentation widgets.
5. Add/update unit, bloc, widget, and golden tests using fakes for determinism.

## Testing Playbook

- Cover cubit/bloc flows with `bloc_test`.
- Exercise UI via widget/golden tests (e.g., `CountdownBar`, `CounterDisplay`).
- Use `MockFirebaseAuth` + `mock_exceptions` for auth paths.
- Advance timers with `FakeTimerService().tick(n)`; stop runs over 3 minutes and
  investigate hangs.
- Update `NativePlatformService` fakes and integration coverage with every
  platform contract change.

## Key Notes

- Counter auto-decrements every 5 s but never drops below 0.
- Supported locales come from `MaterialApp.supportedLocales`.
- Platform info resolves through `NativePlatformService` (MethodChannel).
- Counter widgets live under `lib/features/counter/presentation/widgets/`
  (exported via `features/counter.dart`).
- Theme and locale logic stays in `lib/features/settings/`.
- After touching tests, rerun `flutter test --coverage` then
  `dart run tool/update_coverage_summary.dart`.

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

### Purpose

Generate Flutter layouts from `figma-sync` exports.

### Setup

- `cd figma-sync && npm install` (first run).
- Update `figma-sync/.env` with either:
  - `FIGMA_TOKEN`, `FILE_KEY`, `NODE_IDS`, `EXPORT_FORMAT=png`, or
  - `FIGMA_TOKEN`, `FIGMA_URL`, `EXPORT_FORMAT=png` (auto extracts keys).

### Fetch Assets

- Run `npm run fetch` (or `npm run watch`) to populate
  `figma-sync/figma-data/{Frame}_{Node}/` with JSON, art, and manifests.

### Implement Layout

- Copy assets to `assets/figma/{Frame}_{Node}/` and declare the folder in
  `pubspec.yaml`.
- Use `layout_manifest.json` for positioning (subtract frame origin).
- Render in ascending `zIndex`; prefer semantic widgets, otherwise use
  `SvgPicture.asset` or `Image.asset`.
- Load embedded raster SVGs via `ResilientSvgAssetImage`, falling back to PNGs
  or sized placeholders.

### Prompt Triggers

- Act on prompts such as “create design/layout from Figma {Frame}_{Node}”,
  “generate Flutter screen from node {id}”, or direct Figma URLs.

### Direct Figma URLs

- Parse `FILE_KEY` and `NODE_ID` (convert `0-702` → `0:702`), update `.env`,
  run `npm run fetch`, then follow the layout steps.

### Quality Checks

- After integrating assets/code, run the delivery checklist (format, analyze,
  tests, coverage).
- Keep platform fakes and integrations aligned with new assets or channel usage.
