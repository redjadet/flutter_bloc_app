# Dispersion Analyzer — Technical Specification

**Version:** 1.1
**Target platforms:** Flutter mobile (iOS + Android)
**Current state:** A working demo exists under the `Dispersion Analyzer` page in the app.

## 0. Project Intent

This project delivers a practical, local-first mobile tool to analyze shot dispersion from target photos using the Mann-Whitney U-test.

Primary goals:

- Convert manually marked shot holes into normalized coordinate data.
- Compare two datasets statistically with transparent assumptions.
- Keep MVP scope small for fast release and low risk.

Non-goals for MVP:

- Automatic hole detection from image processing.
- Cloud sync or multi-user collaboration.
- Heavy analytics or model-based prediction.

---

## 1. Functional Scope

### 1.1 User flow (step-by-step)

1. Open **Dispersion Analyzer**.
2. Tap **Create Group**.
3. Select image source:

- Camera capture, or
- Gallery import.

1. Set calibration:

- Enter two reference endpoints (pixel coordinates).
- Enter known real length (mm).

1. Set aim point:

- Enter aim X/Y (pixels), used as origin.

1. Enter session values:

- Distance to target (meters).
- Hole diameter (mm).
- Group name.

1. Add shot points:

- Tap on image to place points.
- Optional debug helper: add sample points.

1. Review points:

- Radial values shown.
- Auto/manual outlier flags visible.

1. Save group:

- Group is persisted.
- Dataset is created (1 group -> 1 dataset in MVP).

1. Optional: combine datasets:

- Select >= 2 datasets.
- Enter derived dataset name.
- Create merged dataset with provenance.

1. Compare datasets:

- Choose Dataset A and Dataset B.
- Set alpha.
- Toggle exclude outliers.
- Run Mann-Whitney U-test.

1. View result:

- U, z, p-value, significance label, sample sizes.
- Dispersion graph with A/B points and outlier styling.

### 1.2 Image input and calibration

- Images are imported from camera/gallery and copied into app-managed local storage.
- Calibration uses two pixel endpoints plus known real length.
- Scale factor is computed as `mm per pixel` and used for all point conversion.

### 1.3 Point creation and storage

- User taps on image to add each shot hole.
- Each point is stored relative to aim in mm (`xMm`, `yMm`, `radialMm`).
- Point also stores hole diameter and outlier flags.

### 1.4 Dataset creation, merging, comparison

- Group save creates a dataset for immediate compare usability.
- Derived dataset combines multiple datasets without modifying sources.
- Comparison always runs on radial distances (optionally excluding outliers).

### 1.5 Visualization

- Compare screen renders:
- Numeric result card.
- 2D dispersion graph for dataset A/B.
- Outliers remain visible in graph even when excluded from statistical sample.

---

## 2. Data Model

### 2.1 DispersionPoint

- `id: String`
- `xMm: double`
- `yMm: double`
- `radialMm: double`
- `holeDiameterMm: double`
- `isOutlierAuto: bool`
- `isOutlierManual: bool`
- Derived behavior: `isOutlier = isOutlierAuto || isOutlierManual`

### 2.2 DispersionGroup

- `id, name, capturedAt`
- `distanceToTargetMeters`
- `imagePath` (local file path)
- `calibration` (endpoint1Px, endpoint2Px, knownLengthMm)
- `aimPointPx`
- `points: List<DispersionPoint>`

### 2.3 DispersionDataset

- `id, name, createdAt`
- `groupIds: List<String>`
- `pointCount: int`
- `isDerived: bool`
- `sourceDatasetIds: List<String>` (for derived datasets)
- optional `metadata`

### 2.4 Statistical result model

- `datasetAId, datasetBId`
- `nA, nB`
- `uStatistic`
- `zScore`
- `pValueTwoSided`
- `alpha`
- `isSignificant`
- `effectSizeRankBiserial`
- `excludedOutliersCount`
- `smallSampleCaution`

### 2.5 Local persistence

- Local-only storage for MVP.
- Suggested implementation: Hive + DTO mapping.
- Images stored in app documents subfolder (stable path strategy).
- No backend required for core feature.

---

## 3. Image Processing & Coordinate Mapping

### 3.1 Calibration math

Given endpoints `E1(x1, y1)` and `E2(x2, y2)` in pixels:

- `pixelDistance = sqrt((x2 - x1)^2 + (y2 - y1)^2)`
- `scaleMmPerPx = knownLengthMm / pixelDistance`

### 3.2 Point conversion

For tapped point `T(tx, ty)` and aim `A(ax, ay)`:

- `offsetPx = (tx - ax, ty - ay)`
- `xMm = offsetPx.x * scaleMmPerPx`
- `yMm = offsetPx.y * scaleMmPerPx`
- `radialMm = sqrt(xMm^2 + yMm^2)`

### 3.3 Coordinate origin rule

- Aim point is always `(0,0)` in analysis space.
- All stored coordinates are relative to aim.
- This ensures consistency for merge/compare/graph projections.

### 3.4 Validation rules

- Calibration endpoint distance must be > 0.
- Known length must be > 0.
- Aim point must exist before adding points.
- Invalid calibration blocks point conversion and save.

---

## 4. Statistical Analysis

### 4.1 Why Mann-Whitney U-test here

- Non-parametric test suited for non-normal dispersion distributions.
- Compares two independent samples of radial distances.
- Robust for practical field data where normal assumptions are weak.

