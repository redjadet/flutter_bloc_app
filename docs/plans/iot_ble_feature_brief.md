# IoT BLE Feature Brief

**Status:** Shipped (2026-06-18). Change log: [`changes/2026-06-18_iot-ble-feature.md`](../changes/2026-06-18_iot-ble-feature.md).

## Goal

Add local BLE showcase under existing `/iot-demo` via Cloud | BLE tabs. Mock simulator first; real BLE on Android/iOS.

## Scope

- **In:** `apps/mobile/lib/features/iot/` (domain/data/presentation), app-layer `IotDemoHubPage`, cloud tab extract, tests, docs.
- **Out:** New top-level route, `iot_demo` → `iot` imports, real Bluetooth Classic RFCOMM v1, `?tab=ble` deep link (deferred).

## Architecture

- Websocket-style cubit (no pass-through use cases).
- `MockBleRepository` + `ReactiveBleRepository` implement `BleRepository`; `BleRadioClient` test seam.
- `BleSessionCoordinator` owns connect/discover sequence.
- `BlePermissionGateway` + `permission_handler` for runtime escalation on mobile.
- `Result<T>` at repo; `IotBleErrorCode` in UI.

## Verification

```bash
bash tool/check_feature_brief_linked.sh
bash tool/check_feature_folder_contract.sh --strict
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
flutter analyze
flutter test test/features/iot/ test/app/router/iot_demo_hub_page_test.dart
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```

Integration (device/sim): `integration_test/iot_demo_ble_tab_flow_test.dart`.

## User-facing doc

[`features/iot_ble.md`](../features/iot_ble.md)
