# Dispersion Analyzer MVP (Mann-Whitney U-Test) Plan

## Core Concepts

### What is dispersion?

Dispersion is how spread out shot impacts are around the intended aiming point.
If impacts are tightly grouped, dispersion is low (better consistency). If impacts are spread out, dispersion is high (lower consistency).
In this app, each shot hole is converted into coordinates relative to the aiming point, then into radial distance (distance from center), which is used for analysis.

### What is the Mann-Whitney U-test?

The Mann-Whitney U-test is a non-parametric statistical test used to compare two independent groups of values and check whether one group tends to have larger or smaller values than the other.
It does not require normal distribution assumptions, which makes it a good fit for real-world dispersion data that can be skewed or include outliers.
In this app, the test compares radial distances from two selected datasets and returns a U statistic and p-value to indicate whether the difference is likely statistically significant.

### Coordinate system and calibration

- **Origin**: The aiming point is the origin. All point coordinates are relative to it.
- **Units**: Stored and analyzed in millimeters (mm); distance to target in meters. UI may display inches/yards; convert at display only.
- **Calibration**: User places two endpoints on the image and enters the known real length. Scale factor = `knownLengthMm / pixelDistance(endpoint1, endpoint2)`. Point positions in mm = (pixelOffset from aim point) × scale factor.
- **MOA**: `MOA = (radialMm / distanceMm) × (180 × 60 / π)` (radial and distance in mm; result in arcminutes). Shooting distance is required for MOA; raw radial mm is always available.

## Summary

Build a new local-only Flutter feature for iOS/Android that lets users capture/import group photos, calibrate scale, mark aim point and shot holes, save groups/datasets, combine datasets into derived datasets, and compare any two datasets with a two-sided Mann-Whitney U-test on radial distance from aim point.
The design follows existing project architecture: Domain → Data → Presentation, Cubit-based state, Hive persistence, route-level Cubit init, adaptive/responsive UI, localized strings, and project validation scripts.

## Frameworks and QA Approach

### 1) What frameworks will you work with?

- **Flutter (Dart)** for cross-platform mobile UI and app runtime.
- **flutter_bloc (Cubit)** for presentation-layer state management and business-flow orchestration.
- **Freezed + json_serializable** for immutable state/domain models and reliable serialization.
- **Hive** for local offline persistence of groups, datasets, and derived dataset metadata.
- **go_router** for navigation integration with existing app routing.
- **image picker/camera plugin(s)** for capture and gallery import in the group creation flow.
- **Project shared UI utilities** (`CommonPageLayout`, adaptive widgets, responsive extensions, `showAdaptiveDialog`) for consistent UX and platform-adaptive behavior.

### 2) Describe your approach to testing and improving QA

- **Risk-first test strategy**:
  Focus first on statistically critical and regression-prone parts: Mann-Whitney implementation, tie handling, outlier detection, calibration math, and dataset merge provenance.
- **Layered automated tests**:
  - Unit tests for pure math/logic (U-test, IQR outliers, unit conversions, merge logic).
  - Cubit tests for workflow/state transitions, error handling, and async lifecycle guards.
  - Widget tests for calibration/point-marking interactions and comparison screen behavior.
- **Deterministic statistical validation**:
  Validate U-statistic and p-values against fixed known datasets (including ties and edge cases) so future refactors cannot silently break analysis accuracy.
- **Guardrail-driven quality checks**:
  Run `./bin/checklist` to enforce architecture/lifecycle/UI/performance rules and prevent known bug classes.
- **Coverage and regression discipline**:
  Keep high-value coverage on domain and Cubit logic; run targeted suites plus full regression before release; update coverage summary via `dart run tool/update_coverage_summary.dart`.
- **Short QA feedback loop**:
  Implement in small phases (domain → data → presentation), run tests/checklist at each phase, and fix failures immediately to reduce late-stage defect accumulation.

## Scope Locked

