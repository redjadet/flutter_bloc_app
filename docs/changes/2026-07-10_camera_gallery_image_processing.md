# Camera gallery on-device image processing

## Feature: Camera Gallery image processing

### Problem

Camera Gallery demo captured or selected photos but did not demonstrate any
on-device image transformation.

### Scope

- In: non-destructive original, grayscale, sepia, and invert preview filters;
  in-memory JPEG output bounded to 1200px per dimension and input capped at
  20 MiB.
- Out: image upload, persistence, editing controls, new platform permissions,
  or route changes.

### Layers touched

- [x] domain
- [x] data
- [x] presentation
- [ ] DI
- [x] routes / l10n

### Contracts

- Repository: process source bytes through an on-device image codec and return
  a displayable result.
- State: preserve original source path while replacing only preview output and
  tracking selected filter.

### Tests

- [x] Scenario: filter tap keeps original source and displays processed preview.
- [x] Files: `apps/mobile/test/features/camera_gallery/presentation/cubit/camera_gallery_cubit_test.dart`,
  `apps/mobile/test/features/camera_gallery/presentation/pages/camera_gallery_page_test.dart`
- [x] Unit: grayscale output and mobile preview size bound.
- [x] Files: `apps/mobile/test/features/camera_gallery/data/image_processor_test.dart`
- [ ] Integration: N/A — single existing route; picker integration remains covered
  by device testing.

### Proof command

- [x] `cd apps/mobile && flutter test test/features/camera_gallery`
- [x] `dart analyze apps/mobile/lib/features/camera_gallery apps/mobile/test/features/camera_gallery`
- [x] Example hub entry: `example-camera-gallery-button` → `/camera-gallery`
- [x] Integration: `integration_test/camera_gallery_flow_test.dart` + selective map
- [x] Web preflight: Camera & Gallery reachability in `web_bootstrap_smoke_test.dart`

### Risks

`image_picker` source data is platform-specific. Native processing runs on a
background isolate; web processing runs inline because `dart:isolate` is
unsupported by dart4web. `data:` output handles web picker paths and mobile
in-memory previews. Original filter short-circuits to the source path. Filter
cancellation no longer clears the selected image.