### 4.2 Inputs and outputs

Inputs:

- `sampleA: List<double>` radial mm values.
- `sampleB: List<double>` radial mm values.
- `alpha` significance threshold.
- `excludeOutliers` filter behavior.

Outputs:

- U statistic, z-score, two-sided p-value.
- Significance label (`p <= alpha`).
- Effect size (rank-biserial).
- Sample size and outlier-exclusion metadata.

### 4.3 Computation assumptions

- Tie handling via average ranks.
- Variance with tie correction.
- Asymptotic normal approximation with continuity correction.
- Two-sided p-value for MVP.

### 4.4 Small sample and edge cases

- If either sample is empty: no meaningful inference; return non-significant with caution.
- For small samples (e.g., `< 20` in either group): show caution badge.
- Exact p-value implementation is deferred unless explicitly requested.

### 4.5 Outlier policy

- Auto outliers from IQR rule.
- Manual outlier flags are user-driven.
- Effective outlier = auto OR manual.
- Exclude toggle affects test sample only, not graph visibility.

---

## 5. Flutter Technical Stack

### 5.1 Core stack

- Flutter + Dart
- `flutter_bloc` (Cubit)
- `freezed` / immutable state models
- Local storage (Hive)
- Routing (`go_router`)
- Image input (`image_picker`)

### 5.2 State management approach

- Cubit per feature workflow.
- Immutable state transitions.
- Repository abstraction for persistence/statistics calls.
- Domain logic in pure Dart (test-first).

### 5.3 Charting approach

- Simple 2D scatter visualization (custom painter or lightweight chart widget).
- Two series (A/B), legend, outlier style differentiation.
- Responsive behavior for phone and tablet widths.

### 5.4 Cross-platform considerations

- Permission handling for camera/gallery on both iOS and Android.
- Image file management through app-specific directories.
- Avoid platform-specific logic in domain and analysis layers.

---

## 6. MVP Scope vs Future Extensions

### 6.1 Fast MVP (in scope)

- Manual calibration + manual point marking.
- Group save and dataset listing.
- Derived dataset creation.
- Mann-Whitney compare (two-sided) with alpha and outlier filtering.
- Dispersion graph and outlier styling.
- Local persistence only.

### 6.2 Explicitly out of scope now

- Backend, authentication, cloud sync.
- Automatic hole detection/computer vision.
- Export pipeline (CSV/PDF/report generation).
- Advanced statistical test suite beyond Mann-Whitney.
- Real-time collaboration or shared projects.

### 6.3 Likely next-phase extensions

- On-image drag calibration handles.
- Zoom/pan-assisted precision point placement.
- Export to CSV/PDF.
- Optional cloud backup/sync.
- Additional effect metrics and confidence intervals.

---

## 7. Milestone Breakdown (fixed-price friendly)

### Milestone 1: Domain + Statistical Core

Deliverables:

- Finalized data models.
- Mann-Whitney service (pure Dart) with deterministic tests.
- Outlier utility + tests.

Acceptance:

- Statistical outputs match agreed benchmark datasets (including Excel parity checks).

### Milestone 2: Local Persistence + Repository

Deliverables:

- Group/dataset persistence.
- Derived dataset creation and provenance retention.
- Stable image-path persistence.

Acceptance:

- Save/reload works across app restarts without data loss.

### Milestone 3: Create Group Workflow

Deliverables:

- Image import, calibration inputs, aim inputs.
- Tap-to-add points, point list, manual outlier toggles.
- Save flow validation and errors.

Acceptance:

- A user can create and save a complete group end-to-end.

### Milestone 4: Compare + Graph

Deliverables:

- Dataset A/B selection.
- Compare execution with alpha and outlier toggle.
- Numeric result card + graph rendering.

Acceptance:

- Compare output is reproducible and graph reflects selected datasets.

### Milestone 5: QA Hardening + Release Readiness

Deliverables:

- Regression test pass (unit/cubit/widget).
- Validation script pass.
- Localization and UX polish.

Acceptance:

- Agreed checklist passes and demo build is stable on iOS + Android.

---

## 8. Risks & Unknowns

### 8.1 Technical risks

- Calibration mistakes can heavily skew output.
- Tiny/large images may create precision or performance edge cases.
- Statistical expectation mismatch with Excel if assumptions differ (tie handling, continuity correction, filtering).

### 8.2 UX risks

- Point placement precision on small screens.
- Long form flow may cause user fatigue.
- Misunderstanding of p-value/significance without clear wording.

### 8.3 Assumptions to validate early

- Unit system defaults (mm, m) and display preferences.
- Outlier policy acceptance (IQR + manual override behavior).
- Required parity level with existing Excel workbook.
- MVP release criteria (local-only acceptable, no export required).

### 8.4 Mitigation plan

- Run benchmark dataset validation early (Milestone 1).
- Add guided validation errors for calibration prerequisites.
- Keep compare result language explicit and non-interpretive.
- Perform early device testing on small-screen Android and iPhone variants.

---

## Complexity Summary (for proposal context)

- **Overall complexity:** Medium.
- **High-risk area:** statistical correctness + calibration accuracy.
- **Most time-consuming area:** polished point-edit UX and regression coverage.
- **Backend complexity:** Low (none in MVP).
- **Delivery confidence:** High if scope remains local-first and manual-marking-based.