- Platform: iOS + Android.
- Storage: local only (no account/cloud sync in v1).
- Image input: camera + gallery.
- Test variable: radial distance from aim point.
- Outliers: automatic IQR rule on radial distance (1.5×IQR), plus highlight/flag.
- Significance: default alpha `0.05`, user-adjustable.
- Hypothesis output: two-sided p-value.
- Dataset merge: creates a new saved derived dataset (originals unchanged).
- Metrics shown: raw offsets, radial distance (mm/in), normalized MOA.

## Architecture and File Layout

### Domain (`lib/features/dispersion/domain/`)

- `dispersion_point.dart`
- `dispersion_group.dart`
- `dispersion_dataset.dart`
- `dispersion_comparison_result.dart`
- `dispersion_repository.dart` (contract)
- `mann_whitney_service.dart` (domain service contract + implementation interface)

### Data (`lib/features/dispersion/data/`)

- `hive_dispersion_repository.dart` (extends `HiveRepositoryBase`)
- `dispersion_dto.dart` (safe map serialization)
- `image_import_service.dart` (camera/gallery abstraction for presentation-safe use)
- `mann_whitney_service_impl.dart` (pure Dart implementation; no Flutter imports)

### Presentation (`lib/features/dispersion/presentation/`)

- `cubit/dispersion_cubit.dart`
- `cubit/dispersion_state.dart` (Freezed immutable state)
- `pages/dispersion_page.dart`
- `widgets/` for step UI: image source, calibration overlay, aim point, hole marking, dataset manager, comparison panel, recreated graph panel

### Integration

- Add DI registration via `registerLazySingletonIfAbsent` in `lib/core/di/injector_registrations.dart` or dedicated `register_dispersion_services.dart`.
- Add route constants in `lib/core/router/app_routes.dart`.
- Add route in `lib/app/router/route_groups.dart` (non-deferred for MVP simplicity).
- Add overflow entry from home app bar (`CounterPageAppBar`) for discoverability.
- Add `lib/features/dispersion/dispersion.dart` export barrel (export only public domain and presentation types; do not expose data-layer DTOs or Hive internals).

## Public APIs / Interfaces / Types

- `abstract class DispersionRepository`
- `Future<List<DispersionDataset>> fetchDatasets()`
- `Stream<List<DispersionDataset>> watchDatasets()`
- `Future<void> upsertDataset(DispersionDataset dataset)`
- `Future<void> deleteDataset(String id)`
- `Future<DispersionDataset> createDerivedDataset({required String name, required List<String> sourceDatasetIds})`
- `Future<DispersionComparisonResult> compareDatasets(String idA, String idB, {required double alpha, required bool excludeOutliers})` (repository or dedicated domain service; loads datasets, extracts radial distances, invokes Mann-Whitney, returns result)

- `class DispersionPoint`
- Fields: `id`, `xMm`, `yMm`, `radialMm`, `holeDiameterMm`, `isOutlierAuto`, `isOutlierManual`

- `class DispersionGroup`
- Fields: `id`, `name`, `capturedAt`, `distanceToTargetMeters`, `imagePath`, `calibration`, `aimPointPx`, `points`

- `class DispersionDataset`
- Fields: `id`, `name`, `groupIds`, `createdAt`, `isDerived`, `sourceDatasetIds`, `pointCount`, `metadata`

- `class DispersionComparisonResult`
- Fields: `datasetAId`, `datasetBId`, `nA`, `nB`, `uStatistic`, `zScore`, `pValueTwoSided`, `alpha`, `isSignificant`, `effectSizeRankBiserial`, `excludedOutliersCount`

## Statistical Implementation Spec

