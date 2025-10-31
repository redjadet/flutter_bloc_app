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

### Purpose

Automatically generate Flutter UI layouts from exported Figma assets and metadata created by `fetchFigma.js`.

### Setup: Fetching Data from Figma

1. **Install Dependencies** (first time only):

   ```bash
   cd figma-sync
   npm install
   ```

2. **Configure Environment Variables**:

   Create `figma-sync/.env` with:

   ```env
   FIGMA_TOKEN=your_figma_personal_access_token
   FILE_KEY=your_figma_file_key
   NODE_IDS=0:88,0:2
   EXPORT_FORMAT=png
   ```

   **Alternative: Use Figma URL** (auto-extracts FILE_KEY and NODE_IDS):

   ```env
   FIGMA_TOKEN=your_figma_personal_access_token
   FIGMA_URL=https://www.figma.com/design/{FILE_KEY}/...?node-id=0-88
   EXPORT_FORMAT=png
   ```

3. **Run the Fetch Script**:

   ```bash
   cd figma-sync
   npm run fetch
   ```

   Or watch mode (auto-refetches on file changes):

   ```bash
   npm run watch
   ```

### What `fetchFigma.js` Generates

For each Figma node, the script creates:

1. **JSON Metadata**: `{FrameName}.json` - Full Figma API response with node structure
2. **Main Frame Image**: `{FrameName}.{format}` - Exported frame (png/jpg/svg based on `EXPORT_FORMAT`)
3. **Vector Assets**: Individual SVG exports for vector layers (VECTOR, ELLIPSE, RECTANGLE, POLYGON, STAR, LINE types)
4. **Layout Manifest**: `layout_manifest.json` - AI-readable structure with positions, sizes, z-index
5. **Combined Summary**: `all_nodes.json` - Combined metadata for all fetched nodes

### Directory Structure

All fetched Figma data lives inside:

```text
./figma-sync/figma-data/{FrameName}_{NodeId}/
 ├── {FrameName}.json              # Full Figma API metadata
 ├── {FrameName}.png               # Main frame export (or .svg/.jpg)
 ├── layout_manifest.json          # AI-readable layout structure
 ├── {AssetName}_{AssetId}.svg     # Individual vector assets
 └── ...
```

### Layout Manifest Format

Each `layout_manifest.json` file includes:

```json
{
  "frame": "Profile",
  "nodeId": "0:88",
  "assets": [
    {
      "id": "0:89",
      "name": "Rectangle",
      "file": "Rectangle_0-89.svg",
      "type": "RECTANGLE",
      "position": { "x": 8637, "y": 300 },
      "size": { "width": 375, "height": 812 },
      "zIndex": 0
    }
  ]
}
```

**Important Notes:**

- `position.x` and `position.y` are **absolute coordinates** from Figma's canvas (may be large numbers)
- Convert to **relative positions** when implementing Flutter layouts
- `type` can be: `RECTANGLE`, `ELLIPSE`, `VECTOR`, `POLYGON`, `STAR`, `LINE`
- Assets are sorted by `zIndex` (ascending = bottom to top)

### Agent Behaviour

When prompted with:
> "create design from figma for Profile_0-88"

Agents should:

1. **Locate Design Data**:
   - Check `./figma-sync/figma-data/Profile_0-88/`
   - If not found, search all subdirectories in `figma-data/` for matching frame name or node ID

2. **Load Layout Manifest**:
   - Read `layout_manifest.json` to understand asset hierarchy
   - Parse frame dimensions from main image or first asset's bounding box

3. **Copy Assets to Flutter**:
   - Copy all assets from `figma-sync/figma-data/{FrameName}_{NodeId}/` to `assets/figma/{FrameName}_{NodeId}/`
   - Update `pubspec.yaml` to include assets:

     ```yaml
     flutter:
       assets:
         - assets/figma/{FrameName}_{NodeId}/
     ```

4. **Generate Flutter Code**:

   - For each asset in `layout_manifest.json`, determine asset type:
     - If `type` contains `RECTANGLE`, `ELLIPSE`, `VECTOR`, etc. → Use SVG if `.svg` file exists
     - Otherwise → Use PNG/Image

   - Render assets:

     ```dart
     // SVG assets
     SvgPicture.asset('assets/figma/{FrameName}_{NodeId}/{file}')

     // PNG/Image assets
     Image.asset('assets/figma/{FrameName}_{NodeId}/{file}')
     ```

