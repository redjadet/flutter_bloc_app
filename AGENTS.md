# AGENTS — Flutter BLoC App

Keep work lean, clean, and tested.

## Quick Checklist

1. `flutter pub get`
2. If Freezed/JSON models changed → `dart run build_runner build --delete-conflicting-outputs`
3. `dart format .`
4. `flutter analyze`
5. `dart run custom_lint`
6. `flutter test --coverage`
7. `dart run tool/update_coverage_summary.dart`
8. `flutter build ios --simulator` (optional, only when platform changes or other big shifts risk breaking builds)

## Architecture Rules

- Enforce **Clean Architecture**: Domain → Data → Presentation only.
- Follow MVP: Widgets (View) ↔ Cubits (Presenter) ↔ Repositories/Models.
- Apply SOLID & Clean Code: expressive names, small units, limited side effects.
- UI-only state stays under `presentation/*`; domain models remain UI agnostic.
- Use `TimerService` (& `FakeTimerService` in tests) for timed behaviour.

## Code Rules

- Honor layer boundaries: domain stays Flutter-agnostic; data implements domain contracts only; presentation depends on abstractions, never concrete data sources.
- Keep business logic inside domain use cases or cubits; widgets are limited to view concerns (layout, theming, navigation hooks).
- Register every repository/service in `get_it`; avoid `new`ing dependencies in widgets or cubits unless they are pure value objects.
- Make all cubit states immutable and `Equatable`/`freezed`; expose derived values with getters instead of mutable fields.
- Ban unhandled `async` work: await futures, avoid `async void` outside callbacks, and route errors through domain failures or `ErrorHandling` helpers.
- Guard architecture with imports: no `../../data` or `../../presentation` jumps; shared utilities live under `lib/shared/` only when cross-cutting.
- Timer or clock logic must pass through `TimerService` (or `FakeTimerService` in tests) to keep flows deterministic.
- Any new feature ships with matching `bloc_test` coverage and, when UI surfaces change, widget/golden tests; keep coverage scripts up to date.
- Respect lint configuration: fix violations instead of disabling rules; if ignoring is unavoidable, annotate with a TODO and owner.
- Adhere to size limits: keep hand-written files under ~250 lines—extract widgets/helpers once you approach the threshold.
- Resolve any lint warnings before wrapping up a task so future runs start clean.

## Workflow

1. Update domain contracts/models.
2. Implement data repositories and register via `get_it`.
3. Extend Cubits/Blocs; inject dependencies.
4. Build UI with focused widgets; keep business rules in cubits/domain.
5. Add or update unit/bloc/widget/golden tests; use fakes for determinism.

## Testing Focus

- `bloc_test` for state flows.
- Widget/golden coverage for UI regressions (CountdownBar, CounterDisplay, etc.).
- Auth flows with `MockFirebaseAuth` + `mock_exceptions`.
- Deterministic time: `FakeTimerService().tick(n)`.
- Abort any test run exceeding 3 minutes and investigate stuck timers, unawaited futures, or hanging platform calls before rerunning.
- Cover platform contracts: update `NativePlatformService` fakes alongside channel changes and add integration coverage for new platform behaviour.

## DI Snippet

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

## Notes

- Auto-decrement interval = 5 s; counter never goes below 0.
- Supported locales: `MaterialApp.supportedLocales`.
- Platform info comes from `NativePlatformService` (MethodChannel).
- Counter UI widgets now live under `lib/features/counter/presentation/widgets/` (exported via `features/counter.dart`).
- Theme & locale contracts + cubits reside in `lib/features/settings/`; keep `lib/shared/` for cross-cutting utilities only.
- After modifying tests, rerun coverage (`flutter test --coverage` + `dart run tool/update_coverage_summary.dart`) to keep reports current.
- Keep hand-written `.dart` files under ~250 lines; split out widgets/helpers when approaching the limit (ignore generated and localization files).

## 🧠 Figma → Flutter Agent Rules

## Purpose

Automatically generate Flutter UI layouts from exported Figma assets and metadata created by `fetchFigma.js`.

## Directory Structure

All fetched Figma data lives inside:

./figma-sync/figma-data/{FrameName}_{NodeId}/
 ├── {FrameName}.json
 ├── {FrameName}.png (or .svg)
 ├── layout_manifest.json
 ├── {AssetName}_{AssetId}.svg or .png

## Layout Manifest

Each `layout_manifest.json` file includes:

```json
{
  "frame": "Profile",
  "nodeId": "0:88",
  "assets": [
    {
      "id": "1:42",
      "name": "Rectangle",
      "file": "Rectangle_1-42.svg",
      "type": "SVG",
      "position": { "x": 12, "y": 64 },
      "size": { "width": 200, "height": 80 },
      "zIndex": 0
    }
  ]
}
```

## Agent Behaviour

When prompted with:
> "create design from figma for Profile_0-88"

Agents should:

1. Locate the design data in:
   `./figma-sync/figma-data/Profile_0-88/`

2. Load `layout_manifest.json` to understand the asset hierarchy.

3. For each listed asset:
   - If `"type": "SVG"`, render using:

     ```dart
     SvgPicture.asset('assets/figma/Profile_0-88/{file}')
     ```

   - If `"type": "PNG"`, render using:

     ```dart
     Image.asset('assets/figma/Profile_0-88/{file}')
     ```

4. Use the `position` and `size` fields from the manifest to place widgets inside a `Stack`:

   ```dart
   Positioned(
     left: x,
     top: y,
     width: width,
     height: height,
     child: widget,
   )
   ```

5. Wrap everything inside a root `Stack` with the frame’s full width and height.

6. Always render `{FrameName}.png` (or `.svg`) as the background layer first, then overlay UI components in ascending `zIndex`.

## Error Handling

- If an SVG cannot be rendered, the agent must fall back to the `.png` version (if available).
- If a file is missing, render an empty `SizedBox` instead of failing the build.

## Agent Intelligence

- The agent must automatically detect if the assets are stored under `./figma-sync/figma-data/`.
- If multiple nodes are exported (e.g., Profile_0-88 and Logged_out_0-2), it should pick the one that matches the user’s prompt.
- When generating Flutter screens, it should infer logical widget names from the `name` field in each asset.

## Command Triggers

The following prompt patterns should activate this process:

- `"create design from figma for {FrameName}_{NodeId}"`
- `"generate Flutter screen from Figma node {NodeId}"`
- `"build Flutter layout using {layout_manifest.json}"`