- Input samples: radial distances in mm from selected datasets, excluding flagged outliers when “exclude outliers” is enabled.
- Rank all pooled values with average ranks for ties.
- Compute `U1`, `U2`, and use `U = min(U1, U2)`.
- Tie correction applied in variance term.
- Asymptotic normal approximation with continuity correction for MVP.
- Two-sided p-value: `p = 2 * (1 - Phi(|z|))`.
- Provide rank-biserial effect size.
- **Small sample (n &lt; 20)**: Still report U and asymptotic p-value; show an explicit “small sample caution” in the UI so users know the p-value is approximate (exact test not in MVP).
- Deterministic unit-tested math utilities (pure Dart).

## UX Flow (MVP)

1. Create Group

- Choose image source (camera/gallery).
- Place 2 calibration endpoints on image and input known real length.
- Enter shooting distance (meters/yards with internal canonical meters).
- Place aiming point.
- Add shot holes by placing a circle on each hole with selected hole diameter.
- Save group; points converted to offsets/radial in mm.

1. Dataset Management

- Create dataset from one or more groups.
- Create derived dataset by selecting existing datasets.
- Keep provenance (source dataset IDs) for reproducibility.

1. Comparison

- Select dataset A and B.
- Configure alpha and “exclude outliers” toggle (when on: points marked as outliers are omitted from the U-test sample only; they remain visible on the recreated graph, e.g. dimmed or with distinct styling).
- Run U-test and show significance summary, p-value, U, z, effect size.
- Show recreated dispersion graph for both groups with outliers highlighted/flagged.

## Persistence and Data Rules

- Hive box: `dispersion_data`.
- Keys: `datasets`, `groups`, `version`.
- **Images**: Store image file path only. Save captured/imported images under a dedicated app directory (e.g. `dispersion_images/` in app documents) so paths are stable and portable; reference by relative or app-scoped path in Hive.
- Store canonical metric values internally (mm, meters); UI supports display conversion.
- Soft-validate corrupted entries and skip invalid records (same defensive pattern as existing Hive repos).

## Validation and Testing Plan

1. Unit tests

- Mann-Whitney correctness on known samples and tie scenarios.
- IQR outlier detection cases.
- Unit conversions (px→mm, mm→MOA).
- Derived dataset merge/provenance logic.

1. Cubit tests

- Full creation workflow state transitions.
- Async guards (`isClosed` before emits), error handling path.
- Comparison state updates for include/exclude outliers and alpha changes.

1. Widget tests

- Calibration interaction.
- Aim point and hole placement interactions.
- Dataset selection and comparison panel rendering.
- Outlier highlighting visibility.

1. Regression/quality

- Run `./bin/checklist`.
- Run relevant test suites.
- Update coverage summary with `dart run tool/update_coverage_summary.dart`.

## Dependencies and Config

- Add image acquisition package(s) for camera/gallery workflow.
- Keep feature isolated to avoid impacting existing modules.
- Add localized strings in ARB files for all new text.
- No raw Material buttons/dialogs/colors; use project adaptive/common widgets.

## Delivery Phases

1. Phase 1: Domain models, repository contract, Mann-Whitney service + unit tests.
2. Phase 2: Hive repository and dataset/group persistence + tests.
3. Phase 3: Cubit/state workflow for create-group, dataset merge, comparison.
4. Phase 4: UI pages/widgets for capture/calibration/marking/comparison graph.
5. Phase 5: Routing, DI, localization, home overflow entry.
6. Phase 6: Validation scripts, tests, coverage verification, polish.

## Assumptions and Defaults

- “Simple/fast release” means no authentication, sync, or backend.
- Mann-Whitney implementation uses asymptotic two-sided p-value in MVP.
- Outlier auto-flag is IQR-based on radial distances; manual override can coexist.
- “Exclude outliers”: excluded points are omitted from the U-test sample only; they remain visible on the recreated dispersion graph (e.g. dimmed or distinct style).
- Comparison is done on radial distance distribution, not separate axis tests.
- Shooting distance is required for MOA output; raw radial mm remains available regardless.

---

## User Guide: What You Can Do in the App (Current MVP)

This section is a step-by-step guide for using the Dispersion Analyzer as implemented in the current release. It also states what is not yet available in the UI (see **Current MVP scope and limitations** below).

