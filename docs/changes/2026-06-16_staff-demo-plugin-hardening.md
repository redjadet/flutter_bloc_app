# Staff demo plugin hardening (2026-06-16)

Bounded follow-up from the staff-demo plugin audit: typed failures for location and
media pickers, clean-arch layering for proof photos, regression tests, and durable
docs — without `permission_handler`, Firebase bootstrap shape changes, or
`CameraGalleryResult` API changes.

## Why

Staff demo relied on ad-hoc exceptions and presentation→data imports for geolocator
and `image_picker`. Audit follow-ups required `Result`/`Failure` at plugin seams,
mapper placement in owning features, cubit tests against domain ports, and checklist
green.

## What changed

### Core / shared

- `lib/core/domain/failure.dart`, `result.dart` — shared failure/result types for
  plugin seams (not a full domain rewrite).
- `lib/shared/utils/failure_to_app_error.dart` — maps `Failure` → `AppError` for UI.
- `lib/shared/platform/secure_secret_storage.dart` — `readResult()` on `SecretStorage`.

### Staff demo

- `StaffDemoLocationService` → `Result<StaffDemoCapturedLocation, Failure>`;
  clock-in unwrap via `staff_demo_location_result_unwrap.dart`.
- Geolocator 14 has no `restricted`/`limited` enum — iOS restricted maps to
  `denied`; approximate location uses `whileInUse` (documented in service).
- Proof photo pick: domain port `StaffDemoProofPhotoPicker`; data impl
  `ImagePickerStaffDemoProofPhotoPicker`; cubit/routes use port + DI only.
- `StaffDemoProofCubit`: `_pickInFlight` ignores concurrent picks; persist
  failures surface `MediaPickErrorKeys.generic`.

### Camera gallery

- `camera_gallery_failure_mapper.dart` moved to `lib/features/camera_gallery/domain/`
  (out of `shared/`).

### Tests

- Location unwrap, proof picker, failure mapper, extended `image_picker` repository
  failure paths; cubit/layout tests use mock `StaffDemoProofPhotoPicker`.
- Hive-backed offline-first tests use `HiveKeyManager(storage: InMemorySecretStorage())`
  so VM `flutter test` does not hit real secure storage (see
  [`storage_rules.md`](../storage_rules.md)).

### Docs

- [`storage_rules.md`](../storage_rules.md), [`plugin_failure_mode_strategy.md`](../plugin_failure_mode_strategy.md) (MD060 tables).
- [`README.md`](README.md) — doc index rows for storage/plugin failure strategy.

## Proof

### Targeted (staff demo / camera gallery)

```bash
bash tool/check_feature_brief_linked.sh
flutter analyze --fatal-infos \
  lib/features/staff_app_demo lib/features/camera_gallery lib/core/domain \
  lib/shared/utils/failure_to_app_error.dart
flutter test \
  test/features/staff_app_demo/data/staff_demo_location_result_unwrap_test.dart \
  test/features/staff_app_demo/data/staff_demo_proof_photo_picker_test.dart \
  test/features/staff_app_demo/data/staff_demo_location_service_test.dart \
  test/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit_test.dart \
  test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart \
  test/features/camera_gallery/
```

### Full delivery checklist (`./bin/checklist`)

- **Exit code:** 0 (`🎉 Delivery checklist complete! All steps passed.`)
- **Unit/widget tests:** 2463 passed, 4 skipped (`04:10 +2463 ~4: All tests passed!`)
- **Coverage (unit lane):** 72.70% (`coverage/coverage_summary.md` after checklist)
- **Notes:** feature folder contract passed with legacy warnings for `staff_app_demo`
  cubit placement (pre-existing; not a blocker)

### Integration (`./bin/integration_tests`)

- **Device:** iPhone 17 Pro simulator (`3439532F-5E88-4860-A9E8-A020EACA656C`)
- **Preflight:** log-filter regression 4/4; web bootstrap smoke 4/4
- **iOS `integration_test/all_flows_test.dart`:** 26/26 passed, exit 0 (~300s)
- **Overall script exit code:** 0
- **Coverage after integration lane:** 74.65% (`coverage/coverage_summary.md` updated by script)

## Manual QA (device / simulator)

- [ ] Clock-in with location **denied** → clock-in still succeeds without GPS;
  integration log records failure (degraded path per unwrap policy), no crash.
- [ ] Proof **camera/gallery cancel** → no SnackBar; **permission denied** → SnackBar.
- [ ] Rapid double-tap photo pick → single photo added.
- [ ] Secure storage unavailable for **Hive encryption key** → encrypted Hive boxes fail to open (fail-closed per [`storage_rules.md`](../storage_rules.md)); app does not silently invent a fallback key.

## Out of scope (unchanged)

- No `permission_handler`; geolocator-only location.
- Firebase bootstrap stays `bool`.
- `CameraGalleryResult` unchanged (mapping only).

## Codex review follow-up (R11)

**Medium — proof persist catch too narrow:** `StaffDemoProofCubit` used `on Exception` around
`addPhotoFromPath`. Web store / Hive can throw `StateError` or other non-`Exception` types,
skipping error-key mapping and staged-pick cleanup. **Fix:** `on Object` in pick persist path.

**Low — location `unableToDetermine` after request:** After `requestPermission()`, only
`denied` / `deniedForever` were rejected; a lingering `unableToDetermine` still fetched GPS.
**Fix:** treat post-request `unableToDetermine` as `PermissionFailure(denied)`.

Regression tests added in cubit + location service suites for both cases.