5. **Layout Positioning**:

   - Convert absolute Figma coordinates to relative Flutter layout
   - Calculate relative positions based on frame bounds:

     ```dart
     // If frame starts at (frameX, frameY) with width frameWidth
     final relativeX = asset.position.x - frameX;
     final relativeY = asset.position.y - frameY;
     ```

   - Use `Positioned` widgets in a `Stack`:

     ```dart
     Positioned(
       left: relativeX,
       top: relativeY,
       width: asset.size.width,
       height: asset.size.height,
       child: widget,
     )
     ```

6. **Layer Ordering**:
   - Render main frame image (`{FrameName}.png`) as background layer first
   - Overlay UI components in ascending `zIndex` order (0 = bottom, higher = top)

### Error Handling

- If an SVG cannot be rendered, fall back to `.png` version (if available)
- If an asset file is missing, render an empty `SizedBox` with matching dimensions instead of failing
- If `layout_manifest.json` is missing, attempt to parse `{FrameName}.json` directly
- Always validate asset paths exist before generating code

### Agent Intelligence

- Automatically detect assets stored under `./figma-sync/figma-data/`
- Support multiple node exports: if multiple frames exist (e.g., `Profile_0-88` and `Logged_out_0-2`), match based on user prompt
- Infer logical widget names from asset `name` field (e.g., "Rectangle" → `RectangleWidget`, "Ellipse" → `CircleAvatar`)
- Prefer semantic Flutter widgets (e.g., `Container` with `BoxDecoration` for rectangles) over raw image rendering when appropriate
- Generate responsive layouts when frame dimensions suggest mobile (common width: 375px) or tablet sizes

### Command Triggers

The following prompt patterns should activate this process:

- `"create design from figma for {FrameName}_{NodeId}"`
- `"generate Flutter screen from Figma node {NodeId}"`
- `"build Flutter layout using {FrameName}_{NodeId}"`
- `"create Flutter widget from figma-sync/figma-data/{FrameName}_{NodeId}"`
- `"generate UI from {Figma URL}"`
- `"generate Flutter code from {Figma URL}"`
- `"create design from {Figma URL}"`

**Example URL format:**

```text
https://www.figma.com/design/J3e1WuK1n9JKzwxldOMr3m/Figma-Basics?node-id=0-702
```

### Handling Direct Figma URLs

When a user provides a direct Figma URL, agents must:

1. **Parse the URL** to extract:
   - `FILE_KEY`: Found in the path after `/design/` (e.g., `J3e1WuK1n9JKzwxldOMr3m`)
   - `NODE_ID`: Found in the `node-id` query parameter (e.g., `0-702` needs conversion to `0:702`)

2. **Set up Environment for Fetching**:

   - Check if `figma-sync/.env` exists
   - If missing or incomplete, create/update `.env` with:

     ```env
     FIGMA_TOKEN=<existing_token_or_prompt_user>
     FIGMA_URL=<provided_url>
     EXPORT_FORMAT=png
     ```

   - **Note**: If `FIGMA_TOKEN` is missing, prompt the user to provide it or use an existing token from the environment

3. **Fetch Data from Figma**:

   ```bash
   cd figma-sync
   npm run fetch
   ```

   - This will automatically extract `FILE_KEY` and `NODE_IDS` from `FIGMA_URL` and fetch the data
   - Assets will be saved to `figma-sync/figma-data/{FrameName}_{NodeId}/`

4. **Generate Flutter Code**:
   - Follow the standard workflow below using the newly fetched data
   - The frame name and node ID will be determined from the fetched data structure

### Workflow Integration

**When starting from a Figma URL:**

1. Parse URL and set up `.env` (see "Handling Direct Figma URLs" above)
2. Run `cd figma-sync && npm run fetch` to fetch assets
3. Locate the generated data in `figma-sync/figma-data/{FrameName}_{NodeId}/`
4. Copy assets to `assets/figma/{FrameName}_{NodeId}/` directory
5. Update `pubspec.yaml` with asset declarations
6. Run `flutter pub get`
7. Generate Flutter code following Clean Architecture (place in appropriate feature's `presentation/widgets/`)
8. Run quality checks: `dart format .`, `flutter analyze`, `flutter test`

**When starting from existing fetched data:**

1. Copy assets to `assets/figma/` directory
2. Update `pubspec.yaml` with asset declarations
3. Run `flutter pub get`
4. Generate code following Clean Architecture (place in appropriate feature's `presentation/widgets/`)
5. Run quality checks: `dart format .`, `flutter analyze`, `flutter test`