### How to open the Dispersion Analyzer

1. Open the app on your device or simulator (e.g. iPhone simulator).
2. You should see the **Counter** (home) screen.
3. Tap the **More** (⋮) button in the **app bar** (top right).
4. In the menu, tap **"Dispersion Analyzer"**.
5. The Dispersion Analyzer home screen opens (list of datasets and two main actions).

### 1. Take a picture of your dispersion group

1. From the Dispersion Analyzer home, tap **"Create group"** (or equivalent label).
2. On the Create Group screen, choose the image source:
   - **Camera** – take a new photo of your target/group.
   - **Gallery** – pick an existing image from the device.
3. After selecting or capturing, the image appears in the form. You use this image to define scale and aim (see below); in the current MVP, shot points are not yet added by tapping on the image (see limitations).

### 2. Set a known reference length (calibration)

1. On the same Create Group screen, find the **Calibration** section.
2. Enter the **two calibration endpoints in pixels** (e.g. from an external tool or known positions):
   - **Endpoint 1 X (px)**, **Endpoint 1 Y (px)**.
   - **Endpoint 2 X (px)**, **Endpoint 2 Y (px)**.
3. Enter the **Known length (mm)** – the real-world length in mm that the segment between the two endpoints represents.
4. The app uses this to compute scale (mm per pixel) for converting later point positions to mm.

### 3. Position the aiming point

1. In the **Aim point (pixels)** section, enter:
   - **Aim X (px)** and **Aim Y (px)** – the pixel coordinates of the aiming point on the image.
2. All shot positions are interpreted relative to this aim point.

### 4. Enter distance and hole size

1. **Distance (m)** – enter the shooting distance to the target in meters.
2. **Hole diameter (mm)** – enter the nominal hole diameter in mm. In the current MVP this is a **single value for the whole group** (not per-point).

### 5. Name and save the group

1. Enter a **Group name** (e.g. "Session 1").
2. Tap **"Save group"**.
3. The app creates one **dataset** per saved group (1:1 in current flow). You return to the home screen and see the new dataset in the list.

**Note:** In the current MVP there is **no UI yet to add individual dispersion points** (e.g. by positioning a circle on each hole on the image). The backend supports points; the create-group form only shows the number of points. So saved groups may have zero points until a future release adds point-entry (e.g. tap-to-place circles). You can still save calibration, aim, distance, and hole diameter for the group.

### 6. Compare two datasets with the Mann-Whitney U-test

1. From the Dispersion Analyzer home, tap **"Compare datasets"** (or equivalent).
2. Select **Dataset A** and **Dataset B** from the dropdowns (any two saved datasets).
3. Set **Alpha** (significance level, e.g. 0.05) with the slider.
4. Use the **"Exclude outliers"** switch: when on, points marked as outliers (IQR-based) are omitted from the U-test sample.
5. Tap **"Run comparison"**.
6. The app shows the **comparison result**: U statistic, z-score, two-sided p-value, whether the difference is statistically significant at the chosen alpha, effect size (rank-biserial), and a **small sample caution** if either sample has fewer than 20 points.

### 7. Outliers (current behavior)

- **Automatic:** When a group is saved, the app applies IQR-based outlier detection (1.5×IQR on radial distances) and marks points as auto-outliers.
- **Comparison:** The "Exclude outliers" option controls whether those marked points are included in the Mann-Whitney test or not.
- **Manual:** On the Create Group screen, a point list under the image shows Radial (mm), Auto, Manual (toggle), and Effective outlier status per point. You can mark or unmark any point as a manual outlier; effective outlier = auto OR manual.
- **Graph:** The Compare screen shows a dispersion graph below the numeric result when two datasets are compared; dataset A/B points are plotted in a common mm-from-aim coordinate system with outlier-aware styling (outliers remain visible when excluded from the test).

---

## Testing with sample data (debug builds)

