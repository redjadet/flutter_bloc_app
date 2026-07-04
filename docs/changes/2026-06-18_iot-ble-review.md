# IoT BLE feature review (2026-06-18)

Point-in-time note for the mock-first BLE showcase on `/iot-demo`. Plan: [`docs/plans/iot_ble_feature_brief.md`](../plans/iot_ble_feature_brief.md). Change log: [`2026-06-18_iot-ble-feature.md`](2026-06-18_iot-ble-feature.md). User doc: [`features/iot_ble.md`](../features/iot_ble.md).

## Why

Interview/portfolio app needed a bounded BLE demo: Clean Architecture, mock simulator for desktop CI, optional real `flutter_reactive_ble` on mobile, composed at app layer without `iot_demo` → `iot` imports.

## What shipped

### Architecture

- Feature module `apps/mobile/lib/features/iot/` (domain / data / presentation).
- Hub composition in `apps/mobile/lib/app/router/pages/iot_demo_hub_page.dart` — Cloud | BLE tabs; BLE cubit lazy on BLE tab.
- `BleSessionCoordinator`, `Result<T>` + `IotBleErrorCode`, mock catalog (ESP32, HRM, thermometer, smart lock).
- `ReactiveBleRepository` + `BleRadioClient` test seam; `UnsupportedBleRepository` for off-mobile real mode.

### Integration

- DI: `register_iot_services.dart` (from `register_demo_services.dart`).
- Route: `/iot-demo` → `IotDemoHubPage`.
- Platform: Android BLE permissions; iOS `NSBluetooth*` usage strings.
- l10n: BLE keys in all six ARBs.

### Deferred (plan OK)

- Real classic Bluetooth (`flutter_classic_bluetooth`).
- Deep link `?tab=ble`, `DeferredPage`.

### Completed follow-ups

- FRB `discoverAllServices` + `getDiscoveredServices` via `BleRadioClient.discoverGattServices`.
- `permission_handler` escalation in `ReactiveBleRepository.ensureReady()`.
- Integration: `registerIotDemoBleTabIntegrationFlow()` (extended tier + `integration_test/iot_demo_ble_tab_flow_test.dart`).

## Proof

```bash
# Modularity
rg "features/iot/" apps/mobile/lib/features/iot_demo
# expect 0 hits

bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/check_feature_brief_linked.sh

# IoT tests
flutter analyze
flutter test test/features/iot/ test/app/router/iot_demo_hub_page_test.dart
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```

## Follow-ups

- Device QA: [`docs/features/iot_ble_device_test_checklist.md`](../features/iot_ble_device_test_checklist.md).
- Deferred: real classic BT, `?tab=ble` deep link, `DeferredPage`.