In **debug builds only**, the Create Group screen shows extra actions: **"Use test image"** and **"Fill test values"**. You can add points either by **tapping on the image** (point editor) or by using **"Add sample points"** (debug only).

### 1. Use test image

- Tap **"Use test image"** (next to Camera / Gallery). The app loads a built-in small image and sets it as the group image. You can then enter calibration, aim, distance, and hole diameter. Once calibration and aim are set, the image shows a **point editor**: tap on the image to add shot points relative to the aim; tap a point marker to select it, then use **"Delete selected"** to remove it.

### 2. Suggested test values

Use these values to get a known scale and consistent results. In **debug builds**, tap **"Fill test values"** to fill all fields below from this table in one go.

| Field | Value | Notes |
| ----- | ----- | ----- |
| Endpoint 1 X (px) | 0 | |
| Endpoint 1 Y (px) | 0 | |
| Endpoint 2 X (px) | 200 | |
| Endpoint 2 Y (px) | 0 | 200 px horizontal segment |
| Known length (mm) | 50 | Scale = 50/200 = **0.25 mm/px** |
| Aim X (px) | 100 | |
| Aim Y (px) | 100 | |
| Distance (m) | 25 | |
| Hole diameter (mm) | 5 | |
| Group name | e.g. "Test group A" | |

### 3. Adding points

- **Tap on image:** After setting **calibration**, **aim**, and **hole diameter**, the image becomes a point editor. Tap where each shot hole is; points are converted to mm from aim using the calibration scale. A **point list** below shows radial (mm), Auto/Manual/Outlier status; use the **Mark as outlier** switch per point if needed.
- **Add sample points (debug only):** Alternatively, tap **"Add sample points"** (shown when the point editor i
s visible). Each tap adds **1–2 points** with known radials (up to 6 predefined points total); they appear on the image like tap-added points. Hole diameter can be unset (default 1.0 mm for sample points). You can then save the group and use it in Compare or Combine.

### 4. Combine datasets (optional)

- From the Dispersion home screen, tap **"Combine datasets"**. Select **at least 2 datasets** (e.g. Test A and Test B), enter a **combined dataset name** (e.g. "Test A + B"), and tap **"Create combined dataset"**. The new derived dataset appears on home with a "Derived" badge and can be used in **Compare datasets**.

### 5. Quick test flow

1. Open Dispersion Analyzer → **Create group**.
2. Tap **Use test image** (required – the form needs an image before save).
3. Enter the **test values** from the table above (or in debug, tap **Fill test values** to fill them automatically).
4. Add points: either **tap on the image** for each shot, or tap **Add sample points** (debug, 1–2 points per tap). Optionally adjust **manual outlier** toggles in the point list.
5. Enter group name **"Test A"** → **Save group**.
6. Back on home, tap **Create group** again → **Use test image** → **Fill test values** (or re-enter) → add points (tap or Add sample points) → name **"Test B"** → **Save group**.
7. **(Optional)** Tap **Combine datasets** → select Test A and Test B → name "Combined" → **Create combined dataset**.
8. Tap **Compare datasets** → choose two datasets (e.g. Test A and Test B, or one derived). Select **Dataset A** and **Dataset B** from the dropdowns → **Run comparison**. You should see the **numeric result** (n(A), n(B), U, z, p-value, significant/not) and the **Dispersion graph** below with both datasets’ points and a legend (A, B, Outlier).

---

## Current MVP Scope and Limitations

The following reflect the **current UI and backend** after implementing the missing-features plan (point editor, combine UI, manual outlier controls, dispersion graph):

| Requirement | In app? | Notes |
| ----------- | ------- | ----- |
| Take a picture of dispersion group | Yes | Camera + Gallery on Create Group. |
| Known reference length | Yes | Calibration endpoints (px) + known length (mm). |
| Distance at which dispersion occurred | Yes | Distance (m) field. |
| Position the aiming point | Yes | Aim X/Y in pixels (numeric entry). |
| Hole diameter | Yes | One value per group on Create Group. |
| Add each dispersion point (tap on image) | Yes | Point editor: tap to add, tap marker to select, Delete selected to remove. Calibration + aim + hole diameter required. |
| Fill test values (debug) | Yes | Debug-only "Fill test values" fills calibration, aim, distance, hole diameter, and group name from the suggested test table. |
| Add sample points (debug) | Yes | Debug-only "Add sample points" adds 1–2 points per tap (6 predefined total); shown when point editor is visible; points appear on image. |
| Combine datasets into derived dataset | Yes | "Combine datasets" on home → multi-select datasets, name → Create combined dataset. |
| Compare two datasets (Mann-Whitney) | Yes | Compare screen with A/B dropdowns, alpha, exclude outliers, Run comparison, result card. |
| Recreated dispersion graph | Yes | Graph below result card when comparison is run; A/B points in mm-from-aim with legend and outlier styling. |
| Outliers: auto IQR | Yes | Applied on add/remove and on save; point list shows Auto Y/N. |
| Outliers: manual toggle | Yes | Point list has "Mark as outlier" switch per point; effective = auto OR manual. |

**Summary:** You can capture/import a photo, set calibration and aim, set distance and hole diameter, add points by tapping on the image (or use "Add sample points" in debug), optionally set manual outlier per point, save a group, combine two or more datasets into a derived dataset from the UI, and compare any two datasets with the Mann-Whitney U-test and a dispersion graph. In debug builds, "Fill test values" fills the suggested test table values in one tap. End-to-end regression tests for the full flow were not completed (Issue 6 cancelled).

---

## Implementation Plan for Missing Features

This plan is updated against the current codebase state (feature files under `lib/features/dispersion/`). It focuses only on true UI/UX and workflow gaps.

### Current gap analysis (code-verified)

- Implemented:
  - Camera + gallery import (`ImageImportServiceImpl`).
  - Group save flow with calibration, aim, distance, and points support in Cubit.
  - Per-point fields in domain/data (`holeDiameterMm`, `isOutlierAuto`, `isOutlierManual`) and Hive DTO persistence.
  - Dataset comparison with Mann-Whitney U-test, alpha, and exclude-outliers toggle.
  - Derived dataset creation in repository/cubit (`createDerivedDataset`).
  - Tap-on-image point editor (`dispersion_point_editor.dart`): tap to add, select, delete; integrated in Create Group body.
  - Combine datasets UI: "Combine datasets" on home, multi-select + name, create derived dataset.
  - Recreated dispersion graph on Compare screen (`dispersion_compare_graph.dart`), legend, outlier-aware styling.
  - Manual outlier controls: point list with Radial/Auto/Manual/Effective and per-point "Mark as outlier" switch.
- Not done:
  - End-to-end workflow tests for the full feature (Issue 6 cancelled).

### Phase 1 – Point editor on image (highest priority blocker)

- Goal: Replace debug-only sample points with production point-entry UX.
- Files:
  - Add: `lib/features/dispersion/presentation/widgets/dispersion_point_editor.dart`
  - Update: `lib/features/dispersion/presentation/widgets/dispersion_create_group_body.dart`
  - Update: `lib/features/dispersion/presentation/cubit/dispersion_cubit.dart` (selection/edit helpers)
  - Update: `lib/features/dispersion/presentation/cubit/dispersion_state.dart` (selected point id, editor mode if needed)
- Implementation:
  - Render image with overlay markers (aim + points) in a `RepaintBoundary`.
  - Tap to add point by converting tap position to offset from aim and calling `addCreatePoint`.
  - Tap existing marker to select; allow delete and optional drag-to-adjust.
  - Keep current numeric calibration/aim fields for MVP (do not introduce calibration-on-canvas yet).
- Acceptance criteria:
  - User can add, select, move (or delete), and review points before saving.
  - `pointsCount` updates correctly and saved groups persist edited points.
  - No side effects in `build()`; all actions via callbacks/Cubit methods.
- Tests:
  - Widget tests for add/select/delete flows.
  - Cubit tests for add/remove/update math and state transitions.

### Phase 2 – Combine datasets UI (unlock derived dataset workflow)

- Goal: Expose existing `createDerivedDataset` capability in UI.
- Files:
  - Add: `lib/features/dispersion/presentation/widgets/dispersion_combine_datasets_body.dart`
  - Update: `lib/features/dispersion/presentation/cubit/dispersion_state.dart` (new screen enum or modal state)
  - Update: `lib/features/dispersion/presentation/pages/dispersion_page.dart`
  - Update: `lib/features/dispersion/presentation/widgets/dispersion_home_body.dart`
- Implementation:
  - Add “Combine datasets” action on home.
  - Multi-select dataset list + derived dataset name field.
  - Validate: minimum 2 datasets selected, non-empty name, no duplicate dataset ids.
  - Submit through `createDerivedDataset`.
- Acceptance criteria:
  - Derived dataset appears immediately in home list with derived badge.
  - Source dataset IDs are retained and persisted.
- Tests:
  - Cubit test for validation + success path.
  - Widget test for combine form and error states.

### Phase 3 – Recreated dispersion graph in compare view

- Goal: Visualize both compared distributions alongside numeric result.
- Files:
  - Add: `lib/features/dispersion/domain/dispersion_graph_point.dart` (pure domain view model)
  - Add: `lib/features/dispersion/domain/dispersion_graph_projection.dart` (pure helper)
  - Add: `lib/features/dispersion/presentation/widgets/dispersion_compare_graph.dart`
  - Update: `lib/features/dispersion/presentation/widgets/dispersion_compare_body.dart`
  - Optional update: `lib/features/dispersion/data/hive_dispersion_repository.dart` (if projection input helper needed)
- Implementation:
  - Build graph points from selected datasets in a common coordinate system centered at aim.
  - Draw dataset A/B markers with distinct color-scheme-driven styles.
  - Keep outliers visible; when exclude-outliers is ON, only statistical sample changes, not graph visibility.
  - Add compact legend and optional tap tooltip.
- Acceptance criteria:
  - Graph always matches selected A/B datasets and current outlier-exclude toggle semantics.
  - Works on small screens and text scale >= 1.3 without overflow.
- Tests:
  - Unit tests for projection helper.
  - Widget/golden tests for deterministic graph render.

### Phase 4 – Manual outlier control + highlighting

- Goal: Let users manually override outlier status and make status visible.
- Files:
  - Update: `lib/features/dispersion/presentation/widgets/dispersion_create_group_body.dart` (point list + toggle)
  - Update: `lib/features/dispersion/presentation/cubit/dispersion_cubit.dart` (toggle API)
  - Update: `lib/features/dispersion/presentation/cubit/dispersion_state.dart`
  - Update: `lib/features/dispersion/presentation/widgets/dispersion_compare_graph.dart`
- Implementation:
  - Add per-point outlier status row (Auto, Manual, Effective).
  - Provide manual toggle (`isOutlierManual`) per point.
  - Graph markers visibly distinguish regular vs outlier points.
  - Maintain existing repository behavior: effective outlier = auto OR manual.
- Acceptance criteria:
  - Manual toggle persists after save/load.
  - Comparison result changes when outlier exclusion is enabled and manual flags are edited.
- Tests:
  - Repository round-trip tests for manual flags.
  - Cubit tests for manual toggle.
  - Widget tests for highlight/toggle behavior.

### Phase 5 – QA hardening and release readiness

- Goal: Stabilize feature before broader implementation work.
- Required checks:
  - `./bin/checklist`
  - Targeted tests for dispersion domain/data/presentation
  - `dart run tool/update_coverage_summary.dart`
- Additional quality work:
  - Replace remaining hardcoded error strings in cubit with localized messages.
  - Add empty-state messaging for comparisons with zero effective points.
  - Add one end-to-end widget flow: create group with points -> create derived dataset -> compare -> verify result + graph.
- Exit criteria:
  - No failing checks/tests.
  - No lifecycle guard violations (`mounted`/`isClosed` checks preserved).
  - Feature usable in release mode without debug-only helpers.

### Recommended execution order

1. Phase 1 (point editor)
2. Phase 2 (combine datasets UI)
3. Phase 4 (manual outlier controls)
4. Phase 3 (graph; depends on finalized point/outlier UX)
5. Phase 5 (QA hardening)

This order minimizes rework and keeps each increment independently testable and shippable.

---

## Issue-by-Issue Task Checklist

Use this as the implementation tracker. Mark each issue complete only when all acceptance checks pass.

### Issue 1: Build point editor overlay on create group screen

- [x] Add `dispersion_point_editor.dart` with image + overlay markers.
- [x] Support tap-to-add point relative to aim point.
- [x] Support select point and delete selected point.
- [x] Integrate editor into `dispersion_create_group_body.dart`.
- [x] Ensure `pointsCount` and saved group points match editor state.
- [x] Add widget tests for add/select/delete behavior.
- [x] Add cubit tests for add/remove point flow and coordinate conversion.

### Issue 2: Add combine datasets UI flow

- [x] Add new combine datasets body widget.
- [x] Add navigation entry from dispersion home screen.
- [x] Add dataset multi-select + derived dataset name input.
- [x] Validate inputs (min 2 datasets, non-empty name).
- [x] Submit using existing `createDerivedDataset`.
- [x] Show new derived dataset in home list with derived badge.
- [x] Add cubit + widget tests for success and validation errors.

### Issue 3: Add manual outlier controls in create flow

- [x] Add point list under editor showing radial and outlier status.
- [x] Add manual toggle for `isOutlierManual` per point.
- [x] Add cubit API for manual outlier toggle.
- [x] Persist manual flags through save/load flow.
- [x] Ensure compare logic still treats outlier as auto OR manual.
- [x] Add repository and cubit tests for flag round-trip and behavior.
- [x] Add widget tests for toggle interactions.

### Issue 4: Add recreated dispersion graph to compare screen

- [x] Add pure helper for graph projection in domain layer.
- [x] Add compare graph widget for plotting dataset A/B points.
- [x] Add legend and outlier-aware point styling.
- [x] Keep outliers visible even when excluded from statistical sample.
- [x] Integrate graph below numeric comparison card.
- [x] Add projection unit tests.
- [x] Add widget/golden tests for graph rendering.

### Issue 5: Localize remaining hardcoded strings in dispersion flow

- [ ] Replace hardcoded cubit error messages with localized keys.
- [ ] Add ARB keys for new editor/combine/graph/outlier labels.
- [ ] Regenerate localization outputs.
- [ ] Verify no hardcoded-string check failures for dispersion files.

### Issue 6: End-to-end feature regression tests *(cancelled / not completed)*

- [ ] Add one end-to-end widget flow.
- [ ] Create group with image + calibration + aim + points.
- [ ] Create derived dataset from two datasets.
- [ ] Run compare with outliers included/excluded.
- [ ] Assert numeric result and graph presence.
- [ ] Add one empty-state comparison test (no effective points).

### Issue 7: Final QA and release gate

- [ ] Run `./bin/checklist`.
- [ ] Run dispersion-related unit, cubit, widget, and golden tests.
- [ ] Run `dart run tool/update_coverage_summary.dart`.
- [ ] Verify responsive behavior and text scale >= 1.3.
- [ ] Confirm release mode usability without debug-only helpers.
- [ ] Confirm no lifecycle guard violations (`mounted`/`isClosed`).

### Dependency order

- [x] Issue 1
- [x] Issue 2
- [x] Issue 3
- [x] Issue 4
- [ ] Issue 5
- [ ] Issue 6
- [ ] Issue 7
